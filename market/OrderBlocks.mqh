#ifndef ORDERBLOCKS_MQH
#define ORDERBLOCKS_MQH

#include "../utils/Drawings.mqh"
#include "../utils/Indicators.mqh"

struct OrderBlock
{
   double high;
   double low;
   datetime time;
   bool bullish;
   bool mitagated;
};

OrderBlock activeOB;

void UpdateOrderBlocks()
{
   // Simple OB logic:
   // Bullish OB: Down candle before up move that broke structure
   // Bearish OB: Up candle before down move that broke structure
   // We look for recent impulse moves

   double atr = GetATR();
   if(atr == 0) return;

   // Check last 10 candles for strong moves
   for(int i=1; i<10; i++)
   {
      double open = iOpen(_Symbol, PERIOD_M15, i);
      double close = iClose(_Symbol, PERIOD_M15, i);
      double body = MathAbs(close - open);

      // Strong move definition: body > 1.5 * ATR
      if(body > 1.5 * atr)
      {
         // Bullish Impulse
         if(close > open)
         {
            // The candle BEFORE this impulse is the OB candidate
            int obIndex = i+1;
            if(iClose(_Symbol, PERIOD_M15, obIndex) < iOpen(_Symbol, PERIOD_M15, obIndex)) // Was a down candle
            {
               activeOB.high = iHigh(_Symbol, PERIOD_M15, obIndex);
               activeOB.low = iLow(_Symbol, PERIOD_M15, obIndex);
               activeOB.time = iTime(_Symbol, PERIOD_M15, obIndex);
               activeOB.bullish = true;
               activeOB.mitagated = false;
               
               return; // Found one
            }
         }
         // Bearish Impulse
         else
         {
            // The candle BEFORE this impulse is the OB candidate
            int obIndex = i+1;
            if(iClose(_Symbol, PERIOD_M15, obIndex) > iOpen(_Symbol, PERIOD_M15, obIndex)) // Was an up candle
            {
               activeOB.high = iHigh(_Symbol, PERIOD_M15, obIndex);
               activeOB.low = iLow(_Symbol, PERIOD_M15, obIndex);
               activeOB.time = iTime(_Symbol, PERIOD_M15, obIndex);
               activeOB.bullish = false;
               activeOB.mitagated = false;

               return; // Found one
            }
         }
      }
   }
}

// Check if price is inside a bullish OB
bool BullishOrderBlock(double price)
{
   if(activeOB.time == 0) return false;
   if(!activeOB.bullish) return false;
   if(activeOB.mitagated) return false;

   // Check if price is within OB range
   if(price >= activeOB.low && price <= activeOB.high)
      return true;
      
   return false;
}

// Check if price is inside a bearish OB
bool BearishOrderBlock(double price)
{
   if(activeOB.time == 0) return false;
   if(activeOB.bullish) return false; // Must be bearish
   if(activeOB.mitagated) return false;

   // Check if price is within OB range
   if(price >= activeOB.low && price <= activeOB.high)
      return true;

   return false;
}

#endif
