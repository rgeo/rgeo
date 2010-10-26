/*
  -----------------------------------------------------------------------------
  
  Polygon methods for GEOS wrapper
  
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
#include "line_string.h"
#include "polygon.h"

RGEO_BEGIN_C


static VALUE method_polygon_eql(VALUE self, VALUE rhs)
{
  VALUE result = rgeo_geos_klasses_and_factories_eql(self, rhs);
  if (RTEST(result)) {
    result = rgeo_geos_polygons_eql(RGEO_CONTEXT_FROM_GEOMETRY(self), RGEO_GET_GEOS_GEOMETRY(self), RGEO_GET_GEOS_GEOMETRY(rhs));
  }
  return result;
}


static VALUE method_polygon_geometry_type(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    result = rb_const_get_at(RGEO_GLOBALS_FROM_GEOMETRY(self)->features_module, rb_intern("Polygon"));
  }
  return result;
}


static VALUE method_polygon_area(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    double area;
    if (GEOSArea_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom, &area)) {
      result = rb_float_new(area);
    }
  }
  return result;
}


static VALUE method_polygon_centroid(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    result = rgeo_wrap_geos_geometry(RGEO_FACTORY_FROM_GEOMETRY(self), GEOSGetCentroid_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom), rb_const_get_at(RGEO_GLOBALS_FROM_GEOMETRY(self)->geos_module, rb_intern("PointImpl")));
  }
  return result;
}


static VALUE method_polygon_point_on_surface(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    result = rgeo_wrap_geos_geometry(RGEO_FACTORY_FROM_GEOMETRY(self), GEOSPointOnSurface_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom), rb_const_get_at(RGEO_GLOBALS_FROM_GEOMETRY(self)->geos_module, rb_intern("PointImpl")));
  }
  return result;
}


static VALUE method_polygon_exterior_ring(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    result = rgeo_wrap_geos_geometry_clone(RGEO_FACTORY_FROM_GEOMETRY(self), GEOSGetExteriorRing_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom), rb_const_get_at(RGEO_GLOBALS_FROM_GEOMETRY(self)->geos_module, rb_intern("LinearRingImpl")));
  }
  return result;
}


static VALUE method_polygon_num_interior_rings(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    int num = GEOSGetNumInteriorRings_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom);
    if (num >= 0) {
      result = INT2NUM(num);
    }
  }
  return result;
}


static VALUE method_polygon_interior_ring_n(VALUE self, VALUE n)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    result = rgeo_wrap_geos_geometry_clone(RGEO_FACTORY_FROM_GEOMETRY(self), GEOSGetInteriorRingN_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom, NUM2INT(n)), rb_const_get_at(RGEO_GLOBALS_FROM_GEOMETRY(self)->geos_module, rb_intern("LinearRingImpl")));
  }
  return result;
}


static VALUE method_polygon_interior_rings(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    int count = GEOSGetNumInteriorRings_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom);
    if (count >= 0) {
      result = rb_ary_new2(count);
      int i;
      for (i=0; i<count; ++i) {
        rb_ary_store(result, i, rgeo_wrap_geos_geometry_clone(RGEO_FACTORY_FROM_GEOMETRY(self), GEOSGetInteriorRingN_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom, i), rb_const_get_at(RGEO_GLOBALS_FROM_GEOMETRY(self)->geos_module, rb_intern("LinearRingImpl"))));
      }
    }
  }
  return result;
}


static VALUE cmethod_create(VALUE module, VALUE factory, VALUE exterior, VALUE interior_array)
{
  Check_Type(interior_array, T_ARRAY);
  VALUE linear_ring_type = rb_const_get_at(RGEO_GLOBALS_FROM_FACTORY(factory)->features_module, rb_intern("LinearRing"));
  GEOSGeometry* exterior_geom = rgeo_convert_to_detached_geos_geometry(RGEO_GLOBALS_FROM_FACTORY(factory), exterior, linear_ring_type, NULL);
  if (exterior_geom) {
    unsigned int len = (unsigned int)RARRAY_LEN(interior_array);
    GEOSGeometry** interior_geoms = ALLOC_N(GEOSGeometry*, len == 0 ? 1 : len);
    if (interior_geoms) {
      unsigned int actual_len = 0;
      unsigned int i;
      for (i=0; i<len; ++i) {
        GEOSGeometry* interior_geom = rgeo_convert_to_detached_geos_geometry(RGEO_GLOBALS_FROM_FACTORY(factory), rb_ary_entry(interior_array, i), linear_ring_type, NULL);
        if (interior_geom) {
          interior_geoms[actual_len++] = interior_geom;
        }
      }
      if (len == actual_len) {
        GEOSGeometry* polygon = GEOSGeom_createPolygon_r(RGEO_CONTEXT_FROM_FACTORY(factory), exterior_geom, interior_geoms, actual_len);
        if (polygon) {
          free(interior_geoms);
          return rgeo_wrap_geos_geometry(factory, polygon, rb_const_get_at(RGEO_GLOBALS_FROM_FACTORY(factory)->geos_module, rb_intern("PolygonImpl")));
        }
      }
      for (i=0; i<actual_len; ++i) {
        GEOSGeom_destroy_r(RGEO_CONTEXT_FROM_FACTORY(factory), interior_geoms[i]);
      }
      free(interior_geoms);
    }
    GEOSGeom_destroy_r(RGEO_CONTEXT_FROM_FACTORY(factory), exterior_geom);
  }
  return Qnil;
}


void rgeo_init_geos_polygon(RGeo_Globals* globals)
{
  VALUE geos_polygon_class = rb_define_class_under(globals->geos_module, "PolygonImpl", rb_const_get_at(globals->geos_module, rb_intern("GeometryImpl")));
  
  rb_define_module_function(geos_polygon_class, "create", cmethod_create, 3);
  
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


VALUE rgeo_geos_polygons_eql(GEOSContextHandle_t context, const GEOSGeometry* geom1, const GEOSGeometry* geom2)
{
  VALUE result = Qnil;
  if (geom1 && geom2) {
    result = rgeo_geos_coordseqs_eql(context, GEOSGetExteriorRing_r(context, geom1), GEOSGetExteriorRing_r(context, geom2));
    if (RTEST(result)) {
      int len1 = GEOSGetNumInteriorRings_r(context, geom1);
      int len2 = GEOSGetNumInteriorRings_r(context, geom2);
      if (len1 >= 0 && len2 >= 0) {
        if (len1 == len2) {
          int i;
          for (i=0; i<len1; ++i) {
            result = rgeo_geos_coordseqs_eql(context, GEOSGetInteriorRingN_r(context, geom1, i), GEOSGetInteriorRingN_r(context, geom2, i));
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
