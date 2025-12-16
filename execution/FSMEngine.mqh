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
   static FSM_STATE lastState = fsmState;
   Print("FSM -> ", EnumToString(fsmState),
      " | Price: ", DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_BID), 2));
    
   Comment("FSM STATE: ", EnumToString(fsmState));

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   MqlDateTime timeStruct;
   TimeCurrent(timeStruct);

   switch(fsmState)
   {
      // ================================
      case WAIT_ASIA:
      // ================================
         // Allow FSM to start after Asian session ends
         if(timeStruct.hour >= AsianEnd)
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

         else if(currentBias == BEARISH && LiquiditySwept(true))
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
         if(currentBias == BULLISH)
         {
            bool isFVG = InsideBullishFVG(ask);
            if(isFVG)
               DrawFVG("Entry_BullishFVG", activeFVG.timeStart, activeFVG.timeEnd, activeFVG.priceHigh, activeFVG.priceLow, clrLightBlue);
               
            if(isFVG || DisplacementUp())
               fsmState = ENTRY;
         }

         else if(currentBias == BEARISH)
         {
            bool isFVG = InsideBearishFVG(bid);
            if(isFVG)
               DrawFVG("Entry_BearishFVG", activeFVG.timeStart, activeFVG.timeEnd, activeFVG.priceHigh, activeFVG.priceLow, clrPink);
               
            if(isFVG || DisplacementDown())
               fsmState = ENTRY;
         }
         break;

      // ================================
      case ENTRY:
      // ================================
         if(!PositionSelect(_Symbol))
         {
            // Mechanical Test: Force Buy
            ExecuteBuy(atr * 1.5);
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

   if(fsmState != lastState)
   {
      string objName = "FSM_" + EnumToString(fsmState);
      ObjectDelete(0, objName);
      ObjectCreate(0, objName, OBJ_VLINE, 0, TimeCurrent(), 0);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, clrYellow);
      lastState = fsmState;
   }
}

#endif
