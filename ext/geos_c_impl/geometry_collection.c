/*
  -----------------------------------------------------------------------------
  
  Geometry collection methods for GEOS wrapper
  
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
#include "geometry_collection.h"

#ifdef __cplusplus
extern "C" {
#if 0
}
#endif
#endif


/**** INTERNAL IMPLEMENTATION OF CREATE ****/


static char compute_collection_klasses_internal(int type, VALUE factory, const GEOSGeometry* geom, VALUE in_klass, VALUE out_klasses)
{
  char good = 1;
  int geom_type = GEOSGeomTypeId_r(RGEO_CONTEXT_FROM_FACTORY(factory), geom);
  if (type == GEOS_MULTIPOINT && geom_type == GEOS_POINT ||
      type == GEOS_MULTILINESTRING && (geom_type == GEOS_LINESTRING || geom_type == GEOS_LINEARRING) ||
      type == GEOS_MULTIPOLYGON && geom_type == GEOS_POLYGON) {
    rb_ary_push(out_klasses, in_klass);
  }
  else if (geom_type == GEOS_GEOMETRYCOLLECTION || type == geom_type) {
    int len = GEOSGetNumGeometries_r(RGEO_CONTEXT_FROM_FACTORY(factory), geom);
    int i;
    for (i=0; i<len; ++i) {
      const GEOSGeometry* sub_geom = GEOSGetGeometryN_r(RGEO_CONTEXT_FROM_FACTORY(factory), geom, i);
      if (sub_geom) {
        VALUE sub_klass = (TYPE(in_klass) == T_ARRAY) ? rb_ary_entry(in_klass, i) : Qnil;
        good = compute_collection_klasses_internal(type, factory, sub_geom, sub_klass, out_klasses);
        if (!good) {
          break;
        }
      }
      else {
        good = 0;
        break;
      }
    }
  }
  else {
    good = 0;
  }
  return good;
}


// This walks through an array of geometry objects, and determines the
// size of the collection that should be built. For straight
// GeometryCollection objects, the size is the same as the length of
// the array. For MultiPoint, MultiLineString, and MultiPolygon, we do
// recursive gathering of any sub-geometries, so the resulting collection
// may have a different length.
// We also build an array of the klasses for the geometries gathered.
// The array is returned. If a problem occurs-- usually a type mismatch
// such as trying to add a LineString to a MultiPoint-- we return Qnil.

static VALUE compute_collection_klasses(int type, VALUE factory, VALUE array)
{
  int len = RARRAY_LEN(array);
  VALUE result = rb_ary_new();
  int i;
  for (i=0; i<len; ++i) {
    VALUE entry = rb_ary_entry(array, i);
    const GEOSGeometry* geom = rgeo_get_geos_geometry_safe(entry);
    if (!geom) {
      result = Qnil;
      break;
    }
    VALUE klass = RGEO_KLASSES_FROM_GEOMETRY(entry);
    if (NIL_P(klass)) {
      klass = CLASS_OF(entry);
    }
    if (type == GEOS_GEOMETRYCOLLECTION) {
      rb_ary_push(result, klass);
    }
    else {
      char good = compute_collection_klasses_internal(type, factory, geom, klass, result);
      if (!good) {
        result = Qnil;
        break;
      }
    }
  }
  return result;
}


static char gather_geometry_collection_internal(int type, VALUE factory, GEOSGeometry** geoms, int* ci, const GEOSGeometry* geom, char geom_mine)
{
  char good = 1;
  int geom_type = GEOSGeomTypeId_r(RGEO_CONTEXT_FROM_FACTORY(factory), geom);
  if (type != GEOS_GEOMETRYCOLLECTION && (geom_type == GEOS_GEOMETRYCOLLECTION || geom_type == type)) {
    int len = GEOSGetNumGeometries_r(RGEO_CONTEXT_FROM_FACTORY(factory), geom);
    int i;
    for (i=0; i<len; ++i) {
      const GEOSGeometry* sub_geom = GEOSGetGeometryN_r(RGEO_CONTEXT_FROM_FACTORY(factory), geom, i);
      if (sub_geom) {
        good = gather_geometry_collection_internal(type, factory, geoms, ci, sub_geom, 0);
        if (!good) {
          break;
        }
      }
      else {
        good = 0;
        break;
      }
    }
  }
  else {
    geoms[(*ci)++] = geom_mine ? (GEOSGeometry*)geom : GEOSGeom_clone_r(RGEO_CONTEXT_FROM_FACTORY(factory), geom);
  }
  return good;
}


// This walks through the array of geometries and builds a C array of the
// geometries to add to the collection we're building. If we're building
// a simple GeometryCollection, we just gather the geometries as they are.
// If we're building a MultiPoint, MultiLineString, or MultiPolygon, we
// recursively gather the contents of any collections we encounter.

