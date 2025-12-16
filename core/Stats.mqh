#ifndef STATS_MQH
#define STATS_MQH

// ================================
// Trade Statistics Structure
// ================================
struct TradeStats
{
   double entry;
   double exit;
   double initialRisk;
   double mae;
   double mfe;
   double rMultiple;
   bool   isWin;
   bool   isBuy;
   datetime openTime;
};

// Global variables (declarations)
TradeStats stats;
bool statsActive = false;

// Function declarations


#endif
