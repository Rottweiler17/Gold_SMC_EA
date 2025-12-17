#ifndef FSMENGINE_MQH
#define FSMENGINE_MQH

#include "../core/FSM.mqh"
#include "../core/State.mqh"
#include "../core/Config.mqh"
#include "../modules/Bias.mqh"
#include "../modules/Displacement.mqh"
#include "../market/Liquidity.mqh"
#include "../market/Structure.mqh"
#include "../market/FairValueGaps.mqh"
#include "../market/OrderBlocks.mqh"
#include "../modules/EntryScore.mqh"
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
         {
            double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            if(liquidity.CheckLiquidity(price))
            {
               HTF_BIAS hb = htf.GetBias();
               if(hb == HTF_BIAS_NONE) break;
               if(hb == HTF_BIAS_BULLISH && !htf.IsInDiscount(price)) break;
               if(hb == HTF_BIAS_BEARISH && !htf.IsInPremium(price)) break;
               fsmState = WAIT_CHOCH;
            }
         }
         break;

      // ================================
      case WAIT_CHOCH:
      // ================================
         if(currentBias == BIAS_BULLISH && chochBullish)
         {
            DrawStructureLabel("FSM_CHOCH_UP", TimeCurrent(), SymbolInfoDouble(_Symbol, SYMBOL_ASK), "CHOCH", clrLime);
            chochLevel = prevHigh.price;
            chochDirection = POSITION_TYPE_BUY;
            chochBarCount = 0;
            fsmState = WAIT_DISPLACEMENT;
         }

         else if(currentBias == BIAS_BEARISH && chochBearish)
         {
            DrawStructureLabel("FSM_CHOCH_DN", TimeCurrent(), SymbolInfoDouble(_Symbol, SYMBOL_BID), "CHOCH", clrRed);
            chochLevel = prevLow.price;
            chochDirection = POSITION_TYPE_SELL;
            chochBarCount = 0;
            fsmState = WAIT_DISPLACEMENT;
         }
         break;

      // ================================
      case WAIT_DISPLACEMENT:
      // ================================
         chochBarCount++;
         if(displacement.Check(chochDirection, currentBias, chochLevel))
         {
            fsmState = WAIT_ENTRY_ZONE;
         }
         if(chochBarCount > 6)
         {
            displacement.Reset();
            ResetFSM();
         }
         break;

      // ================================
      case WAIT_ENTRY_ZONE:
      // ================================
         if(currentBias == BIAS_BULLISH)
         {
            bool isFVG = InsideBullishFVG(ask);
            if(isFVG)
               DrawFVG("Entry_BullishFVG", activeFVG.timeStart, activeFVG.timeEnd, activeFVG.priceHigh, activeFVG.priceLow, clrLightBlue);
            if(isFVG || DisplacementUp())
               fsmState = ENTRY;
         }
         else if(currentBias == BIAS_BEARISH)
         {
            bool isFVG = InsideBearishFVG(bid);
            if(isFVG)
               DrawFVG("Entry_BearishFVG", activeFVG.timeStart, activeFVG.timeEnd, activeFVG.priceHigh, activeFVG.priceLow, clrPink);
            if(isFVG || DisplacementDown())
               fsmState = ENTRY;
         }
         break;
      // ================================
      case WAIT_FVG:
      // ================================
         // FVG retrace
         if(currentBias == BIAS_BULLISH)
         {
            bool isFVG = InsideBullishFVG(ask);
            if(isFVG)
               DrawFVG("Entry_BullishFVG", activeFVG.timeStart, activeFVG.timeEnd, activeFVG.priceHigh, activeFVG.priceLow, clrLightBlue);
               
            if(isFVG || DisplacementUp())
               fsmState = ENTRY;
         }

         else if(currentBias == BIAS_BEARISH)
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
            double px = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            HTF_BIAS hb = htf.GetBias();

            // --- SCORING SYSTEM ---
            int score = 0;
            MqlDateTime dt;
            TimeToStruct(TimeCurrent(), dt);
            
            // 1. Time
            score += CEntryScore::ScoreKillzone(dt.hour);
            
            // 2. Displacement
            double atrNow = GetATR(1);
            double atrPrev = GetATR(5);
            double body = MathAbs(iClose(_Symbol, _Period, 1) - iOpen(_Symbol, _Period, 1));
            score += CEntryScore::ScoreDisplacement(atrNow, body);
            
            // 3. CHoCH
            score += CEntryScore::ScoreCHOCH(true); // Reached ENTRY => CHoCH occurred
            
            // 4. Volatility
            score += CEntryScore::ScoreVolatility(atrNow, atrPrev);

            // 5. Directional Checks (FVG & OB)
            double fvgTapRatio = 0.0;
            bool isInsideOB = false;

            if(currentBias == BIAS_BULLISH)
            {
               // Check FVG
               if(InsideBullishFVG(px))
               {
                  double gapHeight = activeFVG.priceLow - activeFVG.priceHigh;
                  double depth = activeFVG.priceLow - px;
                  if(gapHeight > 0) fvgTapRatio = depth / gapHeight;
               }
               // Check OB
               isInsideOB = BullishOrderBlock(px);
            }
            else if(currentBias == BIAS_BEARISH)
            {
               // Check FVG
               if(InsideBearishFVG(px))
               {
                  double gapHeight = activeFVG.priceHigh - activeFVG.priceLow;
                  double depth = px - activeFVG.priceLow;
                  if(gapHeight > 0) fvgTapRatio = depth / gapHeight;
               }
               // Check OB
               isInsideOB = BearishOrderBlock(px);
            }
            
            score += CEntryScore::ScoreFVG(fvgTapRatio);
            score += CEntryScore::ScoreOrderBlock(isInsideOB);

            int minScore = 6;

            // If volatility is low, relax threshold slightly
            if(atrNow < atrPrev * 1.05)
               minScore = 5;

            // Strong HTF trend -> allow one-point relaxation
            if(htf.GetBias() != HTF_BIAS_NONE)
               minScore--;

            // Final gate
            if(score < minScore)
            {
               Print("ENTRY REJECTED | Score=", score, " Required=", minScore);
               return;
            }

            Print("ENTRY ACCEPTED | Score=", score);
            
            if(currentBias == BIAS_BULLISH && hb == HTF_BIAS_BULLISH && htf.IsInDiscount(px))
            {
               ExecuteBuy(atrNow * 1.5);
               fsmState = MANAGEMENT;
            }
            else if(currentBias == BIAS_BEARISH && hb == HTF_BIAS_BEARISH && htf.IsInPremium(px))
            {
               ExecuteSell(atrNow * 1.5);
               fsmState = MANAGEMENT;
            }
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
      if(ShowFSMMarkers)
      {
         string objName = "FSM_" + EnumToString(fsmState);
         ObjectDelete(0, objName);
         ObjectCreate(0, objName, OBJ_VLINE, 0, TimeCurrent(), 0);
         ObjectSetInteger(0, objName, OBJPROP_COLOR, clrYellow);
      }
      lastState = fsmState;
   }
}

#endif
