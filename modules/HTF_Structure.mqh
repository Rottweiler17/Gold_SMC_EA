#ifndef MODULES_HTF_STRUCTURE_MQH
#define MODULES_HTF_STRUCTURE_MQH

enum HTF_BIAS
{
   HTF_BIAS_NONE = 0,
   HTF_BIAS_BULLISH,
   HTF_BIAS_BEARISH
};

class CHTFStructure
{
private:
   ENUM_TIMEFRAMES tf;
   int lookback;

   double htfHigh;
   double htfLow;
   double midpoint;
   HTF_BIAS bias;

public:
   CHTFStructure(ENUM_TIMEFRAMES timeframe = PERIOD_H1, int bars = 100)
   {
      tf = timeframe;
      lookback = bars;
      bias = HTF_BIAS_NONE;
   }

   void Update()
   {
      htfHigh = -DBL_MAX;
      htfLow  = DBL_MAX;

      for(int i = 1; i <= lookback; i++)
      {
         htfHigh = MathMax(htfHigh, iHigh(_Symbol, tf, i));
         htfLow  = MathMin(htfLow,  iLow(_Symbol, tf, i));
      }

      midpoint = (htfHigh + htfLow) / 2.0;

      // --- STRUCTURE BIAS DETECTION ---
      double htfLastHigh = iHigh(_Symbol, tf, 1);
      double htfLastLow  = iLow(_Symbol, tf, 1);
      double htfPrevHigh = iHigh(_Symbol, tf, 5);
      double htfPrevLow  = iLow(_Symbol, tf, 5);

      if(htfLastHigh > htfPrevHigh && htfLastLow > htfPrevLow)
         bias = HTF_BIAS_BULLISH;
      else if(htfLastLow < htfPrevLow && htfLastHigh < htfPrevHigh)
         bias = HTF_BIAS_BEARISH;
      else
         bias = HTF_BIAS_NONE;
   }

   HTF_BIAS GetBias() const
   {
      return bias;
   }

   bool IsInDiscount(double price) const
   {
      return price < midpoint;
   }

   bool IsInPremium(double price) const
   {
      return price > midpoint;
   }

   double GetMidpoint() const
   {
      return midpoint;
   }
};

#endif
