#ifndef BIAS_MQH
#define BIAS_MQH

#include "../core/State.mqh"
#include "Structure.mqh"

void DetermineBias()
{
   if(bosBullish && !chochBearish)
   {
      currentBias = BULLISH;
      htfBias = BULLISH;
      return;
   }

   if(bosBearish && !chochBullish)
   {
      currentBias = BEARISH;
      htfBias = BEARISH;
      return;
   }

   if(chochBullish)
      currentBias = BULLISH;
   else if(chochBearish)
      currentBias = BEARISH;
   else
      currentBias = NEUTRAL;
}

#endif
