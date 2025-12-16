#pragma once

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
