/*
  Per-interpreter globals.
  Most of these are cached references to commonly used classes, modules,
  and symbols so we don't have to do a lot of constant lookups and calls
  to rb_intern.
*/

#ifndef RGEO_GEOS_GLOBALS_INCLUDED
#define RGEO_GEOS_GLOBALS_INCLUDED

#include <geos_c.h>

RGEO_BEGIN_C

extern VALUE rgeo_module;

extern VALUE rgeo_feature_module;
extern VALUE rgeo_feature_geometry_module;
extern VALUE rgeo_feature_point_module;
extern VALUE rgeo_feature_line_string_module;
extern VALUE rgeo_feature_linear_ring_module;
extern VALUE rgeo_feature_line_module;
extern VALUE rgeo_feature_polygon_module;
extern VALUE rgeo_feature_geometry_collection_module;
extern VALUE rgeo_feature_multi_point_module;
extern VALUE rgeo_feature_multi_line_string_module;
extern VALUE rgeo_feature_multi_polygon_module;

extern VALUE rgeo_geos_module;
extern VALUE rgeo_geos_geometry_class;
extern VALUE rgeo_geos_point_class;
extern VALUE rgeo_geos_line_string_class;
extern VALUE rgeo_geos_linear_ring_class;
extern VALUE rgeo_geos_line_class;
extern VALUE rgeo_geos_polygon_class;
extern VALUE rgeo_geos_geometry_collection_class;
extern VALUE rgeo_geos_multi_point_class;
extern VALUE rgeo_geos_multi_line_string_class;
extern VALUE rgeo_geos_multi_polygon_class;

/*
  The `RGeo::Geos::Primary` namespace is used to ease argument parsing between
  the ruby interface and the ruby C API. This lets us avoid the usage of
  `rb_scan_args`, and give a more user friendly method source. Hence also less
  burden of maintaining a correct documentation.

  Example usage:

  ```
  // ./geometry.c
  VALUE
  primary_method_geometry_simplify(VALUE _primary, VALUE self, VALUE tolerance)
  {
    ...
  }

  void Init_geometry()
  {
    rb_define_singleton_method(rgeo_geos_primary_module,
                               "simplify",
                               primary_method_geometry_simplify,
                               2);
  }

  # ./geometry.rb
  def simplify(tolerance: 0.2)
    Primary.simplify(self, tolerance)
  end
*/
extern VALUE rgeo_geos_primary_module;

void
rgeo_init_geos_globals();

RGEO_END_C

#endif
