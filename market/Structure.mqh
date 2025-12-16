#ifndef STRUCTURE_MQH
#define STRUCTURE_MQH

#include "../utils/Drawings.mqh"

#define SWING_LOOKBACK 5

struct Swing
{
   double price;
   datetime time;
};

Swing lastHigh, prevHigh;
Swing lastLow,  prevLow;

bool bosBullish = false;
bool bosBearish = false;
bool chochBullish = false;
bool chochBearish = false;

void InitStructure()
{
   lastHigh.price = prevHigh.price = 0;
   lastLow.price  = prevLow.price  = 0;
}

bool IsSwingHigh(int i)
{
   for(int j=1; j<=SWING_LOOKBACK; j++)
      if(iHigh(_Symbol, PERIOD_M15, i) <= iHigh(_Symbol, PERIOD_M15, i+j) ||
         iHigh(_Symbol, PERIOD_M15, i) <= iHigh(_Symbol, PERIOD_M15, i-j))
         return false;
   return true;
}

bool IsSwingLow(int i)
{
   for(int j=1; j<=SWING_LOOKBACK; j++)
      if(iLow(_Symbol, PERIOD_M15, i) >= iLow(_Symbol, PERIOD_M15, i+j) ||
         iLow(_Symbol, PERIOD_M15, i) >= iLow(_Symbol, PERIOD_M15, i-j))
         return false;
   return true;
}

void UpdateMarketStructure()
{
   bosBullish = bosBearish = false;
   chochBullish = chochBearish = false;

   for(int i=SWING_LOOKBACK; i<50; i++)
   {
      if(IsSwingHigh(i))
      {
         prevHigh = lastHigh;
         lastHigh.price = iHigh(_Symbol, PERIOD_M15, i);
         lastHigh.time  = iTime(_Symbol, PERIOD_M15, i);
         break;
      }
   }

   for(int i=SWING_LOOKBACK; i<50; i++)
   {
      if(IsSwingLow(i))
      {
         prevLow = lastLow;
         lastLow.price = iLow(_Symbol, PERIOD_M15, i);
         lastLow.time  = iTime(_Symbol, PERIOD_M15, i);
         break;
      }
   }

   double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   if(prevHigh.price > 0 && price > prevHigh.price)
      bosBullish = true;

   if(prevLow.price > 0 && price < prevLow.price)
      bosBearish = true;

   if(prevHigh.price > 0 && lastLow.time > lastHigh.time && price < prevLow.price)
      chochBearish = true;

   if(prevLow.price > 0 && lastHigh.time > lastLow.time && price > prevHigh.price)
      chochBullish = true;
}

#endif
