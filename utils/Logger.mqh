#ifndef LOGGER_MQH
#define LOGGER_MQH

#include "../core/Stats.mqh"
#include "../core/State.mqh"

void LogTradeStats()
{
   int handle = FileOpen("SMC_TradeLog.csv",
      FILE_READ | FILE_WRITE | FILE_CSV | FILE_SHARE_WRITE);

   if(handle == INVALID_HANDLE)
      return;

   // Write header if file is new
   if(FileSize(handle) == 0)
   {
      FileWrite(handle,
         "Time",
         "Direction",
         "Entry",
         "Exit",
         "R",
         "MAE",
         "MFE",
         "Bias"
      );
   }

   FileSeek(handle, 0, SEEK_END);

   FileWrite(handle,
      TimeToString(stats.openTime, TIME_DATE | TIME_SECONDS),
      stats.isBuy ? "BUY" : "SELL",
      DoubleToString(stats.entry, 2),
      DoubleToString(stats.exit, 2),
      DoubleToString(stats.rMultiple, 2),
      DoubleToString(stats.mae, 2),
      DoubleToString(stats.mfe, 2),
      EnumToString(currentBias)
   );

   FileClose(handle);
}

#endif
