//+------------------------------------------------------------------+
//| Gold_SMC_EA - Modular Smart Money Framework                      |
//| Status: Compile-clean skeleton (logic stubs)                     |
//+------------------------------------------------------------------+
#property strict
#property version "1.10"

#include <Trade/Trade.mqh>

// ================= MODULES ==============
#include "modules/Bias.mqh"
#include "modules/Liquidity.mqh"
#include "modules/Displacement.mqh"
#include "modules/HTF_Structure.mqh"
#include "modules/EntryScore.mqh"

// ================= CORE =================
#include "core/Config.mqh"
#include "core/State.mqh"
#include "core/SessionManager.mqh"
#include "core/RiskManager.mqh"
#include "core/FSM.mqh"
#include "core/Stats.mqh"

// ================= UTILS =================
#include "utils/Indicators.mqh"
#include "utils/MathUtils.mqh"
#include "utils/Drawings.mqh"
#include "utils/Logger.mqh"


// ================= MARKET =================
#include "market/Structure.mqh"
#include "market/Liquidity.mqh"
#include "market/OrderBlocks.mqh"
#include "market/FairValueGaps.mqh"

// ==================================================================
// GLOBAL OBJECTS
// ==================================================================
HTFBias htfBias;
MARKET_BIAS currentBias = BIAS_NEUTRAL;
LiquidityDetector liquidity;
DisplacementDetector displacement;
CHTFStructure htf(PERIOD_H1, 120);

// ================= EXECUTION =================
#include "execution/StatsEngine.mqh"
#include "execution/TradeExecutor.mqh"
#include "execution/PositionManager.mqh"
#include "execution/FSMEngine.mqh"
#include "execution/EntryEngine.mqh"

// ==================================================================
// GLOBAL STATE DEFINITIONS (from State.mqh)
// ==================================================================
// Variables are defined in State.mqh
datetime lastProcessedBar = 0;


// ==================================================================
// INITIALIZATION
// ==================================================================
int OnInit()
{
   Print("Gold_SMC_EA initializing...");

   dailyStartEquity  = AccountInfoDouble(ACCOUNT_EQUITY);
   weeklyStartEquity = dailyStartEquity;

   // Init structure engine
   InitStructure();

   // Init indicators
   if(!InitIndicators())
   {
      Print("ERROR: Indicator initialization failed");
      return INIT_FAILED;
   }
   liquidity.Reset();
   liquidity.UpdatePrevDay();
   displacement.Reset();

   Print("Gold_SMC_EA initialized successfully");
   return INIT_SUCCEEDED;
}

// ==================================================================
// DEINITIALIZATION
// ==================================================================
void OnDeinit(const int reason)
{
   Print("Gold_SMC_EA stopped. Reason: ", reason);
}

// ==================================================================
// MAIN TICK LOOP
// ==================================================================
void OnTick()
{
   datetime currentBar = iTime(_Symbol, PERIOD_M15, 0);
   if(currentBar == lastProcessedBar)
   {
      // still same bar -> ONLY manage open trade & stats
      if(PositionSelect(_Symbol))
      {
         ManagePosition();
         Stats_OnTick();
      }
      return;
   }
   lastProcessedBar = currentBar;

   static datetime lastDay = 0;
   datetime dayStart = iTime(_Symbol, PERIOD_D1, 0);
   if(lastDay != dayStart)
   {
      liquidity.Reset();
      liquidity.UpdatePrevDay();
      lastDay = dayStart;
   }
   static datetime lastHTFUpdate = 0;
   datetime htfTime = iTime(_Symbol, PERIOD_H1, 0);
   if(htfTime != lastHTFUpdate)
   {
      htf.Update();
      lastHTFUpdate = htfTime;
   }

   // --- Session & structure updates ---
   UpdateAsianRange();
   UpdateMarketStructure();
   UpdateOrderBlocks();
   // DetermineBias(); // Replaced by HTF Bias Module
   currentBias = htfBias.GetBias();
   liquidity.UpdateAsia(asianHigh, asianLow);


   // --- Manage open trade ---
   if(PositionSelect(_Symbol))
   {
      ManagePosition();
      return;
   }

   // --- Risk & session filters ---
   // if(!IsInKillZone())      return;
   if(!PassRiskChecks())   return;

   // --- Indicators ---
   double atr = GetATR();
   if(atr <= 0) return;
   liquidity.UpdateATR(atr);
   displacement.UpdateATR(atr);

   // --- Entry logic ---
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   ProcessFSM(atr);

   if(PositionSelect(_Symbol))
      ManagePosition();
      Comment(
   "FSM STATE: ", EnumToString(fsmState), "\n",
   "Bias: ", EnumToString(currentBias), "\n",
   "AsianHigh: ", DoubleToString(asianHigh, 2),
   " AsianLow: ", DoubleToString(asianLow, 2)
);


}
void OnTradeTransaction(
   const MqlTradeTransaction& trans,
   const MqlTradeRequest& req,
   const MqlTradeResult& res)
{
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
   {
      if(HistoryDealSelect(trans.deal))
      {
         long entry = HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
         if(entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_OUT_BY)
         {
            // Only reset if position is fully closed
            if(!PositionSelect(_Symbol))
            {
               Stats_OnClose();
               ResetFSM();
               displacement.Reset();
            }
         }
      }
   }
}

