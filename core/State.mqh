#ifndef STATE_MQH
#define STATE_MQH

#include "../modules/Bias.mqh"
#include "../modules/Liquidity.mqh"
#include "../modules/Displacement.mqh"

struct TradeState
{
   double entry;
   double stop;
   double initialRisk;
   bool scaled50;
   bool scaled75;
};

extern MARKET_BIAS currentBias;
extern LiquidityDetector liquidity;
extern DisplacementDetector displacement;
double chochLevel = 0.0;
ENUM_POSITION_TYPE chochDirection = POSITION_TYPE_BUY;
int chochBarCount = 0;

double asianHigh = 0.0;
double asianLow = 0.0;

double dailyStartEquity = 0.0;
double weeklyStartEquity = 0.0;
int consecutiveLosses = 0;

TradeState tradeState;

extern datetime lastProcessedBar;

#endif
