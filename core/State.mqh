#pragma once

enum BIAS { BULLISH, BEARISH, NEUTRAL };

struct TradeState
{
   double entry;
   double stop;
   double initialRisk;
   bool scaled50;
   bool scaled75;
};

extern BIAS currentBias;
extern BIAS htfBias;

extern double asianHigh;
extern double asianLow;

extern double dailyStartEquity;
extern double weeklyStartEquity;
extern int consecutiveLosses;

extern TradeState tradeState;
