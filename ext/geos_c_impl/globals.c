#include "preface.h"

#ifdef RGEO_GEOS_SUPPORTED

#include <ruby.h>

#include "globals.h"

RGEO_BEGIN_C

VALUE rgeo_module;

VALUE rgeo_feature_module;
VALUE rgeo_feature_geometry_module;
VALUE rgeo_feature_point_module;
VALUE rgeo_feature_line_string_module;
VALUE rgeo_feature_linear_ring_module;
VALUE rgeo_feature_line_module;
VALUE rgeo_feature_polygon_module;
VALUE rgeo_feature_geometry_collection_module;
VALUE rgeo_feature_multi_point_module;
VALUE rgeo_feature_multi_line_string_module;
VALUE rgeo_feature_multi_polygon_module;

VALUE rgeo_geos_module;
VALUE rgeo_geos_geometry_class;
VALUE rgeo_geos_point_class;
VALUE rgeo_geos_line_string_class;
VALUE rgeo_geos_linear_ring_class;
VALUE rgeo_geos_line_class;
VALUE rgeo_geos_polygon_class;
VALUE rgeo_geos_geometry_collection_class;
VALUE rgeo_geos_multi_point_class;
VALUE rgeo_geos_multi_line_string_class;
VALUE rgeo_geos_multi_polygon_class;

void rgeo_init_geos_globals()
{
  rgeo_module = rb_define_module("RGeo");
  rb_gc_register_mark_object(rgeo_module);

  rgeo_feature_module = rb_define_module_under(rgeo_module, "Feature");
  rb_gc_register_mark_object(rgeo_feature_module);
  rgeo_feature_geometry_module = rb_const_get_at(rgeo_feature_module, rb_intern("Geometry"));
  rb_gc_register_mark_object(rgeo_feature_geometry_module);
  rgeo_feature_point_module = rb_const_get_at(rgeo_feature_module, rb_intern("Point"));
  rb_gc_register_mark_object(rgeo_feature_point_module);
  rgeo_feature_line_string_module = rb_const_get_at(rgeo_feature_module, rb_intern("LineString"));
  rb_gc_register_mark_object(rgeo_feature_line_string_module);
  rgeo_feature_linear_ring_module = rb_const_get_at(rgeo_feature_module, rb_intern("LinearRing"));
  rb_gc_register_mark_object(rgeo_feature_linear_ring_module);
  rgeo_feature_line_module = rb_const_get_at(rgeo_feature_module, rb_intern("Line"));
  rb_gc_register_mark_object(rgeo_feature_line_module);
  rgeo_feature_polygon_module = rb_const_get_at(rgeo_feature_module, rb_intern("Polygon"));
  rb_gc_register_mark_object(rgeo_feature_polygon_module);
  rgeo_feature_geometry_collection_module = rb_const_get_at(rgeo_feature_module, rb_intern("GeometryCollection"));
  rb_gc_register_mark_object(rgeo_feature_geometry_collection_module);
  rgeo_feature_multi_point_module = rb_const_get_at(rgeo_feature_module, rb_intern("MultiPoint"));
  rb_gc_register_mark_object(rgeo_feature_multi_point_module);
  rgeo_feature_multi_line_string_module = rb_const_get_at(rgeo_feature_module, rb_intern("MultiLineString"));
  rb_gc_register_mark_object(rgeo_feature_multi_line_string_module);
  rgeo_feature_multi_polygon_module = rb_const_get_at(rgeo_feature_module, rb_intern("MultiPolygon"));
  rb_gc_register_mark_object(rgeo_feature_multi_polygon_module);

  rgeo_geos_module = rb_define_module_under(rgeo_module, "Geos");
  rb_gc_register_mark_object(rgeo_geos_module);
  rgeo_geos_geometry_class = rb_define_class_under(rgeo_geos_module, "CAPIGeometryImpl", rb_cObject);
  rb_gc_register_mark_object(rgeo_geos_geometry_class);
  rgeo_geos_point_class = rb_define_class_under(rgeo_geos_module, "CAPIPointImpl", rb_cObject);
  rb_gc_register_mark_object(rgeo_geos_point_class);
  rgeo_geos_line_string_class = rb_define_class_under(rgeo_geos_module, "CAPILineStringImpl", rb_cObject);
  rb_gc_register_mark_object(rgeo_geos_line_string_class);
  rgeo_geos_linear_ring_class = rb_define_class_under(rgeo_geos_module, "CAPILinearRingImpl", rb_cObject);
  rb_gc_register_mark_object(rgeo_geos_linear_ring_class);
  rgeo_geos_line_class = rb_define_class_under(rgeo_geos_module, "CAPILineImpl", rb_cObject);
  rb_gc_register_mark_object(rgeo_geos_line_class);
  rgeo_geos_polygon_class = rb_define_class_under(rgeo_geos_module, "CAPIPolygonImpl", rb_cObject);
  rb_gc_register_mark_object(rgeo_geos_polygon_class);
  rgeo_geos_geometry_collection_class = rb_define_class_under(rgeo_geos_module, "CAPIGeometryCollectionImpl", rb_cObject);
  rb_gc_register_mark_object(rgeo_geos_geometry_collection_class);
  rgeo_geos_multi_point_class = rb_define_class_under(rgeo_geos_module, "CAPIMultiPointImpl", rb_cObject);
  rb_gc_register_mark_object(rgeo_geos_multi_point_class);
  rgeo_geos_multi_line_string_class = rb_define_class_under(rgeo_geos_module, "CAPIMultiLineStringImpl", rb_cObject);
  rb_gc_register_mark_object(rgeo_geos_multi_line_string_class);
  rgeo_geos_multi_polygon_class = rb_define_class_under(rgeo_geos_module, "CAPIMultiPolygonImpl", rb_cObject);
  rb_gc_register_mark_object(rgeo_geos_multi_polygon_class);
}

RGEO_END_C

#endif
