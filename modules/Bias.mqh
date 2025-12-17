#ifndef MODULES_BIAS_MQH
#define MODULES_BIAS_MQH

enum MARKET_BIAS
{
   BIAS_BULLISH,
   BIAS_BEARISH,
   BIAS_NEUTRAL
};

class HTFBias
{
private:
   int emaFastHandle;
   int emaSlowHandle;
   ENUM_TIMEFRAMES tf;

public:
   HTFBias(ENUM_TIMEFRAMES timeframe = PERIOD_H1)
   {
      tf = timeframe;
      emaFastHandle = iMA(_Symbol, tf, 50, 0, MODE_EMA, PRICE_CLOSE);
      emaSlowHandle = iMA(_Symbol, tf, 200, 0, MODE_EMA, PRICE_CLOSE);
   }

   ~HTFBias()
   {
      if(emaFastHandle != INVALID_HANDLE)
         IndicatorRelease(emaFastHandle);
      if(emaSlowHandle != INVALID_HANDLE)
         IndicatorRelease(emaSlowHandle);
   }

   MARKET_BIAS GetBias()
   {
      if(emaFastHandle == INVALID_HANDLE || emaSlowHandle == INVALID_HANDLE)
         return BIAS_NEUTRAL;

      double emaFast[2], emaSlow[2];
      if(CopyBuffer(emaFastHandle, 0, 0, 2, emaFast) < 2) return BIAS_NEUTRAL;
      if(CopyBuffer(emaSlowHandle, 0, 0, 2, emaSlow) < 2) return BIAS_NEUTRAL;

      double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);

      // Bullish alignment
      if(price > emaFast[0] && emaFast[0] > emaSlow[0])
         return BIAS_BULLISH;

      // Bearish alignment
      if(price < emaFast[0] && emaFast[0] < emaSlow[0])
         return BIAS_BEARISH;

      return BIAS_NEUTRAL;
   }
};

#endif
