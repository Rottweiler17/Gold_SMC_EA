#pragma once

bool IsInKillZone()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);

   return (dt.hour >= LondonStart && dt.hour < LondonEnd) ||
          (dt.hour >= NYStart && dt.hour < NYEnd);
}

void UpdateAsianRange()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);

   if(dt.hour < AsianStart || dt.hour >= AsianEnd)
      return;

   double h = iHigh(_Symbol, PERIOD_M15, 1);
   double l = iLow(_Symbol, PERIOD_M15, 1);

   if(asianHigh == 0 || h > asianHigh) asianHigh = h;
   if(asianLow  == 0 || l < asianLow ) asianLow  = l;
}
