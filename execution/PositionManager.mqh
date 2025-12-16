#ifndef POSITIONMANAGER_MQH
#define POSITIONMANAGER_MQH

#include <Trade/Trade.mqh>
#include "../core/State.mqh"
#include "../utils/Indicators.mqh"
#include "TradeExecutor.mqh"

void ManagePosition()
{
  Stats_OnTick();

   if(!PositionSelect(_Symbol))
{
   Stats_OnClose();
   ResetFSM();
   return;
}


   ulong ticket = PositionGetInteger(POSITION_TICKET);
   double open  = PositionGetDouble(POSITION_PRICE_OPEN);
   double sl    = PositionGetDouble(POSITION_SL);
   double tp    = PositionGetDouble(POSITION_TP);
   double vol   = PositionGetDouble(POSITION_VOLUME);

   ENUM_POSITION_TYPE type =
      (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

   double price = (type == POSITION_TYPE_BUY)
      ? SymbolInfoDouble(_Symbol, SYMBOL_BID)
      : SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   if(tradeState.initialRisk <= 0) return;

   double profit = (type == POSITION_TYPE_BUY)
      ? price - open
      : open - price;

   double r = profit / tradeState.initialRisk;

   // ================================
   // SCALE OUT 50% @ 1.5R
   // ================================
   if(!tradeState.scaled50 && r >= 1.5)
   {
      double closeVol = vol * 0.5;
      if(trade.PositionClosePartial(ticket, closeVol))
         tradeState.scaled50 = true;
   }

   // ================================
   // SCALE OUT 25% @ 2.5R
   // ================================
   if(tradeState.scaled50 && !tradeState.scaled75 && r >= 2.5)
   {
      double closeVol = PositionGetDouble(POSITION_VOLUME) * 0.5;
      if(trade.PositionClosePartial(ticket, closeVol))
         tradeState.scaled75 = true;
   }

   // ================================
   // TRAIL REMAINING POSITION
   // ================================
   if(tradeState.scaled75 && r >= 2.0)
   {
      double atr = GetATR();
      if(atr <= 0) return;

      double trailDist = atr * 0.8;
      double newSL;

      if(type == POSITION_TYPE_BUY)
      {
         newSL = price - trailDist;
         if(newSL > sl)
            trade.PositionModify(ticket, newSL, tp);
      }
      else
      {
         newSL = price + trailDist;
         if(newSL < sl)
            trade.PositionModify(ticket, newSL, tp);
      }
   }
}

#endif
