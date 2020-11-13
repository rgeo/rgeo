
#ifndef RGEO_GEOS_ERROS_INCLUDED
#define RGEO_GEOS_ERROS_INCLUDED

#include <ruby.h>

#include "preface.h"

#ifdef RGEO_GEOS_SUPPORTED

#include "errors.h"

RGEO_BEGIN_C

// Any error relative to RGeo.
VALUE rgeo_error;
// RGeo error specific to the GEOS implementation.
VALUE geos_error;


void rgeo_init_geos_errors() {
  VALUE rgeo_module;
  VALUE error_module;

  rgeo_module = rb_define_module("RGeo");
  error_module = rb_define_module_under(rgeo_module, "Error");
  rgeo_error = rb_define_class_under(error_module, "RGeoError", rb_eRuntimeError);
  geos_error = rb_define_class_under(error_module, "GeosError", rgeo_error);
}

RGEO_END_C

#endif // RGEO_GEOS_SUPPORTED

#endif // RGEO_GEOS_ERROS_INCLUDED
