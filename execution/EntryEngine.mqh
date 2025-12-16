#ifndef ENTRYENGINE_MQH
#define ENTRYENGINE_MQH

#include "../core/State.mqh"
#include "../core/Config.mqh"
#include "../market/Liquidity.mqh"
#include "../market/OrderBlocks.mqh"
#include "../market/FairValueGaps.mqh"

bool ValidBullishSetup(double price)
{
   if(currentBias != BULLISH && htfBias != BULLISH) return false;
   if(price <= asianHigh) return false;

   if(RequireLiquiditySweep && !LiquiditySwept()) return false;
   if(RequireOrderBlock && !BullishOrderBlock(price)) return false;
   if(TradeFromFVG && !InsideBullishFVG(price)) return false;

   return true;
}

bool ValidBearishSetup(double price)
{
   if(currentBias != BEARISH && htfBias != BEARISH) return false;
   if(price >= asianLow) return false;

   if(RequireLiquiditySweep && !LiquiditySwept()) return false;
   if(RequireOrderBlock && !BearishOrderBlock(price)) return false;
   if(TradeFromFVG && !InsideBearishFVG(price)) return false;

   return true;
}

#endif
