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
         if(currentBias == BULLISH && LiquiditySwept())
            fsmState = WAIT_CHOCH;

         else if(currentBias == BEARISH && LiquiditySwept())
            fsmState = WAIT_CHOCH;
         break;

      // ================================
      case WAIT_CHOCH:
      // ================================
         // Structure shift
         if(currentBias == BULLISH && chochBullish)
            fsmState = WAIT_FVG;

         else if(currentBias == BEARISH && chochBearish)
            fsmState = WAIT_FVG;
         break;

      // ================================
      case WAIT_FVG:
      // ================================
         // FVG retrace
         if(currentBias == BULLISH && InsideBullishFVG(ask))
            fsmState = ENTRY;

         else if(currentBias == BEARISH && InsideBearishFVG(bid))
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
