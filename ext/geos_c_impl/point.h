/*
  Point methods for GEOS wrapper
*/

#ifndef RGEO_GEOS_POINT_INCLUDED
#define RGEO_GEOS_POINT_INCLUDED

#include <ruby.h>

RGEO_BEGIN_C

/*
  Initializes the point module. This should be called after
  the geometry module is initialized.
*/
void
rgeo_init_geos_point();

/*
  Creates a point and returns the ruby object.
  Supports 2D, 3D (XYZ), 3D (XYM), or 4D (XYZM) based on factory flags.
*/
VALUE
rgeo_create_geos_point(VALUE factory, double x, double y, double z, double m);

RGEO_END_C

#endif
