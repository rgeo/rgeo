/*
  Main initializer for GEOS wrapper
*/

#include "preface.h"

#ifdef RGEO_GEOS_SUPPORTED

#include <ruby.h>
#include <geos_c.h>

#include "errors.h"

#include "factory.h"
#include "geometry.h"
#include "point.h"
#include "line_string.h"
#include "polygon.h"
#include "geometry_collection.h"
#include "analysis.h"

#endif

RGEO_BEGIN_C

void Init_geos_c_impl()
{
#ifdef RGEO_GEOS_SUPPORTED
  RGeo_Globals* globals;

  globals = rgeo_init_geos_factory();
  rgeo_init_geos_geometry(globals);
  rgeo_init_geos_point(globals);
  rgeo_init_geos_line_string(globals);
  rgeo_init_geos_polygon(globals);
  rgeo_init_geos_geometry_collection(globals);
  rgeo_init_geos_analysis(globals);
  rgeo_init_geos_errors();
#endif
}


RGEO_END_C
