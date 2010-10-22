/*
  -----------------------------------------------------------------------------
  
  Factory and utility functions for GEOS wrapper
  
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
#include "line_string.h"
#include "polygon.h"
#include "geometry_collection.h"

#ifdef __cplusplus
extern "C" {
#if 0
}
#endif
#endif


/**** RUBY AND GEOS CALLBACKS ****/


// NOP message handler. GEOS requires that a message handler be set
// for every context handle.

static void message_handler(const char* fmt, ...)
{
}


// Destroy function for factory data. We destroy any serialization
// objects that have been created for the factory, and then destroy
// the GEOS context, before freeing the factory data itself.

static void destroy_factory_func(RGeo_FactoryData* data)
{
  if (data->wkt_reader) {
    GEOSWKTReader_destroy_r(data->geos_context, data->wkt_reader);
  }
  if (data->wkb_reader) {
    GEOSWKBReader_destroy_r(data->geos_context, data->wkb_reader);
  }
  if (data->wkt_writer) {
    GEOSWKTWriter_destroy_r(data->geos_context, data->wkt_writer);
  }
  if (data->wkb_writer) {
    GEOSWKBWriter_destroy_r(data->geos_context, data->wkb_writer);
  }
  finishGEOS_r(data->geos_context);
  free(data);
}


// Destroy function for geometry data. We destroy the internal
// GEOS geometry (if present) before freeing the data itself.

static void destroy_geometry_func(RGeo_GeometryData* data)
{
  if (data->geom) {
    GEOSGeom_destroy_r(RGEO_CONTEXT_FROM_FACTORY(data->factory), data->geom);
  }
  free(data);
}


// Mark function for geometry data. This marks the factory and klasses
// held by the geometry so those don't get collected.

static void mark_geometry_func(RGeo_GeometryData* data)
{
  if (!NIL_P(data->factory)) {
    rb_gc_mark(data->factory);
  }
  if (!NIL_P(data->klasses)) {
    rb_gc_mark(data->klasses);
  }
}


// Destroy function for globals data. We don't need to destroy any
// auxiliary data for now...

static void destroy_globals_func(RGeo_Globals* data)
{
  free(data);
}


// Mark function for globals data. This marks the default factory held
// by the globals so it doesn't get collected.

static void mark_globals_func(RGeo_Globals* data)
{
  rb_gc_mark(data->default_factory);
}


/**** RUBY METHOD DEFINITIONS ****/


static VALUE method_factory_srid(VALUE self)
{
  return INT2NUM(RGEO_FACTORY_DATA_PTR(self)->srid);
}


static VALUE method_factory_buffer_resolution(VALUE self)
{
  return INT2NUM(RGEO_FACTORY_DATA_PTR(self)->buffer_resolution);
}


static VALUE method_factory_flags(VALUE self)
{
  return INT2NUM(RGEO_FACTORY_DATA_PTR(self)->flags);
}


static VALUE method_factory_parse_wkt(VALUE self, VALUE str)
{
  Check_Type(str, T_STRING);
  GEOSWKTReader* wkt_reader = RGEO_FACTORY_DATA_PTR(self)->wkt_reader;
  if (!wkt_reader) {
    wkt_reader = GEOSWKTReader_create_r(RGEO_CONTEXT_FROM_FACTORY(self));
    RGEO_FACTORY_DATA_PTR(self)->wkt_reader = wkt_reader;
  }
  VALUE result = Qnil;
  if (wkt_reader) {
    GEOSGeometry* geom = GEOSWKTReader_read_r(RGEO_CONTEXT_FROM_FACTORY(self), wkt_reader, RSTRING_PTR(str));
    if (geom) {
      result = rgeo_wrap_geos_geometry(self, geom, Qnil);
    }
  }
  return result;
}


static VALUE method_factory_parse_wkb(VALUE self, VALUE str)
{
  Check_Type(str, T_STRING);
  GEOSWKBReader* wkb_reader = RGEO_FACTORY_DATA_PTR(self)->wkb_reader;
  if (!wkb_reader) {
    wkb_reader = GEOSWKBReader_create_r(RGEO_CONTEXT_FROM_FACTORY(self));
    RGEO_FACTORY_DATA_PTR(self)->wkb_reader = wkb_reader;
  }
  VALUE result = Qnil;
  if (wkb_reader) {
    GEOSGeometry* geom = GEOSWKBReader_read_r(RGEO_CONTEXT_FROM_FACTORY(self), wkb_reader, (unsigned char*)RSTRING_PTR(str), (size_t)RSTRING_LEN(str));
    if (geom) {
      result = rgeo_wrap_geos_geometry(self, geom, Qnil);
    }
  }
  return result;
}


