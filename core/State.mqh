#ifndef STATE_MQH
#define STATE_MQH

enum BIAS { BULLISH, BEARISH, NEUTRAL };

struct TradeState
{
   double entry;
   double stop;
   double initialRisk;
   bool scaled50;
   bool scaled75;
};

BIAS currentBias = NEUTRAL;
BIAS htfBias = NEUTRAL;

double asianHigh = 0.0;
double asianLow = 0.0;

double dailyStartEquity = 0.0;
double weeklyStartEquity = 0.0;
int consecutiveLosses = 0;

TradeState tradeState;

extern datetime lastProcessedBar;

#endif
