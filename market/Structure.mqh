#pragma once

// ----------------------------
// Market Structure Data Types
// ----------------------------
struct SwingPoint
{
   double price;
   datetime time;
   bool isHigh;
};

// Simple containers (stub for now)
SwingPoint lastSwingHigh;
SwingPoint lastSwingLow;

// ----------------------------
// Initialization
// ----------------------------
void InitStructure()
{
   lastSwingHigh.price = 0;
   lastSwingLow.price  = 0;
}

// ----------------------------
// Update Market Structure
// ----------------------------
void UpdateMarketStructure()
{
   // VERY BASIC placeholder logic
   // This is intentionally simple to keep compilation clean

   double high = iHigh(_Symbol, PERIOD_M15, 1);
   double low  = iLow(_Symbol, PERIOD_M15, 1);
   datetime t  = iTime(_Symbol, PERIOD_M15, 1);

   // Update swing high
   if(lastSwingHigh.price == 0 || high > lastSwingHigh.price)
   {
      lastSwingHigh.price = high;
      lastSwingHigh.time  = t;
      lastSwingHigh.isHigh = true;
   }

   // Update swing low
   if(lastSwingLow.price == 0 || low < lastSwingLow.price)
   {
      lastSwingLow.price = low;
      lastSwingLow.time  = t;
      lastSwingLow.isHigh = false;
   }
}

// ----------------------------
// Structure Bias Helper
// ----------------------------
bool StructureBullish()
{
   if(lastSwingHigh.price == 0 || lastSwingLow.price == 0)
      return false;

   return lastSwingLow.time > lastSwingHigh.time;
}

bool StructureBearish()
{
   if(lastSwingHigh.price == 0 || lastSwingLow.price == 0)
      return false;

   return lastSwingHigh.time > lastSwingLow.time;
}
