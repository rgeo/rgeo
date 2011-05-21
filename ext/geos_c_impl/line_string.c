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
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  if (self_data->geom) {
    result = RGEO_FACTORY_DATA_PTR(self_data->factory)->globals->feature_line_string;
  }
  return result;
}


static VALUE method_linear_ring_geometry_type(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  if (self_data->geom) {
    result = RGEO_FACTORY_DATA_PTR(self_data->factory)->globals->feature_linear_ring;
  }
  return result;
}


static VALUE method_line_geometry_type(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  if (self_data->geom) {
    result = RGEO_FACTORY_DATA_PTR(self_data->factory)->globals->feature_line;
  }
  return result;
}


static VALUE method_line_string_length(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    double len;
    if (GEOSLength_r(self_data->geos_context, self_geom, &len)) {
      result = rb_float_new(len);
    }
  }
  return result;
}


static VALUE method_line_string_num_points(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    result = INT2NUM(GEOSGetNumCoordinates_r(self_data->geos_context, self_geom));
  }
  return result;
}


static VALUE get_point_from_coordseq(VALUE self, const GEOSCoordSequence* coord_seq, unsigned int i, char has_z)
{
  VALUE result = Qnil;
  double x, y, z;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  GEOSContextHandle_t self_context = self_data->geos_context;
  if (GEOSCoordSeq_getX_r(self_context, coord_seq, i, &x)) {
    if (GEOSCoordSeq_getY_r(self_context, coord_seq, i, &y)) {
      if (has_z) {
        if (!GEOSCoordSeq_getZ_r(self_context, coord_seq, i, &z)) {
          z = 0.0;
        }
      }
      else {
        z = 0.0;
      }
      result = rgeo_create_geos_point(self_data->factory, x, y, z);
    }
  }
  return result;
}


static VALUE method_line_string_point_n(VALUE self, VALUE n)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    GEOSContextHandle_t self_context = self_data->geos_context;
    const GEOSCoordSequence* coord_seq = GEOSGeom_getCoordSeq_r(self_context, self_geom);
    if (coord_seq) {
      char has_z = (char)(RGEO_FACTORY_DATA_PTR(self_data->factory)->flags & RGEO_FACTORYFLAGS_SUPPORTS_Z_OR_M);
      int si = NUM2INT(n);
      if (si >= 0) {
        unsigned int i = si;
        unsigned int size;
        if (GEOSCoordSeq_getSize_r(self_context, coord_seq, &size)) {
          if (i < size) {
            result = get_point_from_coordseq(self, coord_seq, i, has_z);
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
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    GEOSContextHandle_t self_context = self_data->geos_context;
    const GEOSCoordSequence* coord_seq = GEOSGeom_getCoordSeq_r(self_context, self_geom);
    if (coord_seq) {
      char has_z = (char)(RGEO_FACTORY_DATA_PTR(self_data->factory)->flags & RGEO_FACTORYFLAGS_SUPPORTS_Z_OR_M);
      unsigned int size;
      if (GEOSCoordSeq_getSize_r(self_context, coord_seq, &size)) {
        result = rb_ary_new2(size);
        double x, y, z;
        unsigned int i;
        for (i=0; i<size; ++i) {
          VALUE point = get_point_from_coordseq(self, coord_seq, i, has_z);
          if (!NIL_P(point)) {
            rb_ary_store(result, i, point);
          }
        }
      }
    }
  }
  return result;
}


static VALUE method_line_string_start_point(VALUE self)
{
  return method_line_string_point_n(self, INT2NUM(0));
}


static VALUE method_line_string_end_point(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    unsigned int n = GEOSGetNumCoordinates_r(self_data->geos_context, self_geom);
    if (n > 0) {
      result = method_line_string_point_n(self, INT2NUM(n-1));
    }
  }
  return result;
}


static VALUE method_line_string_is_closed(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    result = rgeo_is_geos_line_string_closed(self_data->geos_context, self_geom);
  }
  return result;
}


static VALUE method_line_string_is_ring(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    char val = GEOSisRing_r(self_data->geos_context, self_geom);
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
    RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
    result = rgeo_geos_coordseqs_eql(self_data->geos_context, self_data->geom, RGEO_GEOMETRY_DATA_PTR(rhs)->geom, RGEO_FACTORY_DATA_PTR(self_data->factory)->flags & RGEO_FACTORYFLAGS_SUPPORTS_Z_OR_M);
  }
  return result;
}


