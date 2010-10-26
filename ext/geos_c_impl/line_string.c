/*
  -----------------------------------------------------------------------------
  
  Line string methods for GEOS wrapper
  
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

#include <string.h>
#include <ruby.h>
#include <geos_c.h>

#include "factory.h"
#include "geometry.h"
#include "point.h"
#include "line_string.h"

RGEO_BEGIN_C


static VALUE method_line_string_geometry_type(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    result = rb_const_get_at(RGEO_GLOBALS_FROM_GEOMETRY(self)->features_module, rb_intern("LineString"));
  }
  return result;
}


static VALUE method_linear_ring_geometry_type(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    result = rb_const_get_at(RGEO_GLOBALS_FROM_GEOMETRY(self)->features_module, rb_intern("LinearRing"));
  }
  return result;
}


static VALUE method_line_geometry_type(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    result = rb_const_get_at(RGEO_GLOBALS_FROM_GEOMETRY(self)->features_module, rb_intern("Line"));
  }
  return result;
}


static VALUE method_line_string_length(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    double len;
    if (GEOSLength_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom, &len)) {
      result = rb_float_new(len);
    }
  }
  return result;
}


static VALUE method_line_string_num_points(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    result = INT2NUM(GEOSGetNumCoordinates_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom));
  }
  return result;
}


static VALUE method_line_string_point_n(VALUE self, VALUE n)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    const GEOSCoordSequence* coord_seq = GEOSGeom_getCoordSeq_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom);
    if (coord_seq) {
      char has_z = GEOSHasZ_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom) == 1 ? 1 : 0;
      unsigned int i = NUM2INT(n);
      double x, y, z;
      if (GEOSCoordSeq_getX_r(RGEO_CONTEXT_FROM_GEOMETRY(self), coord_seq, i, &x)) {
        if (GEOSCoordSeq_getY_r(RGEO_CONTEXT_FROM_GEOMETRY(self), coord_seq, i, &y)) {
          if (has_z) {
            if (GEOSCoordSeq_getZ_r(RGEO_CONTEXT_FROM_GEOMETRY(self), coord_seq, i, &z)) {
              result = rgeo_create_geos_point_3d(RGEO_FACTORY_FROM_GEOMETRY(self), x, y, z);
            }
          }
          else {
            result = rgeo_create_geos_point_2d(RGEO_FACTORY_FROM_GEOMETRY(self), x, y);
          }
        }
      }
    }
  }
  return result;
}


static VALUE method_line_string_points(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    const GEOSCoordSequence* coord_seq = GEOSGeom_getCoordSeq_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom);
    if (coord_seq) {
      char has_z = GEOSHasZ_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom) == 1 ? 1 : 0;
      int count = GEOSGetNumCoordinates_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom);
      result = rb_ary_new2(count);
      double x, y, z;
      int i;
      for (i=0; i<count; ++i) {
        if (GEOSCoordSeq_getX_r(RGEO_CONTEXT_FROM_GEOMETRY(self), coord_seq, i, &x)) {
          if (GEOSCoordSeq_getY_r(RGEO_CONTEXT_FROM_GEOMETRY(self), coord_seq, i, &y)) {
            if (has_z) {
              if (GEOSCoordSeq_getZ_r(RGEO_CONTEXT_FROM_GEOMETRY(self), coord_seq, i, &z)) {
                rb_ary_store(result, i, rgeo_create_geos_point_3d(RGEO_FACTORY_FROM_GEOMETRY(self), x, y, z));
              }
            }
            else {
              rb_ary_store(result, i, rgeo_create_geos_point_2d(RGEO_FACTORY_FROM_GEOMETRY(self), x, y));
            }
          }
        }
      }
    }
  }
  return result;
}


static VALUE method_line_string_start_point(VALUE self)
{
  return method_line_string_point_n(self, 0);
}


static VALUE method_line_string_end_point(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    unsigned int n = GEOSGetNumCoordinates_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom);
    if (n > 0) {
      result = method_line_string_point_n(self, n-1);
    }
  }
  return result;
}


static VALUE method_line_string_is_closed(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    result = rgeo_is_geos_line_string_closed(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom);
  }
  return result;
}


static VALUE method_line_string_is_ring(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    char val = GEOSisRing_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom);
    if (val == 0) {
      result = Qfalse;
    }
    else if (val == 1) {
      result = Qtrue;
    }
  }
  return result;
}


static VALUE method_line_string_eql(VALUE self, VALUE rhs)
{
  VALUE result = rgeo_geos_klasses_and_factories_eql(self, rhs);
  if (RTEST(result)) {
    result = rgeo_geos_coordseqs_eql(RGEO_CONTEXT_FROM_GEOMETRY(self), RGEO_GET_GEOS_GEOMETRY(self), RGEO_GET_GEOS_GEOMETRY(rhs));
  }
  return result;
}


static GEOSCoordSequence* coord_seq_from_array(VALUE factory, VALUE array, char close)
{
  Check_Type(array, T_ARRAY);
  VALUE point_type = rb_const_get_at(RGEO_GLOBALS_FROM_FACTORY(factory)->features_module, rb_intern("Point"));
  unsigned int orig_len = (unsigned int)RARRAY_LEN(array);
  const GEOSGeometry** geoms = ALLOC_N(const GEOSGeometry*, orig_len == 0 ? 1 : orig_len);
  if (!geoms) {
    return NULL;
  }
  char has_z = 0;
  unsigned int i;
  for (i=0; i<orig_len; ++i) {
    const GEOSGeometry* entry_geom = rgeo_convert_to_geos_geometry(factory, rb_ary_entry(array, i), point_type);
    if (!entry_geom) {
      free(geoms);
      return NULL;
    }
    geoms[i] = entry_geom;
    if (GEOSHasZ_r(RGEO_CONTEXT_FROM_FACTORY(factory), entry_geom) == 1) {
      has_z = 1;
    }
  }
  unsigned int len = orig_len;
  if (orig_len > 0 && close && GEOSEquals_r(RGEO_CONTEXT_FROM_FACTORY(factory), geoms[0], geoms[orig_len-1]) != 1) {
    ++len;
  }
  GEOSCoordSequence* coord_seq = GEOSCoordSeq_create_r(RGEO_CONTEXT_FROM_FACTORY(factory), len, has_z ? 3 : 2);
  if (coord_seq) {
    for (i=0; i<len; ++i) {
      const GEOSCoordSequence* cs = GEOSGeom_getCoordSeq_r(RGEO_CONTEXT_FROM_FACTORY(factory), geoms[i == orig_len ? 0 : i]);
      double x;
      if (GEOSCoordSeq_getX_r(RGEO_CONTEXT_FROM_FACTORY(factory), cs, 0, &x)) {
        GEOSCoordSeq_setX_r(RGEO_CONTEXT_FROM_FACTORY(factory), coord_seq, i, x);
      }
      if (GEOSCoordSeq_getY_r(RGEO_CONTEXT_FROM_FACTORY(factory), cs, 0, &x)) {
        GEOSCoordSeq_setY_r(RGEO_CONTEXT_FROM_FACTORY(factory), coord_seq, i, x);
      }
      if (has_z && GEOSCoordSeq_getZ_r(RGEO_CONTEXT_FROM_FACTORY(factory), cs, 0, &x)) {
        GEOSCoordSeq_setZ_r(RGEO_CONTEXT_FROM_FACTORY(factory), coord_seq, i, x);
      }
    }
  }
  free(geoms);
  return coord_seq;
}


static VALUE cmethod_create_line_string(VALUE module, VALUE factory, VALUE array)
{
  VALUE result = Qnil;
  GEOSCoordSequence* coord_seq = coord_seq_from_array(factory, array, 0);
  if (coord_seq) {
    GEOSGeometry* geom = GEOSGeom_createLineString_r(RGEO_CONTEXT_FROM_FACTORY(factory), coord_seq);
    if (geom) {
      result = rgeo_wrap_geos_geometry(factory, geom, rb_const_get_at(RGEO_GLOBALS_FROM_FACTORY(factory)->geos_module, rb_intern("LineStringImpl")));
    }
  }
  return result;
}


static VALUE cmethod_create_linear_ring(VALUE module, VALUE factory, VALUE array)
{
  VALUE result = Qnil;
  GEOSCoordSequence* coord_seq = coord_seq_from_array(factory, array, 1);
  if (coord_seq) {
    GEOSGeometry* geom = GEOSGeom_createLinearRing_r(RGEO_CONTEXT_FROM_FACTORY(factory), coord_seq);
    if (geom) {
      result = rgeo_wrap_geos_geometry(factory, geom, rb_const_get_at(RGEO_GLOBALS_FROM_FACTORY(factory)->geos_module, rb_intern("LinearRingImpl")));
    }
  }
  return result;
}


static VALUE cmethod_create_line(VALUE module, VALUE factory, VALUE start, VALUE end)
{
  VALUE result = Qnil;
  char has_z = 0;
  VALUE point_type = rb_const_get_at(RGEO_GLOBALS_FROM_FACTORY(factory)->features_module, rb_intern("Point"));
  
  const GEOSGeometry* start_geom = rgeo_convert_to_geos_geometry(factory, start, point_type);
  if (!start_geom) {
    return Qnil;
  }
  if (GEOSHasZ_r(RGEO_CONTEXT_FROM_FACTORY(factory), start_geom) == 1) {
    has_z = 1;
  }
  const GEOSGeometry* end_geom = rgeo_convert_to_geos_geometry(factory, end, point_type);
  if (!end_geom) {
    return Qnil;
  }
  if (GEOSHasZ_r(RGEO_CONTEXT_FROM_FACTORY(factory), end_geom) == 1) {
    has_z = 1;
  }
  
  GEOSCoordSequence* coord_seq = GEOSCoordSeq_create_r(RGEO_CONTEXT_FROM_FACTORY(factory), 2, has_z ? 3 : 2);
  if (coord_seq) {
    const GEOSCoordSequence* cs;
    double x;
    cs = GEOSGeom_getCoordSeq_r(RGEO_CONTEXT_FROM_FACTORY(factory), start_geom);
    if (GEOSCoordSeq_getX_r(RGEO_CONTEXT_FROM_FACTORY(factory), cs, 0, &x)) {
      GEOSCoordSeq_setX_r(RGEO_CONTEXT_FROM_FACTORY(factory), coord_seq, 0, x);
    }
    if (GEOSCoordSeq_getY_r(RGEO_CONTEXT_FROM_FACTORY(factory), cs, 0, &x)) {
      GEOSCoordSeq_setY_r(RGEO_CONTEXT_FROM_FACTORY(factory), coord_seq, 0, x);
    }
    if (has_z && GEOSCoordSeq_getZ_r(RGEO_CONTEXT_FROM_FACTORY(factory), cs, 0, &x)) {
      GEOSCoordSeq_setZ_r(RGEO_CONTEXT_FROM_FACTORY(factory), coord_seq, 0, x);
    }
    cs = GEOSGeom_getCoordSeq_r(RGEO_CONTEXT_FROM_FACTORY(factory), end_geom);
    if (GEOSCoordSeq_getX_r(RGEO_CONTEXT_FROM_FACTORY(factory), cs, 0, &x)) {
      GEOSCoordSeq_setX_r(RGEO_CONTEXT_FROM_FACTORY(factory), coord_seq, 1, x);
    }
    if (GEOSCoordSeq_getY_r(RGEO_CONTEXT_FROM_FACTORY(factory), cs, 0, &x)) {
      GEOSCoordSeq_setY_r(RGEO_CONTEXT_FROM_FACTORY(factory), coord_seq, 1, x);
    }
    if (has_z && GEOSCoordSeq_getZ_r(RGEO_CONTEXT_FROM_FACTORY(factory), cs, 0, &x)) {
      GEOSCoordSeq_setZ_r(RGEO_CONTEXT_FROM_FACTORY(factory), coord_seq, 1, x);
    }
    GEOSGeometry* geom = GEOSGeom_createLineString_r(RGEO_CONTEXT_FROM_FACTORY(factory), coord_seq);
    if (geom) {
      result = rgeo_wrap_geos_geometry(factory, geom, rb_const_get_at(RGEO_GLOBALS_FROM_FACTORY(factory)->geos_module, rb_intern("LineImpl")));
    }
  }
  return result;
}


static VALUE impl_copy_from(VALUE klass, VALUE factory, VALUE original, char subtype)
{
  VALUE result = Qnil;
  const GEOSGeometry* original_geom = RGEO_GET_GEOS_GEOMETRY(original);
  if (original_geom && subtype == 1 && GEOSGetNumCoordinates_r(RGEO_CONTEXT_FROM_FACTORY(factory), original_geom) != 2) {
    original_geom = NULL;
  }
  if (original_geom) {
    const GEOSCoordSequence* original_coord_seq = GEOSGeom_getCoordSeq_r(RGEO_CONTEXT_FROM_FACTORY(factory), original_geom);
    if (original_coord_seq) {
      GEOSCoordSequence* coord_seq = GEOSCoordSeq_clone_r(RGEO_CONTEXT_FROM_FACTORY(factory), original_coord_seq);
      if (coord_seq) {
        GEOSGeometry* geom = subtype == 2 ? GEOSGeom_createLinearRing_r(RGEO_CONTEXT_FROM_FACTORY(factory), coord_seq) : GEOSGeom_createLineString_r(RGEO_CONTEXT_FROM_FACTORY(factory), coord_seq);
        if (geom) {
          result = rgeo_wrap_geos_geometry(factory, geom, klass);
        }
      }
    }
  }
  return result;
}


static VALUE cmethod_line_string_copy_from(VALUE klass, VALUE factory, VALUE original)
{
  return impl_copy_from(klass, factory, original, 0);
}


static VALUE cmethod_line_copy_from(VALUE klass, VALUE factory, VALUE original)
{
  return impl_copy_from(klass, factory, original, 1);
}


static VALUE cmethod_linear_ring_copy_from(VALUE klass, VALUE factory, VALUE original)
{
  return impl_copy_from(klass, factory, original, 2);
}


void rgeo_init_geos_line_string(RGeo_Globals* globals)
{
  VALUE geos_line_string_class = rb_define_class_under(globals->geos_module, "LineStringImpl", rb_const_get_at(globals->geos_module, rb_intern("GeometryImpl")));
  VALUE geos_linear_ring_class = rb_define_class_under(globals->geos_module, "LinearRingImpl", geos_line_string_class);
  VALUE geos_line_class = rb_define_class_under(globals->geos_module, "LineImpl", geos_line_string_class);
  
  rb_define_module_function(geos_line_string_class, "create", cmethod_create_line_string, 2);
  rb_define_module_function(geos_line_string_class, "_copy_from", cmethod_line_string_copy_from, 2);
  rb_define_method(geos_line_string_class, "eql?", method_line_string_eql, 1);
  rb_define_method(geos_line_string_class, "geometry_type", method_line_string_geometry_type, 0);
  rb_define_method(geos_line_string_class, "length", method_line_string_length, 0);
  rb_define_method(geos_line_string_class, "num_points", method_line_string_num_points, 0);
  rb_define_method(geos_line_string_class, "point_n", method_line_string_point_n, 1);
  rb_define_method(geos_line_string_class, "points", method_line_string_points, 0);
  rb_define_method(geos_line_string_class, "start_point", method_line_string_start_point, 0);
  rb_define_method(geos_line_string_class, "end_point", method_line_string_end_point, 0);
  rb_define_method(geos_line_string_class, "is_closed?", method_line_string_is_closed, 0);
  rb_define_method(geos_line_string_class, "is_ring?", method_line_string_is_ring, 0);
  
  rb_define_module_function(geos_linear_ring_class, "create", cmethod_create_linear_ring, 2);
  rb_define_module_function(geos_linear_ring_class, "_copy_from", cmethod_linear_ring_copy_from, 2);
  rb_define_method(geos_linear_ring_class, "geometry_type", method_linear_ring_geometry_type, 0);
  
  rb_define_module_function(geos_line_class, "create", cmethod_create_line, 3);
  rb_define_module_function(geos_line_class, "_copy_from", cmethod_line_copy_from, 2);
  rb_define_method(geos_line_class, "geometry_type", method_line_geometry_type, 0);
}


VALUE rgeo_is_geos_line_string_closed(GEOSContextHandle_t context, const GEOSGeometry* geom)
{
  char result = Qnil;
  unsigned int n = GEOSGetNumCoordinates_r(context, geom);
  if (n > 0) {
    double x1, x2, y1, y2, z1, z2;
    const GEOSCoordSequence* coord_seq = GEOSGeom_getCoordSeq_r(context, geom);
    if (GEOSCoordSeq_getX_r(context, coord_seq, 0, &x1)) {
      if (GEOSCoordSeq_getX_r(context, coord_seq, n-1, &x2)) {
        if (x1 == x2) {
          if (GEOSCoordSeq_getY_r(context, coord_seq, 0, &y1)) {
            if (GEOSCoordSeq_getY_r(context, coord_seq, n-2, &y2)) {
              if (y1 == y2) {
                if (GEOSHasZ_r(context, geom) == 1) {
                  if (GEOSCoordSeq_getZ_r(context, coord_seq, 0, &z1)) {
                    if (GEOSCoordSeq_getZ_r(context, coord_seq, 0, &z2)) {
                      result = z1 == z2 ? Qtrue : Qfalse;
                    }
                  }
                }
                else {  // Doesn't have Z coordinate
                  result = Qtrue;
                }
              }
              else {  // Y coordinates are different
                result = Qfalse;
              }
            }
          }
        }
        else {  // X coordinates are different
          result = Qfalse;
        }
      }
    }
  }
  return result;
}


RGEO_END_C

#endif
