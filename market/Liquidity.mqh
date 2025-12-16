#ifndef LIQUIDITY_MQH
#define LIQUIDITY_MQH

#include "../utils/Drawings.mqh"
#include "Structure.mqh"

bool LiquiditySwept()
{
   double high = iHigh(_Symbol, PERIOD_M15, 1);
   double low  = iLow(_Symbol, PERIOD_M15, 1);

   // Check if we swept the previous high but closed below
   if(prevHigh.price > 0 && high > prevHigh.price)
   {
       double close = iClose(_Symbol, PERIOD_M15, 1);
       if(close < prevHigh.price)
       {
           DrawLiquidity("LiqSweep_High", prevHigh.time, iTime(_Symbol, PERIOD_M15, 1), prevHigh.price, clrRed);
           return true;
       }
   }

   // Check if we swept the previous low but closed above
   if(prevLow.price > 0 && low < prevLow.price)
   {
       double close = iClose(_Symbol, PERIOD_M15, 1);
       if(close > prevLow.price)
       {
           DrawLiquidity("LiqSweep_Low", prevLow.time, iTime(_Symbol, PERIOD_M15, 1), prevLow.price, clrLime);
           return true;
       }
   }

   return false;
}

#endif