static GEOSCoordSequence* coord_seq_from_array(VALUE factory, VALUE array, char close)
{
  Check_Type(array, T_ARRAY);
  RGeo_FactoryData* factory_data = RGEO_FACTORY_DATA_PTR(factory);
  VALUE point_type = factory_data->globals->feature_point;
  unsigned int len = (unsigned int)RARRAY_LEN(array);
  char has_z = (char)(RGEO_FACTORY_DATA_PTR(factory)->flags & RGEO_FACTORYFLAGS_SUPPORTS_Z_OR_M);
  unsigned int dims = has_z ? 3 : 2;
  double* coords = ALLOC_N(double, len == 0 ? 1 : len * dims);
  if (!coords) {
    return NULL;
  }
  GEOSContextHandle_t context = factory_data->geos_context;
  unsigned int i;
  for (i=0; i<len; ++i) {
    char good = 0;
    const GEOSGeometry* entry_geom = rgeo_convert_to_geos_geometry(factory, rb_ary_entry(array, i), point_type);
    if (entry_geom) {
      const GEOSCoordSequence* entry_cs = GEOSGeom_getCoordSeq_r(context, entry_geom);
      if (entry_cs) {
        double x;
        if (GEOSCoordSeq_getX_r(context, entry_cs, 0, &x)) {
          coords[i*dims] = x;
          if (GEOSCoordSeq_getY_r(context, entry_cs, 0, &x)) {
            coords[i*dims+1] = x;
            good = 1;
            if (has_z) {
              if (GEOSCoordSeq_getZ_r(context, entry_cs, 0, &x)) {
                coords[i*dims+2] = x;
              }
              else {
                good = 0;
              }
            }
          }
        }
      }
    }
    if (!good) {
      free(coords);
      return NULL;
    }
  }
  if (len > 0 && close) {
    if (coords[0] == coords[(len-1)*dims] && coords[1] == coords[(len-1)*dims+1]) {
      close = 0;
    }
  }
  else {
    close = 0;
  }
  GEOSCoordSequence* coord_seq = GEOSCoordSeq_create_r(context, len + close, 3);
  if (coord_seq) {
    for (i=0; i<len; ++i) {
      GEOSCoordSeq_setX_r(context, coord_seq, i, coords[i*dims]);
      GEOSCoordSeq_setY_r(context, coord_seq, i, coords[i*dims+1]);
      GEOSCoordSeq_setZ_r(context, coord_seq, i, has_z ? coords[i*dims+2] : 0);
    }
    if (close) {
      GEOSCoordSeq_setX_r(context, coord_seq, len, coords[0]);
      GEOSCoordSeq_setY_r(context, coord_seq, len, coords[1]);
      GEOSCoordSeq_setZ_r(context, coord_seq, len, has_z ? coords[2] : 0);
    }
  }
  free(coords);
  return coord_seq;
}


static VALUE cmethod_create_line_string(VALUE module, VALUE factory, VALUE array)
{
  VALUE result = Qnil;
  GEOSCoordSequence* coord_seq = coord_seq_from_array(factory, array, 0);
  if (coord_seq) {
    RGeo_FactoryData* factory_data = RGEO_FACTORY_DATA_PTR(factory);
    GEOSGeometry* geom = GEOSGeom_createLineString_r(factory_data->geos_context, coord_seq);
    if (geom) {
      result = rgeo_wrap_geos_geometry(factory, geom, factory_data->globals->geos_line_string);
    }
  }
  return result;
}


static VALUE cmethod_create_linear_ring(VALUE module, VALUE factory, VALUE array)
{
  VALUE result = Qnil;
  GEOSCoordSequence* coord_seq = coord_seq_from_array(factory, array, 1);
  if (coord_seq) {
    RGeo_FactoryData* factory_data = RGEO_FACTORY_DATA_PTR(factory);
    GEOSGeometry* geom = GEOSGeom_createLinearRing_r(factory_data->geos_context, coord_seq);
    if (geom) {
      result = rgeo_wrap_geos_geometry(factory, geom, factory_data->globals->geos_linear_ring);
    }
  }
  return result;
}


static void populate_geom_into_coord_seq(GEOSContextHandle_t context, const GEOSGeometry* geom, GEOSCoordSequence* coord_seq, unsigned int i, char has_z)
{
  const GEOSCoordSequence* cs = GEOSGeom_getCoordSeq_r(context, geom);
  double x = 0;
  if (cs) {
    GEOSCoordSeq_getX_r(context, cs, 0, &x);
  }
  GEOSCoordSeq_setX_r(context, coord_seq, i, x);
  x = 0;
  if (cs) {
    GEOSCoordSeq_getY_r(context, cs, 0, &x);
  }
  GEOSCoordSeq_setY_r(context, coord_seq, i, x);
  x = 0;
  if (has_z && cs) {
    GEOSCoordSeq_getZ_r(context, cs, 0, &x);
  }
  GEOSCoordSeq_setZ_r(context, coord_seq, i, x);
}


