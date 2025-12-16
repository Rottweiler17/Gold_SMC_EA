#ifndef LIQUIDITY_MQH
#define LIQUIDITY_MQH

#include "../utils/Drawings.mqh"
#include "../utils/MathUtils.mqh"
#include "Structure.mqh"
bool LiquiditySwept(bool wantHigh)
{
   static bool sweptHigh = false;
   static bool sweptLow  = false;

   double close = iClose(_Symbol, PERIOD_M15, 1);

   if(wantHigh && !sweptHigh &&
      MathAbs(lastHigh.price - prevHigh.price) < _Point * 10 &&
      close > lastHigh.price)
   {
      sweptHigh = true;
      return true;
   }

   if(!wantHigh && !sweptLow &&
      MathAbs(lastLow.price - prevLow.price) < _Point * 10 &&
      close < lastLow.price)
   {
      sweptLow = true;
      return true;
   }

   return false;
}


#endif
