#ifndef FAIRVALUEGAPS_MQH
#define FAIRVALUEGAPS_MQH

#include "../utils/Drawings.mqh"
#include "../utils/Indicators.mqh"

struct FVG
{
   datetime timeStart;
   datetime timeEnd;
   double priceHigh;
   double priceLow;
   bool bullish;
};

FVG activeFVG;

// Returns true if a valid bullish FVG exists at index i
// Gap between High(i+2) and Low(i)
bool InsideBullishFVG(int i)
{
   double low0 = iLow(_Symbol, PERIOD_M15, i);
   double high2 = iHigh(_Symbol, PERIOD_M15, i+2);

   // FVG exists if there is a gap
   if(low0 > high2)
   {
       // Check if gap is significant (> 0.5 ATR)
       double gapSize = low0 - high2;
       double atr = GetATR();
       if(atr > 0 && gapSize > 0.5 * atr)
       {
           activeFVG.timeStart = iTime(_Symbol, PERIOD_M15, i+2);
           activeFVG.timeEnd   = iTime(_Symbol, PERIOD_M15, i);
           activeFVG.priceHigh = high2;
           activeFVG.priceLow  = low0;
           activeFVG.bullish   = true;
           return true;
       }
   }
   return false;
}

// Returns true if a valid bearish FVG exists at index i
// Gap between Low(i+2) and High(i)
bool InsideBearishFVG(int i)
{
   double high0 = iHigh(_Symbol, PERIOD_M15, i);
   double low2 = iLow(_Symbol, PERIOD_M15, i+2);

   // FVG exists if there is a gap
   if(low2 > high0)
   {
       // Check if gap is significant
       double gapSize = low2 - high0;
       double atr = GetATR();
       if(atr > 0 && gapSize > 0.5 * atr)
       {
           activeFVG.timeStart = iTime(_Symbol, PERIOD_M15, i+2);
           activeFVG.timeEnd   = iTime(_Symbol, PERIOD_M15, i);
           activeFVG.priceHigh = low2;
           activeFVG.priceLow  = high0;
           activeFVG.bullish   = false;
           return true;
       }
   }
   return false;
}

// Overload: Check if price is inside ANY recent bullish FVG (last 10 candles)
bool InsideBullishFVG(double price)
{
   for(int i=1; i<=10; i++)
   {
      double low0 = iLow(_Symbol, PERIOD_M15, i);
      double high2 = iHigh(_Symbol, PERIOD_M15, i+2);

      if(low0 > high2) // Gap exists
      {
         // Check if price is in this gap
         if(price >= high2 && price <= low0)
         {
            activeFVG.timeStart = iTime(_Symbol, PERIOD_M15, i+2);
            activeFVG.timeEnd   = iTime(_Symbol, PERIOD_M15, i);
            activeFVG.priceHigh = high2;
            activeFVG.priceLow  = low0;
            activeFVG.bullish   = true;
            return true;
         }
      }
   }
   return false;
}

// Overload: Check if price is inside ANY recent bearish FVG (last 10 candles)
bool InsideBearishFVG(double price)
{
   for(int i=1; i<=10; i++)
   {
      double high0 = iHigh(_Symbol, PERIOD_M15, i);
      double low2 = iLow(_Symbol, PERIOD_M15, i+2);

      if(low2 > high0) // Gap exists
      {
         // Check if price is in this gap
         if(price >= high0 && price <= low2)
         {
            activeFVG.timeStart = iTime(_Symbol, PERIOD_M15, i+2);
            activeFVG.timeEnd   = iTime(_Symbol, PERIOD_M15, i);
            activeFVG.priceHigh = low2;
            activeFVG.priceLow  = high0;
            activeFVG.bullish   = false;
            return true;
         }
      }
   }
   return false;
}

#endif
