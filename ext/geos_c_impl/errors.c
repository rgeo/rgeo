
#ifndef RGEO_GEOS_ERROS_INCLUDED
#define RGEO_GEOS_ERROS_INCLUDED

#include <ruby.h>

#include "preface.h"

#ifdef RGEO_GEOS_SUPPORTED

#include "globals.h"

#include "errors.h"

RGEO_BEGIN_C

VALUE rgeo_error;
VALUE rgeo_invalid_geometry_error;
VALUE geos_error;


void rgeo_init_geos_errors() {
  VALUE error_module;

  error_module = rb_define_module_under(rgeo_module, "Error");
  rgeo_error = rb_define_class_under(error_module, "RGeoError", rb_eRuntimeError);
  rgeo_invalid_geometry_error = rb_define_class_under(error_module, "InvalidGeometry", rgeo_error);
  geos_error = rb_define_class_under(error_module, "GeosError", rgeo_error);
}

RGEO_END_C

#endif // RGEO_GEOS_SUPPORTED

#endif // RGEO_GEOS_ERROS_INCLUDED
