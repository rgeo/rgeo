
#ifndef RGEO_GEOS_ERROS_INCLUDED
#define RGEO_GEOS_ERROS_INCLUDED

#include <ruby.h>

#ifdef RGEO_GEOS_SUPPORTED

RGEO_BEGIN_C

// Main rgeo error type
extern VALUE rgeo_error;
// RGeo::Error::InvalidGeometry
extern VALUE rgeo_invalid_geometry_error;
// RGeo error specific to the GEOS implementation.
extern VALUE geos_error;

void rgeo_init_geos_errors();

RGEO_END_C

#endif // RGEO_GEOS_SUPPORTED

#endif // RGEO_GEOS_ERROS_INCLUDED
