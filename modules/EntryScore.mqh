#ifndef MODULES_ENTRY_SCORE_MQH
#define MODULES_ENTRY_SCORE_MQH

class CEntryScore
{
public:
   static int ScoreKillzone(int hour)
   {
      // London 7–10, NY 13–16 (broker time adjust if needed)
      if((hour >= 7 && hour <= 10) || (hour >= 13 && hour <= 16))
         return 1;
      return 0;
   }

   static int ScoreDisplacement(double atr, double body)
   {
      if(body >= atr * 1.8) return 2;
      if(body >= atr * 1.4) return 1;
      return 0;
   }

   static int ScoreCHOCH(bool validBreak)
   {
      return validBreak ? 2 : 0;
   }

   static int ScoreFVG(double tapDepthRatio)
   {
      if(tapDepthRatio >= 0.5) return 2;
      if(tapDepthRatio >= 0.3) return 1;
      return 0;
   }

   static int ScoreOrderBlock(bool insideOB)
   {
      return insideOB ? 1 : 0;
   }

   static int ScoreVolatility(double atrNow, double atrPrev)
   {
      if(atrNow > atrPrev * 1.2) return 1;
      return 0;
   }
};

#endif
