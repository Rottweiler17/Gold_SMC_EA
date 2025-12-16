#pragma once

double Clamp(double v, double min, double max)
{
   return MathMax(min, MathMin(max, v));
}
