#ifndef CONFIG_MQH
#define CONFIG_MQH

input double RiskPerTrade = 1.0;
input double MaxDailyLoss = 2.0;
input double MaxWeeklyRisk = 3.0;

input int AsianStart = 0;
input int AsianEnd   = 7;
input int LondonStart = 2;
input int LondonEnd   = 5;
input int NYStart     = 7;
input int NYEnd       = 10;

input double RiskRewardRatio = 2.5;

input bool RequireLiquiditySweep = true;
input bool RequireOrderBlock     = true;
input bool TradeFromFVG          = true;

#endif
