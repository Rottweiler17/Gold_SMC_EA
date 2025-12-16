#ifndef MATHUTILS_MQH
#define MATHUTILS_MQH

double Clamp(double v, double min, double max)
{
   return MathMax(min, MathMin(max, v));
}

#endif
