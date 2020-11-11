/*
  Analysis methos for GEOS wrapper
*/

#ifndef RGEO_GEOS_ANALYSIS_INCLUDED
#define RGEO_GEOS_ANALYSIS_INCLUDED

#include <ruby.h>

#ifdef RGEO_GEOS_SUPPORTED

#include "factory.h"

RGEO_BEGIN_C

/*
 * call-seq:
 *   RGeo::Geos::Analysis.ccw? -> true or false
 *
 * Checks direction for a ring, returns +true+ if counter-clockwise, +false+
 * otherwise.
 */
VALUE rgeo_geos_analysis_ccw_p(VALUE self, VALUE ring);

void rgeo_init_geos_analysis(RGeo_Globals* globals);

RGEO_END_C

#endif // RGEO_GEOS_SUPPORTED

#endif // RGEO_GEOS_ANALYSIS_INCLUDED
