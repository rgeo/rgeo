/*
  -----------------------------------------------------------------------------

  Polygon methods for GEOS wrapper

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
#include "line_string.h"
#include "polygon.h"

RGEO_BEGIN_C


static VALUE method_polygon_eql(VALUE self, VALUE rhs)
{
  VALUE result;
  RGeo_GeometryData* self_data;

  result = rgeo_geos_klasses_and_factories_eql(self, rhs);
  if (RTEST(result)) {
    self_data = RGEO_GEOMETRY_DATA_PTR(self);
    result = rgeo_geos_polygons_eql(self_data->geos_context, self_data->geom, RGEO_GEOMETRY_DATA_PTR(rhs)->geom, RGEO_FACTORY_DATA_PTR(self_data->factory)->flags & RGEO_FACTORYFLAGS_SUPPORTS_Z_OR_M);
  }
  return result;
}


static VALUE method_polygon_geometry_type(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  if (self_data->geom) {
    result = RGEO_FACTORY_DATA_PTR(self_data->factory)->globals->feature_polygon;
  }
  return result;
}


static VALUE method_polygon_area(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  double area;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    if (GEOSArea_r(self_data->geos_context, self_geom, &area)) {
      result = rb_float_new(area);
    }
  }
  return result;
}


static VALUE method_polygon_centroid(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    result = rgeo_wrap_geos_geometry(self_data->factory, GEOSGetCentroid_r(self_data->geos_context, self_geom), RGEO_FACTORY_DATA_PTR(self_data->factory)->globals->geos_point);
  }
  return result;
}


static VALUE method_polygon_point_on_surface(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    result = rgeo_wrap_geos_geometry(self_data->factory, GEOSPointOnSurface_r(self_data->geos_context, self_geom), RGEO_FACTORY_DATA_PTR(self_data->factory)->globals->geos_point);
  }
  return result;
}


static VALUE method_polygon_exterior_ring(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    result = rgeo_wrap_geos_geometry_clone(self_data->factory, GEOSGetExteriorRing_r(self_data->geos_context, self_geom), RGEO_FACTORY_DATA_PTR(self_data->factory)->globals->geos_linear_ring);
  }
  return result;
}


static VALUE method_polygon_num_interior_rings(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  int num;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    num = GEOSGetNumInteriorRings_r(self_data->geos_context, self_geom);
    if (num >= 0) {
      result = INT2NUM(num);
    }
  }
  return result;
}


static VALUE method_polygon_interior_ring_n(VALUE self, VALUE n)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  int i;
  GEOSContextHandle_t self_context;
  int num;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    i = NUM2INT(n);
    if (i >= 0) {
      self_context = self_data->geos_context;
      num = GEOSGetNumInteriorRings_r(self_context, self_geom);
      if (i < num) {
        result = rgeo_wrap_geos_geometry_clone(self_data->factory,
          GEOSGetInteriorRingN_r(self_context, self_geom, i),
          RGEO_FACTORY_DATA_PTR(self_data->factory)->globals->geos_linear_ring);
      }
    }
  }
  return result;
}


static VALUE method_polygon_interior_rings(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  GEOSContextHandle_t self_context;
  int count;
  VALUE factory;
  VALUE linear_ring_class;
  int i;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    self_context = self_data->geos_context;
    count = GEOSGetNumInteriorRings_r(self_context, self_geom);
    if (count >= 0) {
      result = rb_ary_new2(count);
      factory = self_data->factory;
      linear_ring_class = RGEO_FACTORY_DATA_PTR(self_data->factory)->globals->geos_linear_ring;
      for (i=0; i<count; ++i) {
        rb_ary_store(result, i, rgeo_wrap_geos_geometry_clone(factory, GEOSGetInteriorRingN_r(self_context, self_geom, i), linear_ring_class));
      }
    }
  }
  return result;
}


static VALUE cmethod_create(VALUE module, VALUE factory, VALUE exterior, VALUE interior_array)
{
  RGeo_FactoryData* factory_data;
  VALUE linear_ring_type;
  GEOSGeometry* exterior_geom;
  GEOSContextHandle_t context;
  unsigned int len;
  GEOSGeometry** interior_geoms;
  unsigned int actual_len;
  unsigned int i;
  GEOSGeometry* interior_geom;
  GEOSGeometry* polygon;

  Check_Type(interior_array, T_ARRAY);
  factory_data = RGEO_FACTORY_DATA_PTR(factory);
  linear_ring_type = factory_data->globals->feature_linear_ring;
  exterior_geom = rgeo_convert_to_detached_geos_geometry(exterior, factory, linear_ring_type, NULL);
  if (exterior_geom) {
    context = factory_data->geos_context;
    len = (unsigned int)RARRAY_LEN(interior_array);
    interior_geoms = ALLOC_N(GEOSGeometry*, len == 0 ? 1 : len);
    if (interior_geoms) {
      actual_len = 0;
      for (i=0; i<len; ++i) {
        interior_geom = rgeo_convert_to_detached_geos_geometry(rb_ary_entry(interior_array, i), factory, linear_ring_type, NULL);
        if (interior_geom) {
          interior_geoms[actual_len++] = interior_geom;
        }
      }
      if (len == actual_len) {
        polygon = GEOSGeom_createPolygon_r(context, exterior_geom, interior_geoms, actual_len);
        if (polygon) {
          free(interior_geoms);
          return rgeo_wrap_geos_geometry(factory, polygon, factory_data->globals->geos_polygon);
        }
      }
      for (i=0; i<actual_len; ++i) {
        GEOSGeom_destroy_r(context, interior_geoms[i]);
      }
      free(interior_geoms);
    }
    GEOSGeom_destroy_r(context, exterior_geom);
  }
  return Qnil;
}


void rgeo_init_geos_polygon(RGeo_Globals* globals)
{
  VALUE geos_polygon_class;

  geos_polygon_class = rb_define_class_under(globals->geos_module, "PolygonImpl", globals->geos_geometry);
  globals->geos_polygon = geos_polygon_class;
  globals->feature_polygon = rb_const_get_at(globals->feature_module, rb_intern("Polygon"));
  rb_funcall(globals->global_mixins, rb_intern("include_in_class"), 2,
    rb_const_get_at(globals->feature_module, rb_intern("Surface")), geos_polygon_class);
  rb_funcall(globals->global_mixins, rb_intern("include_in_class"), 2,
    globals->feature_polygon, geos_polygon_class);

  rb_define_module_function(geos_polygon_class, "create", cmethod_create, 3);

  rb_define_method(geos_polygon_class, "rep_equals?", method_polygon_eql, 1);
  rb_define_method(geos_polygon_class, "eql?", method_polygon_eql, 1);
  rb_define_method(geos_polygon_class, "geometry_type", method_polygon_geometry_type, 0);
  rb_define_method(geos_polygon_class, "area", method_polygon_area, 0);
  rb_define_method(geos_polygon_class, "centroid", method_polygon_centroid, 0);
  rb_define_method(geos_polygon_class, "point_on_surface", method_polygon_point_on_surface, 0);
  rb_define_method(geos_polygon_class, "exterior_ring", method_polygon_exterior_ring, 0);
  rb_define_method(geos_polygon_class, "num_interior_rings", method_polygon_num_interior_rings, 0);
  rb_define_method(geos_polygon_class, "interior_ring_n", method_polygon_interior_ring_n, 1);
  rb_define_method(geos_polygon_class, "interior_rings", method_polygon_interior_rings, 0);
}


VALUE rgeo_geos_polygons_eql(GEOSContextHandle_t context, const GEOSGeometry* geom1, const GEOSGeometry* geom2, char check_z)
{
  VALUE result;
  int len1;
  int len2;
  int i;

  result = Qnil;
  if (geom1 && geom2) {
    result = rgeo_geos_coordseqs_eql(context, GEOSGetExteriorRing_r(context, geom1), GEOSGetExteriorRing_r(context, geom2), check_z);
    if (RTEST(result)) {
      len1 = GEOSGetNumInteriorRings_r(context, geom1);
      len2 = GEOSGetNumInteriorRings_r(context, geom2);
      if (len1 >= 0 && len2 >= 0) {
        if (len1 == len2) {
          for (i=0; i<len1; ++i) {
            result = rgeo_geos_coordseqs_eql(context, GEOSGetInteriorRingN_r(context, geom1, i), GEOSGetInteriorRingN_r(context, geom2, i), check_z);
            if (!RTEST(result)) {
              break;
            }
          }
        }
        else {
          result = Qfalse;
        }
      }
      else {
        result = Qnil;
      }
    }
  }
  return result;
}


RGEO_END_C

#endif
