/*
  Analysis methos for GEOS wrapper
*/

#ifndef RGEO_GEOS_ANALYSIS_INCLUDED
#define RGEO_GEOS_ANALYSIS_INCLUDED

#include <ruby.h>

#ifdef RGEO_GEOS_SUPPORTED

RGEO_BEGIN_C

/*
 * call-seq:
 *   RGeo::Geos::Analysis.ccw? -> true or false
 *
 * Checks direction for a ring, returns +true+ if counter-clockwise, +false+
 * otherwise.
 */
VALUE
rgeo_geos_analysis_ccw_p(VALUE self, VALUE ring);

/**
 * call-seq:
 *   RGeo::Geos::Analysis.ccw_supported? -> true or false
 *
 * Always returns true (GEOS 3.14+ always supports CCW checking).
 */
VALUE
rgeo_geos_analysis_supports_ccw(VALUE self);

void
rgeo_init_geos_analysis();

RGEO_END_C

#endif // RGEO_GEOS_SUPPORTED

#endif // RGEO_GEOS_ANALYSIS_INCLUDED