static GEOSGeometry** gather_geometry_collection(int type, VALUE factory, VALUE array, int len)
{
  GEOSGeometry** geoms = ALLOC_N(GEOSGeometry*, len == 0 ? 1 : len);
  int ci = 0;
  if (geoms) {
    int array_len = RARRAY_LEN(array);
    int ai;
    for (ai=0; ai<array_len; ++ai) {
      GEOSGeometry* geom = rgeo_convert_to_detached_geos_geometry(RGEO_GLOBALS_FROM_FACTORY(factory), rb_ary_entry(array, ai), NULL);
      if (geom) {
        if (!gather_geometry_collection_internal(type, factory, geoms, &ci, geom, 1)) {
          break;
        }
      }
      else {
        break;
      }
    }
  }
  if (ci != len) {
    int i;
    for (i=0; i<ci; ++i) {
      GEOSGeom_destroy_r(RGEO_CONTEXT_FROM_FACTORY(factory), geoms[i]);
    }
    free(geoms);
    geoms = NULL;
  }
  return geoms;
}


// Main implementation of the "create" class method for geometry collections.
// You must pass in the correct GEOS geometry type ID.

static VALUE create_geometry_collection(VALUE module, int type, VALUE factory, VALUE array)
{
  VALUE result = Qnil;
  Check_Type(array, T_ARRAY);
  // First pass: we determine the size of the collection to create, and
  // build the klasses array.
  VALUE klasses = compute_collection_klasses(type, factory, array);
  if (!NIL_P(klasses)) {
    int len = RARRAY_LEN(klasses);
    // Second pass: we gather the actual geometries into a C array
    GEOSGeometry** geoms = gather_geometry_collection(type, factory, array, len);
    if (geoms) {
      // Create the collection itself.
      GEOSGeometry* collection = GEOSGeom_createCollection_r(RGEO_CONTEXT_FROM_FACTORY(factory), type, geoms, len);
      // Due to a limitation of GEOS, the MultiPolygon assertions are not checked.
      // We do that manually here.
      if (collection && type == GEOS_MULTIPOLYGON && (RGEO_FACTORY_DATA_PTR(factory)->flags & 1) == 0) {
        char problem = 0;
        int i, j;
        for (i=1; i<len; ++i) {
          for (j=0; j<i; ++j) {
            GEOSGeometry* igeom = geoms[i];
            GEOSGeometry* jgeom = geoms[j];
            problem = GEOSRelatePattern_r(RGEO_CONTEXT_FROM_FACTORY(factory), igeom, jgeom, "2********");
            if (problem) {
              break;
            }
            problem = GEOSRelatePattern_r(RGEO_CONTEXT_FROM_FACTORY(factory), igeom, jgeom, "****1****");
            if (problem) {
              break;
            }
          }
          if (problem) {
            break;
          }
        }
        if (problem) {
          GEOSGeom_destroy_r(RGEO_CONTEXT_FROM_FACTORY(factory), collection);
          collection = NULL;
        }
      }
      if (collection) {
        result = rgeo_wrap_geos_geometry(factory, collection, module);
        RGEO_GEOMETRY_DATA_PTR(result)->klasses = klasses;
      }
      // NOTE: We are assuming that GEOS will do its own cleanup of the
      // element geometries if it fails to create the collection, so we
      // are not doing that ourselves. If that turns out not to be the
      // case, this will be a memory leak.
      free(geoms);
    }
  }
  return result;
}


/**** RUBY METHOD DEFINITIONS ****/


static VALUE method_geometry_collection_eql(VALUE self, VALUE rhs)
{
  VALUE result = rgeo_geos_klasses_and_factories_eql(self, rhs);
  if (RTEST(result)) {
    result = rgeo_geos_geometry_collections_eql(RGEO_CONTEXT_FROM_GEOMETRY(self), RGEO_GET_GEOS_GEOMETRY(self), RGEO_GET_GEOS_GEOMETRY(rhs));
  }
  return result;
}


static VALUE method_geometry_collection_geometry_type(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    result = rb_const_get_at(RGEO_GLOBALS_FROM_GEOMETRY(self)->features_module, rb_intern("GeometryCollection"));
  }
  return result;
}


static VALUE method_geometry_collection_num_geometries(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    result = INT2NUM(GEOSGetNumGeometries_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom));
  }
  return result;
}


static VALUE method_geometry_collection_geometry_n(VALUE self, VALUE n)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    VALUE klasses = RGEO_KLASSES_FROM_GEOMETRY(self);
    int i = NUM2INT(n);
    const GEOSGeometry* elem_geom = GEOSGetGeometryN_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom, i);
    result = rgeo_wrap_geos_geometry_clone(RGEO_FACTORY_FROM_GEOMETRY(self), elem_geom, NIL_P(klasses) ? Qnil : rb_ary_entry(klasses, i));
  }
  return result;
}


