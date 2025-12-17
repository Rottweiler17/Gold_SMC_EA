#ifndef ENTRYENGINE_MQH
#define ENTRYENGINE_MQH

#include "../core/State.mqh"
#include "../core/Config.mqh"
#include "../modules/Bias.mqh"
#include "../market/Liquidity.mqh"
#include "../market/OrderBlocks.mqh"
#include "../market/FairValueGaps.mqh"

bool ValidBullishSetup(double price)
{
   if(currentBias != BIAS_BULLISH) return false;
   if(price <= asianHigh) return false;

   if(RequireLiquiditySweep && !LiquiditySwept(false)) return false;
   if(RequireOrderBlock && !BullishOrderBlock(price)) return false;
   if(TradeFromFVG && !InsideBullishFVG(price)) return false;

   return true;
}

bool ValidBearishSetup(double price)
{
   if(currentBias != BIAS_BEARISH) return false;
   if(price >= asianLow) return false;

   if(RequireLiquiditySweep && !LiquiditySwept(true)) return false;
   if(RequireOrderBlock && !BearishOrderBlock(price)) return false;
   if(TradeFromFVG && !InsideBearishFVG(price)) return false;

   return true;
}

#endif
