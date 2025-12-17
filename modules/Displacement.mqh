#ifndef MODULES_DISPLACEMENT_MQH
#define MODULES_DISPLACEMENT_MQH

#include "Bias.mqh"

class DisplacementDetector
{
private:
   double atrValue;
   bool detected;
   double impulseHigh;
   double impulseLow;
   datetime impulseTime;

public:
   DisplacementDetector()
   {
      Reset();
   }

   void Reset()
   {
      detected = false;
      impulseHigh = impulseLow = 0.0;
      impulseTime = 0;
   }

   void UpdateATR(double atr)
   {
      atrValue = atr;
   }

   bool Check(ENUM_POSITION_TYPE direction,
              MARKET_BIAS bias,
              double structureLevel)
   {
      if(detected || atrValue <= 0) return false;

      int i = 1; // last closed candle

      double open  = iOpen(_Symbol, PERIOD_M15, i);
      double close = iClose(_Symbol, PERIOD_M15, i);
      double high  = iHigh(_Symbol, PERIOD_M15, i);
      double low   = iLow(_Symbol, PERIOD_M15, i);

      double body = MathAbs(close - open);
      double range = high - low;
      double wick = range - body;

      // 1️⃣ Body size check
      if(body < atrValue * 1.5)
         return false;
      if(wick > body * 0.3)
         return false;

      // 2️⃣ Direction & HTF bias alignment
      if(direction == POSITION_TYPE_BUY)
      {
         if(close <= open) return false;
         if(bias != BIAS_BULLISH) return false;
         if(close <= structureLevel) return false;
      }
      else
      {
         if(close >= open) return false;
         if(bias != BIAS_BEARISH) return false;
         if(close >= structureLevel) return false;
      }

      // Passed displacement
      detected = true;
      impulseHigh = high;
      impulseLow  = low;
      impulseTime = iTime(_Symbol, PERIOD_M15, i);

      Draw();

      return true;
   }

   bool IsDetected() const { return detected; }
   double High() const { return impulseHigh; }
   double Low() const { return impulseLow; }

private:
   void Draw()
   {
      string name = "DISP_" + TimeToString(impulseTime);
      ObjectCreate(0, name, OBJ_RECTANGLE, 0,
                   impulseTime, impulseHigh,
                   impulseTime + PeriodSeconds(PERIOD_M15), impulseLow);
      ObjectSetInteger(0, name, OBJPROP_COLOR, (long)clrAqua);
      ObjectSetInteger(0, name, OBJPROP_BACK, (long)true);
   }
};

#endif
