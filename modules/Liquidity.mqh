#ifndef MODULES_LIQUIDITY_MQH
#define MODULES_LIQUIDITY_MQH

enum LIQUIDITY_TYPE
{
   LIQ_NONE,
   LIQ_ASIA_HIGH,
   LIQ_ASIA_LOW,
   LIQ_PDH,
   LIQ_PDL,
   LIQ_SWING_HIGH,
   LIQ_SWING_LOW
};

#endif

class LiquidityDetector
{
private:
   double asiaHigh, asiaLow;
   double pdHigh, pdLow;
   double atrValue;
   bool liquidityTaken;
   LIQUIDITY_TYPE lastType;

public:
   LiquidityDetector()
   {
      Reset();
   }

   void Reset()
   {
      asiaHigh = asiaLow = 0.0;
      pdHigh = pdLow = 0.0;
      atrValue = 0.0;
      liquidityTaken = false;
      lastType = LIQ_NONE;
   }

   void UpdateATR(double atr)
   {
      atrValue = atr;
   }

   void UpdateAsia(double high, double low)
   {
      asiaHigh = high;
      asiaLow = low;
   }

   void UpdatePrevDay()
   {
      pdHigh = iHigh(_Symbol, PERIOD_D1, 1);
      pdLow  = iLow(_Symbol, PERIOD_D1, 1);
   }

   bool CheckLiquidity(double price)
   {
      if(liquidityTaken || atrValue <= 0) return false;

      double thresh = atrValue * 0.2;

      if(asiaHigh > 0 && price > asiaHigh + thresh)
      {
         Mark(LIQ_ASIA_HIGH);
         return true;
      }
      if(asiaLow > 0 && price < asiaLow - thresh)
      {
         Mark(LIQ_ASIA_LOW);
         return true;
      }
      if(pdHigh > 0 && price > pdHigh + thresh)
      {
         Mark(LIQ_PDH);
         return true;
      }
      if(pdLow > 0 && price < pdLow - thresh)
      {
         Mark(LIQ_PDL);
         return true;
      }

      // Recent swing (last 30 bars)
      double swingHigh = iHigh(_Symbol, PERIOD_M15,
                        iHighest(_Symbol, PERIOD_M15, MODE_HIGH, 30, 1));
      double swingLow  = iLow(_Symbol, PERIOD_M15,
                        iLowest(_Symbol, PERIOD_M15, MODE_LOW, 30, 1));

      if(price > swingHigh + thresh)
      {
         Mark(LIQ_SWING_HIGH);
         return true;
      }
      if(price < swingLow - thresh)
      {
         Mark(LIQ_SWING_LOW);
         return true;
      }

      return false;
   }

   bool IsTaken() const { return liquidityTaken; }
   LIQUIDITY_TYPE Type() const { return lastType; }

private:
   void Mark(LIQUIDITY_TYPE t)
   {
      liquidityTaken = true;
      lastType = t;
      Draw(t);
   }

   void Draw(LIQUIDITY_TYPE t)
   {
      string name = "LIQ_" + IntegerToString((int)t) + "_" + TimeToString(TimeCurrent());
      double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);

      ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrOrange);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
   }
};
