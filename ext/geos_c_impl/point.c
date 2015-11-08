/*
  Point methods for GEOS wrapper
*/

#include "preface.h"

#ifdef RGEO_GEOS_SUPPORTED

#include <ruby.h>
#include <geos_c.h>

#include "factory.h"
#include "geometry.h"
#include "point.h"

#include "coordinates.h"

RGEO_BEGIN_C


static VALUE method_point_geometry_type(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  if (self_data->geom) {
    result = RGEO_FACTORY_DATA_PTR(self_data->factory)->globals->feature_point;
  }
  return result;
}


static VALUE method_point_coordinates(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  GEOSContextHandle_t context;
  const GEOSCoordSequence* coord_sequence;
  int zCoordinate;

  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;

  if (self_geom) {
    zCoordinate = RGEO_FACTORY_DATA_PTR(self_data->factory)->flags & RGEO_FACTORYFLAGS_SUPPORTS_Z_OR_M;
    context = self_data->geos_context;
    coord_sequence = GEOSGeom_getCoordSeq_r(context, self_geom);
    if(coord_sequence) {
      result = rb_ary_pop(extract_points_from_coordinate_sequence(context, coord_sequence, zCoordinate));
    }
  }
  return result;
}


static VALUE method_point_x(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  GEOSContextHandle_t self_context;
  const GEOSCoordSequence* coord_seq;
  double val;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    self_context = self_data->geos_context;
    coord_seq = GEOSGeom_getCoordSeq_r(self_context, self_geom);
    if (coord_seq) {
      if (GEOSCoordSeq_getX_r(self_context, coord_seq, 0, &val)) {
        result = rb_float_new(val);
      }
    }
  }
  return result;
}


static VALUE method_point_y(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  GEOSContextHandle_t self_context;
  const GEOSCoordSequence* coord_seq;
  double val;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    self_context = self_data->geos_context;
    coord_seq = GEOSGeom_getCoordSeq_r(self_context, self_geom);
    if (coord_seq) {
      if (GEOSCoordSeq_getY_r(self_context, coord_seq, 0, &val)) {
        result = rb_float_new(val);
      }
    }
  }
  return result;
}


static VALUE get_3d_point(VALUE self, int flag)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  GEOSContextHandle_t self_context;
  const GEOSCoordSequence* coord_seq;
  double val;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    if (RGEO_FACTORY_DATA_PTR(self_data->factory)->flags & flag) {
      self_context = self_data->geos_context;
      coord_seq = GEOSGeom_getCoordSeq_r(self_context, self_geom);
      if (coord_seq) {
        if (GEOSCoordSeq_getZ_r(self_context, coord_seq, 0, &val)) {
          result = rb_float_new(val);
        }
      }
    }
  }
  return result;
}


static VALUE method_point_z(VALUE self)
{
  return get_3d_point(self, RGEO_FACTORYFLAGS_SUPPORTS_Z);
}


static VALUE method_point_m(VALUE self)
{
  return get_3d_point(self, RGEO_FACTORYFLAGS_SUPPORTS_M);
}


static VALUE method_point_eql(VALUE self, VALUE rhs)
{
  VALUE result;
  RGeo_GeometryData* self_data;

  result = rgeo_geos_klasses_and_factories_eql(self, rhs);
  if (RTEST(result)) {
    self_data = RGEO_GEOMETRY_DATA_PTR(self);
    result = rgeo_geos_coordseqs_eql(self_data->geos_context, self_data->geom, RGEO_GEOMETRY_DATA_PTR(rhs)->geom, RGEO_FACTORY_DATA_PTR(self_data->factory)->flags & RGEO_FACTORYFLAGS_SUPPORTS_Z_OR_M);
  }
  return result;
}


static VALUE method_point_hash(VALUE self)
{
  st_index_t hash;
  RGeo_GeometryData* self_data;
  VALUE factory;

  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  factory = self_data->factory;
  hash = rb_hash_start(0);
  hash = rgeo_geos_objbase_hash(factory,
    RGEO_FACTORY_DATA_PTR(factory)->globals->feature_point, hash);
  hash = rgeo_geos_coordseq_hash(self_data->geos_context, self_data->geom, hash);
  return LONG2FIX(rb_hash_end(hash));
}


static VALUE cmethod_create(VALUE module, VALUE factory, VALUE x, VALUE y, VALUE z)
{
  return rgeo_create_geos_point(factory, rb_num2dbl(x), rb_num2dbl(y),
    RGEO_FACTORY_DATA_PTR(factory)->flags & RGEO_FACTORYFLAGS_SUPPORTS_Z_OR_M ? rb_num2dbl(z) : 0);
}


void rgeo_init_geos_point(RGeo_Globals* globals)
{
  VALUE geos_point_methods;

  // Class methods for CAPIPointImpl
  rb_define_module_function(globals->geos_point, "create", cmethod_create, 4);

  // CAPIPointMethods module
  geos_point_methods = rb_define_module_under(globals->geos_module, "CAPIPointMethods");
  rb_define_method(geos_point_methods, "rep_equals?", method_point_eql, 1);
  rb_define_method(geos_point_methods, "eql?", method_point_eql, 1);
  rb_define_method(geos_point_methods, "hash", method_point_hash, 0);
  rb_define_method(geos_point_methods, "geometry_type", method_point_geometry_type, 0);
  rb_define_method(geos_point_methods, "x", method_point_x, 0);
  rb_define_method(geos_point_methods, "y", method_point_y, 0);
  rb_define_method(geos_point_methods, "z", method_point_z, 0);
  rb_define_method(geos_point_methods, "m", method_point_m, 0);
  rb_define_method(geos_point_methods, "coordinates", method_point_coordinates, 0);
}


VALUE rgeo_create_geos_point(VALUE factory, double x, double y, double z)
{
  VALUE result;
  RGeo_FactoryData* factory_data;
  GEOSContextHandle_t context;
  GEOSCoordSequence* coord_seq;
  GEOSGeometry* geom;

  result = Qnil;
  factory_data = RGEO_FACTORY_DATA_PTR(factory);
  context = factory_data->geos_context;
  coord_seq = GEOSCoordSeq_create_r(context, 1, 3);
  if (coord_seq) {
    if (GEOSCoordSeq_setX_r(context, coord_seq, 0, x)) {
      if (GEOSCoordSeq_setY_r(context, coord_seq, 0, y)) {
        if (GEOSCoordSeq_setZ_r(context, coord_seq, 0, z)) {
          geom = GEOSGeom_createPoint_r(context, coord_seq);
          if (geom) {
            result = rgeo_wrap_geos_geometry(factory, geom, factory_data->globals->geos_point);
          }
        }
      }
    }
  }
  return result;
}


RGEO_END_C

#endif
