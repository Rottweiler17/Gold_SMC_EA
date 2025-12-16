#pragma once
#include <Trade/Trade.mqh>

CTrade trade;

double CalculateLot(double slDistance)
{
   if(slDistance <= 0) return 0.01;
   return 0.01;
}

bool ExecuteBuy(double slDist)
{
   double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double sl = price - slDist;
   double tp = price + slDist * RiskRewardRatio;

   tradeState.entry = price;
   tradeState.stop = sl;
   tradeState.initialRisk = slDist;
   tradeState.scaled50 = false;
   tradeState.scaled75 = false;

   return trade.Buy(0.01, _Symbol, price, sl, tp);
}