static VALUE cmethod_create_line(VALUE module, VALUE factory, VALUE start, VALUE end)
{
  VALUE result = Qnil;
  RGeo_FactoryData* factory_data = RGEO_FACTORY_DATA_PTR(factory);
  char has_z = (char)(factory_data->flags & RGEO_FACTORYFLAGS_SUPPORTS_Z_OR_M);
  VALUE point_type = factory_data->globals->feature_point;
  GEOSContextHandle_t context = factory_data->geos_context;
  
  const GEOSGeometry* start_geom = rgeo_convert_to_geos_geometry(factory, start, point_type);
  if (start_geom) {
    const GEOSGeometry* end_geom = rgeo_convert_to_geos_geometry(factory, end, point_type);
    if (end_geom) {
      GEOSCoordSequence* coord_seq = GEOSCoordSeq_create_r(context, 2, 3);
      if (coord_seq) {
        populate_geom_into_coord_seq(context, start_geom, coord_seq, 0, has_z);
        populate_geom_into_coord_seq(context, end_geom, coord_seq, 1, has_z);
        GEOSGeometry* geom = GEOSGeom_createLineString_r(context, coord_seq);
        if (geom) {
          result = rgeo_wrap_geos_geometry(factory, geom, factory_data->globals->geos_line);
        }
      }
    }
  }
  
  return result;
}


static VALUE impl_copy_from(VALUE klass, VALUE factory, VALUE original, char subtype)
{
  VALUE result = Qnil;
  const GEOSGeometry* original_geom = RGEO_GEOMETRY_DATA_PTR(original)->geom;
  if (original_geom) {
    GEOSContextHandle_t context = RGEO_FACTORY_DATA_PTR(factory)->geos_context;
    if (subtype == 1 && GEOSGetNumCoordinates_r(context, original_geom) != 2) {
      original_geom = NULL;
    }
    if (original_geom) {
      const GEOSCoordSequence* original_coord_seq = GEOSGeom_getCoordSeq_r(context, original_geom);
      if (original_coord_seq) {
        GEOSCoordSequence* coord_seq = GEOSCoordSeq_clone_r(context, original_coord_seq);
        if (coord_seq) {
          GEOSGeometry* geom = subtype == 2 ? GEOSGeom_createLinearRing_r(context, coord_seq) : GEOSGeom_createLineString_r(context, coord_seq);
          if (geom) {
            result = rgeo_wrap_geos_geometry(factory, geom, klass);
          }
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
  VALUE geos_line_string_class = rb_define_class_under(globals->geos_module, "LineStringImpl", globals->geos_geometry);
  globals->geos_line_string = geos_line_string_class;
  globals->feature_line_string = rb_const_get_at(globals->feature_module, rb_intern("LineString"));
  rb_funcall(globals->global_mixins, rb_intern("include_in_class"), 2,
    rb_const_get_at(globals->feature_module, rb_intern("Curve")), geos_line_string_class);
  rb_funcall(globals->global_mixins, rb_intern("include_in_class"), 2,
    globals->feature_line_string, geos_line_string_class);
  
  VALUE geos_linear_ring_class = rb_define_class_under(globals->geos_module, "LinearRingImpl", geos_line_string_class);
  globals->geos_linear_ring = geos_linear_ring_class;
  globals->feature_linear_ring = rb_const_get_at(globals->feature_module, rb_intern("LinearRing"));
  rb_funcall(globals->global_mixins, rb_intern("include_in_class"), 2,
    globals->feature_linear_ring, geos_linear_ring_class);
  
  VALUE geos_line_class = rb_define_class_under(globals->geos_module, "LineImpl", geos_line_string_class);
  globals->geos_line = geos_line_class;
  globals->feature_line = rb_const_get_at(globals->feature_module, rb_intern("Line"));
  rb_funcall(globals->global_mixins, rb_intern("include_in_class"), 2,
    globals->feature_line, geos_line_class);
  
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
            if (GEOSCoordSeq_getY_r(context, coord_seq, n-1, &y2)) {
              result = y1 == y2 ? Qtrue : Qfalse;
            }
          }
        }
        else {
          result = Qfalse;
        }
      }
    }
  }
  return result;
}


RGEO_END_C

#endif