static VALUE method_geometry_collection_each(VALUE self)
{
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    int len = GEOSGetNumGeometries_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom);
    if (len > 0) {
      VALUE klasses = RGEO_KLASSES_FROM_GEOMETRY(self);
      int i;
      for (i=0; i<len; ++i) {
        VALUE elem;
        const GEOSGeometry* elem_geom = GEOSGetGeometryN_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom, i);
        elem = rgeo_wrap_geos_geometry_clone(RGEO_FACTORY_FROM_GEOMETRY(self), elem_geom, NIL_P(klasses) ? Qnil : rb_ary_entry(klasses, i));
        if (!NIL_P(elem)) {
          rb_yield(elem);
        }
      }
    }
  }
  return self;
}


static VALUE method_multi_point_geometry_type(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    result = rb_const_get_at(RGEO_GLOBALS_FROM_GEOMETRY(self)->features_module, rb_intern("MultiPoint"));
  }
  return result;
}


static VALUE method_multi_line_string_geometry_type(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    result = rb_const_get_at(RGEO_GLOBALS_FROM_GEOMETRY(self)->features_module, rb_intern("MultiLineString"));
  }
  return result;
}


static VALUE method_multi_line_string_length(VALUE self)
{
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  VALUE result = Qnil;
  if (self_geom) {
    double len;
    if (GEOSLength_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom, &len)) {
      result = rb_float_new(len);
    }
  }
  return result;
}


static VALUE method_multi_line_string_is_closed(VALUE self)
{
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  VALUE result = Qnil;
  if (self_geom) {
    result = Qtrue;
    int len = GEOSGetNumGeometries_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom);
    if (len > 0) {
      int i;
      for (i=0; i<len; ++i) {
        const GEOSGeometry* geom = GEOSGetGeometryN_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom, i);
        if (geom) {
          result = rgeo_is_geos_line_string_closed(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom);
          if (result != Qtrue) {
            break;
          }
        }
      }
    }
  }
  return result;
}


static VALUE method_multi_polygon_geometry_type(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    result = rb_const_get_at(RGEO_GLOBALS_FROM_GEOMETRY(self)->features_module, rb_intern("MultiPolygon"));
  }
  return result;
}


static VALUE method_multi_polygon_area(VALUE self)
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


static VALUE method_multi_polygon_centroid(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    result = rgeo_wrap_geos_geometry(RGEO_FACTORY_FROM_GEOMETRY(self), GEOSGetCentroid_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom), Qnil);
  }
  return result;
}


static VALUE method_multi_polygon_point_on_surface(VALUE self)
{
  VALUE result = Qnil;
  const GEOSGeometry* self_geom = RGEO_GET_GEOS_GEOMETRY(self);
  if (self_geom) {
    result = rgeo_wrap_geos_geometry(RGEO_FACTORY_FROM_GEOMETRY(self), GEOSPointOnSurface_r(RGEO_CONTEXT_FROM_GEOMETRY(self), self_geom), Qnil);
  }
  return result;
}


static VALUE cmethod_geometry_collection_create(VALUE module, VALUE factory, VALUE array)
{
  return create_geometry_collection(module, GEOS_GEOMETRYCOLLECTION, factory, array);
}


static VALUE cmethod_multi_point_create(VALUE module, VALUE factory, VALUE array)
{
  return create_geometry_collection(module, GEOS_MULTIPOINT, factory, array);
}


static VALUE cmethod_multi_line_string_create(VALUE module, VALUE factory, VALUE array)
{
  return create_geometry_collection(module, GEOS_MULTILINESTRING, factory, array);
}


static VALUE cmethod_multi_polygon_create(VALUE module, VALUE factory, VALUE array)
{
  return create_geometry_collection(module, GEOS_MULTIPOLYGON, factory, array);
}


/**** INITIALIZATION FUNCTION ****/


