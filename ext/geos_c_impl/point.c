/*
  -----------------------------------------------------------------------------

  Point methods for GEOS wrapper

  -----------------------------------------------------------------------------
  Copyright 2010-2012 Daniel Azuma

  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
  * Neither the name of the copyright holder, nor the names of any other
    contributors to this software, may be used to endorse or promote products
    derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
  -----------------------------------------------------------------------------
*/


#include "preface.h"

#ifdef RGEO_GEOS_SUPPORTED

#include <ruby.h>
#include <geos_c.h>

#include "factory.h"
#include "geometry.h"
#include "point.h"

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


static VALUE cmethod_create(VALUE module, VALUE factory, VALUE x, VALUE y, VALUE z)
{
  return rgeo_create_geos_point(factory, rb_num2dbl(x), rb_num2dbl(y),
    RGEO_FACTORY_DATA_PTR(factory)->flags & RGEO_FACTORYFLAGS_SUPPORTS_Z_OR_M ? rb_num2dbl(z) : 0);
}


void rgeo_init_geos_point(RGeo_Globals* globals)
{
  VALUE geos_point_class;

  geos_point_class = rb_define_class_under(globals->geos_module, "PointImpl", globals->geos_geometry);
  globals->geos_point = geos_point_class;
  globals->feature_point = rb_const_get_at(globals->feature_module, rb_intern("Point"));
  rb_funcall(globals->global_mixins, rb_intern("include_in_class"), 2,
    globals->feature_point, geos_point_class);

  rb_define_module_function(geos_point_class, "create", cmethod_create, 4);

  rb_define_method(geos_point_class, "rep_equals?", method_point_eql, 1);
  rb_define_method(geos_point_class, "eql?", method_point_eql, 1);
  rb_define_method(geos_point_class, "geometry_type", method_point_geometry_type, 0);
  rb_define_method(geos_point_class, "x", method_point_x, 0);
  rb_define_method(geos_point_class, "y", method_point_y, 0);
  rb_define_method(geos_point_class, "z", method_point_z, 0);
  rb_define_method(geos_point_class, "m", method_point_m, 0);
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
