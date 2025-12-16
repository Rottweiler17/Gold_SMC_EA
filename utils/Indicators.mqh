#ifndef INDICATORS_MQH
#define INDICATORS_MQH

int atrHandle = INVALID_HANDLE;

bool InitIndicators()
{
   atrHandle = iATR(_Symbol, PERIOD_M15, 14);
   return atrHandle != INVALID_HANDLE;
}

double GetATR()
{
   double buf[];
   if(CopyBuffer(atrHandle, 0, 0, 1, buf) <= 0) return 0;
   return buf[0];
}

bool DisplacementUp()
{
   double open  = iOpen(_Symbol, PERIOD_M15, 1);
   double close = iClose(_Symbol, PERIOD_M15, 1);
   double atr   = GetATR();
   
   if(close > open && (close - open) > atr)
      return true;
      
   return false;
}

bool DisplacementDown()
{
   double open  = iOpen(_Symbol, PERIOD_M15, 1);
   double close = iClose(_Symbol, PERIOD_M15, 1);
   double atr   = GetATR();
   
   if(close < open && (open - close) > atr)
      return true;
      
   return false;
}

#endif
