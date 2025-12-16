#ifndef STATSENGINE_MQH
#define STATSENGINE_MQH

#include "../core/Stats.mqh"
#include "../core/State.mqh"
#include "../utils/Logger.mqh"

// ================================
// CALL ON TRADE OPEN
// ================================
void Stats_OnOpen(bool isBuy)
{
   stats.entry = PositionGetDouble(POSITION_PRICE_OPEN);
   stats.initialRisk = tradeState.initialRisk;
   stats.mae = 0;
   stats.mfe = 0;
   stats.isBuy = isBuy;
   stats.isWin = false;
   stats.openTime = TimeCurrent();
   statsActive = true;
}

// ================================
// UPDATE ON EVERY TICK
// ================================
void Stats_OnTick()
{
   if(!statsActive || !PositionSelect(_Symbol))
      return;

   double price = stats.isBuy
      ? SymbolInfoDouble(_Symbol, SYMBOL_BID)
      : SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   double profit = stats.isBuy
      ? (price - stats.entry)
      : (stats.entry - price);

   // Normalize to R
   if(stats.initialRisk > 0)
   {
      stats.mfe = MathMax(stats.mfe, profit / stats.initialRisk);
      stats.mae = MathMin(stats.mae, profit / stats.initialRisk);
   }
}

// ================================
// CALL ON TRADE CLOSE
// ================================
void Stats_OnClose()
{
   if(!statsActive) return;

   stats.exit = stats.isBuy
      ? SymbolInfoDouble(_Symbol, SYMBOL_BID)
      : SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   double netProfit = stats.isBuy
      ? stats.exit - stats.entry
      : stats.entry - stats.exit;

   stats.rMultiple = (stats.initialRisk > 0)
      ? netProfit / stats.initialRisk
      : 0;

   stats.isWin = stats.rMultiple > 0;

   LogTradeStats();
   statsActive = false;
}

#endif
