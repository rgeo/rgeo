/*
  Main initializer for GEOS wrapper
*/

#include "preface.h"

#ifdef RGEO_GEOS_SUPPORTED

#include <ruby.h>
#include <geos_c.h>

#include "ruby_more.h"
#include "globals.h"
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
  rgeo_init_geos_globals();
  rgeo_init_geos_factory();
  rgeo_init_geos_geometry();
  rgeo_init_geos_point();
  rgeo_init_geos_line_string();
  rgeo_init_geos_polygon();
  rgeo_init_geos_geometry_collection();
  rgeo_init_geos_analysis();
  rgeo_init_geos_errors();
#endif
}


RGEO_END_C