void rgeo_init_geos_geometry_collection(RGeo_Globals* globals)
{
  // Create implementation classes
  VALUE geos_geometry_collection_class = rb_define_class_under(globals->geos_module, "GeometryCollectionImpl", rb_const_get_at(globals->geos_module, rb_intern("GeometryImpl")));
  VALUE geos_multi_point_class = rb_define_class_under(globals->geos_module, "MultiPointImpl", geos_geometry_collection_class);
  VALUE geos_multi_line_string_class = rb_define_class_under(globals->geos_module, "MultiLineStringImpl", geos_geometry_collection_class);
  VALUE geos_multi_polygon_class = rb_define_class_under(globals->geos_module, "MultiPolygonImpl", geos_geometry_collection_class);
  
  // Methods for GeometryCollectionImpl
  rb_define_module_function(geos_geometry_collection_class, "create", cmethod_geometry_collection_create, 2);
  rb_include_module(geos_geometry_collection_class, rb_define_module("Enumerable"));
  rb_define_method(geos_geometry_collection_class, "eql?", method_geometry_collection_eql, 1);
  rb_define_method(geos_geometry_collection_class, "geometry_type", method_geometry_collection_geometry_type, 0);
  rb_define_method(geos_geometry_collection_class, "num_geometries", method_geometry_collection_num_geometries, 0);
  rb_define_method(geos_geometry_collection_class, "size", method_geometry_collection_num_geometries, 0);
  rb_define_method(geos_geometry_collection_class, "geometry_n", method_geometry_collection_geometry_n, 1);
  rb_define_method(geos_geometry_collection_class, "[]", method_geometry_collection_geometry_n, 1);
  rb_define_method(geos_geometry_collection_class, "each", method_geometry_collection_each, 0);
  
  // Methods for MultiPointImpl
  rb_define_module_function(geos_multi_point_class, "create", cmethod_multi_point_create, 2);
  rb_define_method(geos_multi_point_class, "geometry_type", method_multi_point_geometry_type, 0);
  
  // Methods for MultiLineStringImpl
  rb_define_module_function(geos_multi_line_string_class, "create", cmethod_multi_line_string_create, 2);
  rb_define_method(geos_multi_line_string_class, "geometry_type", method_multi_line_string_geometry_type, 0);
  rb_define_method(geos_multi_line_string_class, "length", method_multi_line_string_length, 0);
  rb_define_method(geos_multi_line_string_class, "is_closed?", method_multi_line_string_is_closed, 0);
  
  // Methods for MultiPolygonImpl
  rb_define_module_function(geos_multi_polygon_class, "create", cmethod_multi_polygon_create, 2);
  rb_define_method(geos_multi_polygon_class, "geometry_type", method_multi_polygon_geometry_type, 0);
  rb_define_method(geos_multi_polygon_class, "area", method_multi_polygon_area, 0);
  rb_define_method(geos_multi_polygon_class, "centroid", method_multi_polygon_centroid, 0);
  rb_define_method(geos_multi_polygon_class, "point_on_surface", method_multi_polygon_point_on_surface, 0);
}


/**** OTHER PUBLIC FUNCTIONS ****/


VALUE rgeo_geos_geometry_collections_eql(GEOSContextHandle_t context, const GEOSGeometry* geom1, const GEOSGeometry* geom2)
{
  VALUE result = Qnil;
  if (geom1 && geom2) {
    int len1 = GEOSGetNumGeometries_r(context, geom1);
    int len2 = GEOSGetNumGeometries_r(context, geom2);
    if (len1 >= 0 && len2 >= 0) {
      if (len1 == len2) {
        result = Qtrue;
        int i;
        for (i=0; i<len1; ++i) {
          const GEOSGeometry* sub_geom1 = GEOSGetGeometryN_r(context, geom1, i);
          const GEOSGeometry* sub_geom2 = GEOSGetGeometryN_r(context, geom2, i);
          if (sub_geom1 && sub_geom2) {
            int type1 = GEOSGeomTypeId_r(context, sub_geom1);
            int type2 = GEOSGeomTypeId_r(context, sub_geom2);
            if (type1 >= 0 && type2 >= 0) {
              if (type1 == type2) {
                switch (type1) {
                case GEOS_POINT:
                case GEOS_LINESTRING:
                case GEOS_LINEARRING:
                  result = rgeo_geos_coordseqs_eql(context, sub_geom1, sub_geom2);
                  break;
                case GEOS_POLYGON:
                  result = rgeo_geos_polygons_eql(context, sub_geom1, sub_geom2);
                  break;
                case GEOS_GEOMETRYCOLLECTION:
                case GEOS_MULTIPOINT:
                case GEOS_MULTILINESTRING:
                case GEOS_MULTIPOLYGON:
                  result = rgeo_geos_geometry_collections_eql(context, sub_geom1, sub_geom2);
                  break;
                default:
                  result = Qnil;
                  break;
                }
                if (!RTEST(result)) {
                  break;
                }
              }
              else {
                result = Qfalse;
                break;
              }
            }
            else {
              result = Qnil;
              break;
            }
          }
          else {
            result = Qnil;
            break;
          }
        }
      }
      else {
        result = Qfalse;
      }
    }
  }
  return result;
}


#ifdef __cplusplus
#if 0
{
#endif
}
#endif

#endif
