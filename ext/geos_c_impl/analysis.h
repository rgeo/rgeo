/*
  Analysis methods for GEOS wrapper
*/

#ifndef RGEO_GEOS_ANALYSIS_INCLUDED
#define RGEO_GEOS_ANALYSIS_INCLUDED

#include <ruby.h>

#ifdef RGEO_GEOS_SUPPORTED

RGEO_BEGIN_C

VALUE
rgeo_geos_analysis_ccw_p(VALUE self, VALUE ring);

void
rgeo_init_geos_analysis();

RGEO_END_C

#endif // RGEO_GEOS_SUPPORTED

#endif // RGEO_GEOS_ANALYSIS_INCLUDED
