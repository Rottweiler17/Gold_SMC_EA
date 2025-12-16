#ifndef DRAWINGS_MQH
#define DRAWINGS_MQH

// ================================
// UTILITIES
// ================================
void DeleteIfExists(string name)
{
   if(ObjectFind(0, name) >= 0)
      ObjectDelete(0, name);
}

// ================================
// SWING POINTS
// ================================
void DrawSwing(string name, datetime t, double price, color clr)
{
   DeleteIfExists(name);

   ObjectCreate(0, name, OBJ_ARROW, 0, t, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
}

// ================================
// MARKET STRUCTURE LABELS
// ================================
void DrawStructureLabel(string name, datetime t, double price, string text, color clr)
{
   DeleteIfExists(name);

   ObjectCreate(0, name, OBJ_TEXT, 0, t, price);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
}

// ================================
// ORDER BLOCK BOX
// ================================
void DrawOrderBlock(string name, datetime t1, datetime t2, double high, double low, color clr)
{
   DeleteIfExists(name);

   ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, high, t2, low);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   // ObjectSetInteger(0, name, OBJPROP_TRANSPARENCY, 70);
}

// ================================
// FAIR VALUE GAP BOX
// ================================
void DrawFVG(string name, datetime t1, datetime t2, double top, double bottom, color clr)
{
   DeleteIfExists(name);

   ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, top, t2, bottom);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
   // ObjectSetInteger(0, name, OBJPROP_TRANSPARENCY, 80);
}

// ================================
// LIQUIDITY LINE
// ================================
void DrawLiquidity(string name, datetime t1, datetime t2, double price, color clr)
{
   DeleteIfExists(name);

   ObjectCreate(0, name, OBJ_TREND, 0, t1, price, t2, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
}

#endif
