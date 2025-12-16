#pragma once

bool PassRiskChecks()
{
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);

   if(dailyStartEquity <= 0 || weeklyStartEquity <= 0)
      return true;

   double dailyLoss =
      (equity - dailyStartEquity) / dailyStartEquity * 100.0;

   double weeklyLoss =
      (equity - weeklyStartEquity) / weeklyStartEquity * 100.0;

   if(dailyLoss <= -MaxDailyLoss) return false;
   if(weeklyLoss <= -MaxWeeklyRisk) return false;

   return true;
}