static VALUE cmethod_factory_create(VALUE klass, VALUE flags, VALUE srid, VALUE buffer_resolution)
{
  VALUE result = Qnil;
  RGeo_FactoryData* data = ALLOC(RGeo_FactoryData);
  if (data) {
    GEOSContextHandle_t context = initGEOS_r(message_handler, message_handler);
    if (context) {
      VALUE wrapped_globals = rb_const_get_at(klass, rb_intern("INTERNAL_CGLOBALS"));
      data->globals = (RGeo_Globals*)DATA_PTR(wrapped_globals);
      data->geos_context = context;
      data->flags = NUM2INT(flags);
      data->srid = NUM2INT(srid);
      data->buffer_resolution = NUM2INT(buffer_resolution);
      data->wkt_reader = NULL;
      data->wkb_reader = NULL;
      data->wkt_writer = NULL;
      data->wkb_writer = NULL;
      result = Data_Wrap_Struct(klass, NULL, destroy_factory_func, data);
    }
    else {
      free(data);
    }
  }
  return result;
}


/**** INITIALIZATION FUNCTION ****/


RGeo_Globals* rgeo_init_geos_factory()
{
  RGeo_Globals* globals = ALLOC(RGeo_Globals);
  VALUE rgeo_module = rb_define_module("RGeo");
  globals->geos_module = rb_define_module_under(rgeo_module, "Geos");
  globals->features_module = rb_define_module_under(rgeo_module, "Features");
  globals->default_factory = Qnil;
  
  // Add C methods to the factory.
  VALUE geos_factory_class = rb_const_get_at(globals->geos_module, rb_intern("Factory"));
  rb_define_method(geos_factory_class, "_parse_wkt_impl", method_factory_parse_wkt, 1);
  rb_define_method(geos_factory_class, "_parse_wkb_impl", method_factory_parse_wkb, 1);
  rb_define_method(geos_factory_class, "_srid", method_factory_srid, 0);
  rb_define_method(geos_factory_class, "_buffer_resolution", method_factory_buffer_resolution, 0);
  rb_define_method(geos_factory_class, "_flags", method_factory_flags, 0);
  rb_define_module_function(geos_factory_class, "_create", cmethod_factory_create, 3);
  
  // Wrap the globals in a Ruby object and store it off so we have access
  // to it later. Each factory instance will reference it internally.
  VALUE wrapped_globals = Data_Wrap_Struct(rb_cObject, mark_globals_func, destroy_globals_func, globals);
  rb_define_const(geos_factory_class, "INTERNAL_CGLOBALS", wrapped_globals);
  
  // Default factory used internally.
  globals->default_factory = rb_funcall(geos_factory_class, rb_intern("create"), 0);
  
  return globals;
}


/**** OTHER PUBLIC FUNCTIONS ****/


VALUE rgeo_wrap_geos_geometry(VALUE factory, GEOSGeometry* geom, VALUE klass)
{
  VALUE result = Qnil;
  if (geom || !NIL_P(klass)) {
    VALUE klasses = Qnil;
    if (TYPE(klass) != T_CLASS) {
      const char* klass_name = NULL;
      char is_collection = 0;
      switch (GEOSGeomTypeId_r(RGEO_CONTEXT_FROM_FACTORY(factory), geom)) {
      case GEOS_POINT:
        klass_name = "PointImpl";
        break;
      case GEOS_LINESTRING:
        klass_name = "LineStringImpl";
        break;
      case GEOS_LINEARRING:
        klass_name = "LinearRingImpl";
        break;
      case GEOS_POLYGON:
        klass_name = "PolygonImpl";
        break;
      case GEOS_MULTIPOINT:
        klass_name = "MultiPointImpl";
        is_collection = 1;
        break;
      case GEOS_MULTILINESTRING:
        klass_name = "MultiLineStringImpl";
        is_collection = 1;
        break;
      case GEOS_MULTIPOLYGON:
        klass_name = "MultiPolygonImpl";
        is_collection = 1;
        break;
      case GEOS_GEOMETRYCOLLECTION:
        klass_name = "GeometryCollectionImpl";
        is_collection = 1;
        break;
      default:
        klass_name = "GeometryImpl";
        break;
      }
      if (TYPE(klass) == T_ARRAY && is_collection) {
        klasses = klass;
      }
      klass = rb_const_get_at(RGEO_GLOBALS_FROM_FACTORY(factory)->geos_module, rb_intern(klass_name));
    }
    RGeo_GeometryData* data = ALLOC(RGeo_GeometryData);
    if (data) {
      if (geom) {
        GEOSSetSRID_r(RGEO_CONTEXT_FROM_FACTORY(factory), geom, RGEO_FACTORY_DATA_PTR(factory)->srid);
      }
      data->geom = geom;
      data->factory = factory;
      data->klasses = klasses;
      result = Data_Wrap_Struct(klass, mark_geometry_func, destroy_geometry_func, data);
    }
  }
  return result;
}


VALUE rgeo_wrap_geos_geometry_clone(VALUE factory, const GEOSGeometry* geom, VALUE klass)
{
  VALUE result = Qnil;
  if (geom) {
    GEOSGeometry* clone_geom = GEOSGeom_clone_r(RGEO_CONTEXT_FROM_FACTORY(factory), geom);
    if (clone_geom) {
      result = rgeo_wrap_geos_geometry(factory, clone_geom, klass);
    }
  }
  return result;
}


