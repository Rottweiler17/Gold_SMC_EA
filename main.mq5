//+------------------------------------------------------------------+
//| Gold_SMC_EA - Modular Smart Money Framework                      |
//| Status: Compile-clean skeleton (logic stubs)                     |
//+------------------------------------------------------------------+
#property strict
#property version "1.10"

#include <Trade/Trade.mqh>

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
#include "market/Bias.mqh"
#include "market/Liquidity.mqh"
#include "market/OrderBlocks.mqh"
#include "market/FairValueGaps.mqh"

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
   // --- Session & structure updates ---
  UpdateAsianRange();
UpdateMarketStructure();
UpdateOrderBlocks();
DetermineBias();


   // --- Manage open trade ---
   if(PositionSelect(_Symbol))
   {
      ManagePosition();
      return;
   }

   // --- Risk & session filters ---
   if(!IsInKillZone())      return;
   if(!PassRiskChecks())   return;

   // --- Indicators ---
   double atr = GetATR();
   if(atr <= 0) return;

   // --- Entry logic ---
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   if(ValidBullishSetup(ask))
{
   ExecuteBuy(atr * 1.5);
   return;
}

if(ValidBearishSetup(bid))
{
   ExecuteSell(atr * 1.5);
   return;
}
 ProcessFSM(atr);

   if(PositionSelect(_Symbol))
      ManagePosition();

}
