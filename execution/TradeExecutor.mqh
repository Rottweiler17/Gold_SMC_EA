#ifndef TRADEEXECUTOR_MQH
#define TRADEEXECUTOR_MQH

#include <Trade/Trade.mqh>
#include "../core/Config.mqh"
#include "../core/State.mqh"
#include "../modules/Bias.mqh"
#include "StatsEngine.mqh"

CTrade trade;

// ================================
// LOT SIZE (RISK BASED)
// ================================
double CalculateLot(double slDistance)
{
   if(slDistance <= 0) return 0;

   double equity     = AccountInfoDouble(ACCOUNT_EQUITY);
   double riskMoney  = equity * (RiskPerTrade / 100.0);

   double tickValue  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize   = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

   if(tickValue <= 0 || tickSize <= 0) return 0;

   double lossPerLot = (slDistance / tickSize) * tickValue;
   if(lossPerLot <= 0) return 0;

   double lot = riskMoney / lossPerLot;

   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   lot = MathFloor(lot / step) * step;
   lot = MathMax(minLot, MathMin(maxLot, lot));

   return NormalizeDouble(lot, 2);
}

// ================================
// BUY EXECUTION
// ================================
bool ExecuteBuy(double slDist)
{
   if(currentBias != BIAS_BULLISH) return false;

   double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double sl    = price - slDist;
   double tp    = price + slDist * RiskRewardRatio;

   double lot = CalculateLot(slDist);
   if(lot <= 0) return false;

   if(!trade.Buy(lot, _Symbol, price, sl, tp, "SMC_BUY"))
      return false;

   tradeState.entry = price;
   tradeState.stop  = sl;
   tradeState.initialRisk = slDist;
   tradeState.scaled50 = false;
   tradeState.scaled75 = false;
   Stats_OnOpen(true);

   return true;
}

// ================================
// SELL EXECUTION
// ================================
bool ExecuteSell(double slDist)
{
   if(currentBias != BIAS_BEARISH) return false;

   double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double sl    = price + slDist;
   double tp    = price - slDist * RiskRewardRatio;

   double lot = CalculateLot(slDist);
   if(lot <= 0) return false;

   if(!trade.Sell(lot, _Symbol, price, sl, tp, "SMC_SELL"))
      return false;

   tradeState.entry = price;
   tradeState.stop  = sl;
   tradeState.initialRisk = slDist;
   tradeState.scaled50 = false;
   tradeState.scaled75 = false;
   Stats_OnOpen(false);

   return true;
}

#endif
