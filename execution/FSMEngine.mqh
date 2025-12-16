#ifndef FSMENGINE_MQH
#define FSMENGINE_MQH

#include "../core/FSM.mqh"
#include "../core/State.mqh"
#include "../core/Config.mqh"
#include "../market/Liquidity.mqh"
#include "../market/Structure.mqh"
#include "../market/FairValueGaps.mqh"
#include "TradeExecutor.mqh"
#include "PositionManager.mqh"

void ProcessFSM(double atr)
{
   Comment("FSM STATE: ", EnumToString(fsmState));

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   switch(fsmState)
   {
      // ================================
      case WAIT_ASIA:
      // ================================
         // Price must take Asian range
         if(ask > asianHigh || bid < asianLow)
            fsmState = WAIT_LIQUIDITY;
         break;

      // ================================
      case WAIT_LIQUIDITY:
      // ================================
         // Liquidity sweep required
         if(currentBias == BULLISH && LiquiditySwept(false))
         {
            DrawLiquidity("SellSideSweep", prevLow.time, TimeCurrent(), prevLow.price, clrLime);
            fsmState = WAIT_CHOCH;
         }

         else if(currentBias == BEARISH && LiquiditySwept(false))
         {
            DrawLiquidity("BuySideSweep", prevHigh.time, TimeCurrent(), prevHigh.price, clrRed);
            fsmState = WAIT_CHOCH;
         }
         break;

      // ================================
      case WAIT_CHOCH:
      // ================================
         // Structure shift
         if(currentBias == BULLISH && chochBullish)
         {
            DrawStructureLabel("FSM_CHOCH_UP", TimeCurrent(), SymbolInfoDouble(_Symbol, SYMBOL_ASK), "CHOCH", clrLime);
            fsmState = WAIT_FVG;
         }

         else if(currentBias == BEARISH && chochBearish)
         {
            DrawStructureLabel("FSM_CHOCH_DN", TimeCurrent(), SymbolInfoDouble(_Symbol, SYMBOL_BID), "CHOCH", clrRed);
            fsmState = WAIT_FVG;
         }
         break;

      // ================================
      case WAIT_FVG:
      // ================================
         // FVG retrace
         if(currentBias == BULLISH && InsideBullishFVG(ask, true))
            fsmState = ENTRY;

         else if(currentBias == BEARISH && InsideBearishFVG(bid, true))
            fsmState = ENTRY;
         break;

      // ================================
      case ENTRY:
      // ================================
         if(PositionSelect(_Symbol))
         {
            fsmState = MANAGEMENT;
            break;
         }

         if(currentBias == BULLISH)
         {
            if(ExecuteBuy(atr * 1.5))
               fsmState = MANAGEMENT;
         }
         else if(currentBias == BEARISH)
         {
            if(ExecuteSell(atr * 1.5))
               fsmState = MANAGEMENT;
         }
         break;

      // ================================
      case MANAGEMENT:
      // ================================
         if(!PositionSelect(_Symbol))
         {
            ResetFSM();
         }
         break;
   }
}

#endif