const GEOSGeometry* rgeo_convert_to_geos_geometry(VALUE factory, VALUE obj)
{
  VALUE object = rb_funcall(factory, rb_intern("coerce"), 1, obj);
  const GEOSGeometry* geom = NULL;
  if (!NIL_P(object)) {
    geom = RGEO_GET_GEOS_GEOMETRY(object);
  }
  return geom;
}


GEOSGeometry* rgeo_convert_to_detached_geos_geometry(RGeo_Globals* globals, VALUE obj, VALUE* klasses)
{
  if (klasses) {
    *klasses = Qnil;
  }
  VALUE object = rb_funcall(globals->default_factory, rb_intern("coerce"), 2, obj, Qtrue);
  GEOSGeometry* geom = NULL;
  if (!NIL_P(object)) {
    geom = RGEO_GEOMETRY_DATA_PTR(object)->geom;
    RGEO_GEOMETRY_DATA_PTR(object)->geom = NULL;
    RGEO_GEOMETRY_DATA_PTR(object)->factory = Qnil;
    RGEO_GEOMETRY_DATA_PTR(object)->klasses = Qnil;
    if (klasses) {
      *klasses = rgeo_is_geos_object(obj) ? RGEO_KLASSES_FROM_GEOMETRY(obj) : Qnil;
    }
  }
  return geom;
}


char rgeo_is_geos_object(VALUE obj)
{
  return (TYPE(obj) == T_DATA && RDATA(obj)->dfree == (RUBY_DATA_FUNC)destroy_geometry_func) ? 1 : 0;
}


const GEOSGeometry* rgeo_get_geos_geometry_safe(VALUE obj)
{
  return (TYPE(obj) == T_DATA && RDATA(obj)->dfree == (RUBY_DATA_FUNC)destroy_geometry_func) ? RGEO_GET_GEOS_GEOMETRY(obj) : NULL;
}


VALUE rgeo_geos_coordseqs_eql(GEOSContextHandle_t context, const GEOSGeometry* geom1, const GEOSGeometry* geom2)
{
  VALUE result = Qnil;
  if (geom1 && geom2) {
    const GEOSCoordSequence* cs1 = GEOSGeom_getCoordSeq_r(context, geom1);
    const GEOSCoordSequence* cs2 = GEOSGeom_getCoordSeq_r(context, geom2);
    if (cs1 && cs2) {
      char hasz1 = GEOSHasZ_r(context, geom1);
      char hasz2 = GEOSHasZ_r(context, geom2);
      if (hasz1 != 2 && hasz2 != 2) {
        if (hasz1 == hasz2) {
          unsigned int len1 = 0;
          unsigned int len2 = 0;
          if (GEOSCoordSeq_getSize_r(context, cs1, &len1) && GEOSCoordSeq_getSize_r(context, cs2, &len2)) {
            if (len1 == len2) {
              result = Qtrue;
              unsigned int i;
              double val1, val2;
              for (i=0; i<len1; ++i) {
                if (GEOSCoordSeq_getX_r(context, cs1, i, &val1) && GEOSCoordSeq_getX_r(context, cs2, i, &val2)) {
                  if (val1 == val2) {
                    if (GEOSCoordSeq_getY_r(context, cs1, i, &val1) && GEOSCoordSeq_getY_r(context, cs2, i, &val2)) {
                      if (val1 == val2) {
                        if (hasz1) {
                          if (GEOSCoordSeq_getZ_r(context, cs1, i, &val1) && GEOSCoordSeq_getZ_r(context, cs2, i, &val2)) {
                            if (val1 != val2) {
                              result = Qfalse;
                              break;
                            }
                          }
                          else {  // Failed to get Z coords
                            result = Qnil;
                            break;
                          }
                        }
                      }
                      else {  // Y coords are different
                        result = Qfalse;
                        break;
                      }
                    }
                    else {  // Failed to get Y coords
                      result = Qnil;
                      break;
                    }
                  }
                  else {  // X coords are different
                    result = Qfalse;
                    break;
                  }
                }
                else {  // Failed to get X coords
                  result = Qnil;
                  break;
                }
              }  // Iteration over coords
            }
            else {  // Lengths are different
              result = Qfalse;
            }
          }
        }
        else {  // Z coord existence is different
          result = Qfalse;
        }
      }
    }
  }
  return result;
}


VALUE rgeo_geos_klasses_and_factories_eql(VALUE obj1, VALUE obj2)
{
  VALUE result = Qnil;
  if (rb_obj_class(obj1) != rb_obj_class(obj2)) {
    result = Qfalse;
  }
  else {
    result = rb_funcall(RGEO_FACTORY_FROM_GEOMETRY(obj1), rb_intern("eql?"), 1, RGEO_FACTORY_FROM_GEOMETRY(obj2));
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
