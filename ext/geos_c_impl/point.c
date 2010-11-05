/*
  -----------------------------------------------------------------------------
  
  Point methods for GEOS wrapper
  
  -----------------------------------------------------------------------------
  Copyright 2010 Daniel Azuma
  
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
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    result = rb_const_get_at(RGEO_GLOBALS_FROM_GEOMETRY(self)->features_module, rb_intern("Point"));
  }
  return result;
}


static VALUE method_point_x(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    const GEOSCoordSequence* coord_seq = GEOSGeom_getCoordSeq_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom);
    if (coord_seq) {
      double val;
      if (GEOSCoordSeq_getX_r(RGEO_CONTEXT_FROM_GEOMETRY(self), coord_seq, 0, &val)) {
        result = rb_float_new(val);
      }
    }
  }
  return result;
}


static VALUE method_point_y(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    const GEOSCoordSequence* coord_seq = GEOSGeom_getCoordSeq_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom);
    if (coord_seq) {
      double val;
      if (GEOSCoordSeq_getY_r(RGEO_CONTEXT_FROM_GEOMETRY(self), coord_seq, 0, &val)) {
        result = rb_float_new(val);
      }
    }
  }
  return result;
}


static VALUE get_3d_point(VALUE self, int flag)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom && RGEO_FACTORY_DATA_FROM_GEOMETRY(self)->flags & flag) {
    const GEOSCoordSequence* coord_seq = GEOSGeom_getCoordSeq_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom);
    if (coord_seq) {
      double val;
      if (GEOSCoordSeq_getZ_r(RGEO_CONTEXT_FROM_GEOMETRY(self), coord_seq, 0, &val)) {
        result = rb_float_new(val);
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
  VALUE result = rgeo_geos_klasses_and_factories_eql(self, rhs);
  if (RTEST(result)) {
    result = rgeo_geos_coordseqs_eql(RGEO_CONTEXT_FROM_GEOMETRY(self), RGEO_GET_GEOS_GEOMETRY(self), RGEO_GET_GEOS_GEOMETRY(rhs), RGEO_FACTORY_DATA_FROM_GEOMETRY(self)->flags & RGEO_FACTORYFLAGS_SUPPORTS_Z_OR_M);
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
  VALUE geos_point_class = rb_define_class_under(globals->geos_module, "PointImpl", rb_const_get_at(globals->geos_module, rb_intern("GeometryImpl")));
  
  rb_define_module_function(geos_point_class, "create", cmethod_create, 4);
  
  rb_define_method(geos_point_class, "eql?", method_point_eql, 1);
  rb_define_method(geos_point_class, "geometry_type", method_point_geometry_type, 0);
  rb_define_method(geos_point_class, "x", method_point_x, 0);
  rb_define_method(geos_point_class, "y", method_point_y, 0);
  rb_define_method(geos_point_class, "z", method_point_z, 0);
  rb_define_method(geos_point_class, "m", method_point_m, 0);
}


VALUE rgeo_create_geos_point(VALUE factory, double x, double y, double z)
{
  VALUE result = Qnil;
  GEOSCoordSequence* coord_seq = GEOSCoordSeq_create_r(RGEO_CONTEXT_FROM_FACTORY(factory), 1, 3);
  if (coord_seq) {
    if (GEOSCoordSeq_setX_r(RGEO_CONTEXT_FROM_FACTORY(factory), coord_seq, 0, x)) {
      if (GEOSCoordSeq_setY_r(RGEO_CONTEXT_FROM_FACTORY(factory), coord_seq, 0, y)) {
        if (GEOSCoordSeq_setZ_r(RGEO_CONTEXT_FROM_FACTORY(factory), coord_seq, 0, z)) {
          GEOSGeometry* geom = GEOSGeom_createPoint_r(RGEO_CONTEXT_FROM_FACTORY(factory), coord_seq);
          if (geom) {
            result = rgeo_wrap_geos_geometry(factory, geom, rb_const_get_at(RGEO_GLOBALS_FROM_FACTORY(factory)->geos_module, rb_intern("PointImpl")));
          }
        }
      }
    }
  }
  return result;
}


RGEO_END_C

#endif
