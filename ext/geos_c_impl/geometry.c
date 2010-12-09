/*
  -----------------------------------------------------------------------------
  
  Geometry base class methods for GEOS wrapper
  
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

RGEO_BEGIN_C


/**** INTERNAL UTILITY FUNCTIONS ****/


// Determine the dimension of the given geometry. Empty collections have dimension -1.
// Recursively checks collection elemenets.

static int compute_dimension(GEOSContextHandle_t context, const GEOSGeometry* geom)
{
  int result = -1;
  int size, i;
  if (geom) {
    switch (GEOSGeomTypeId_r(context, geom)) {
    case GEOS_POINT:
      result = 0;
      break;
    case GEOS_MULTIPOINT:
      if (!GEOSisEmpty_r(context, geom)) {
        result = 0;
      }
      break;
    case GEOS_LINESTRING:
    case GEOS_LINEARRING:
      result = 1;
      break;
    case GEOS_MULTILINESTRING:
      if (!GEOSisEmpty_r(context, geom)) {
        result = 1;
      }
      break;
    case GEOS_POLYGON:
      result = 2;
      break;
    case GEOS_MULTIPOLYGON:
      if (!GEOSisEmpty_r(context, geom)) {
        result = 2;
      }
      break;
    case GEOS_GEOMETRYCOLLECTION:
      size = GEOSGetNumGeometries_r(context, geom);
      for (i=0; i<size; ++i) {
        int dim = compute_dimension(context, GEOSGetGeometryN_r(context, geom, i));
        if (dim > result) {
          result = dim;
        }
      }
      break;
    }
  }
  return result;
}


/**** RUBY METHOD DEFINITIONS ****/


static VALUE method_geometry_initialized_p(VALUE self)
{
  return RGEO_GEOMETRY_DATA_PTR(self)->geom ? Qtrue : Qfalse;
}


static VALUE method_geometry_factory(VALUE self)
{
  return RGEO_GEOMETRY_DATA_PTR(self)->factory;
}


static VALUE method_geometry_set_factory(VALUE self, VALUE factory)
{
  RGEO_GEOMETRY_DATA_PTR(self)->factory = factory;
  return factory;
}


static VALUE method_geometry_dimension(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    result = INT2NUM(compute_dimension(self_data->geos_context, self_geom));
  }
  return result;
}


static VALUE method_geometry_geometry_type(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    result = RGEO_FACTORY_DATA_PTR(self_data->factory)->globals->feature_geometry;
  }
  return result;
}


static VALUE method_geometry_srid(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    result = INT2NUM(GEOSGetSRID_r(self_data->geos_context, self_geom));
  }
  return result;
}


static VALUE method_geometry_envelope(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    GEOSContextHandle_t geos_context = self_data->geos_context;
    GEOSGeometry* envelope = GEOSEnvelope_r(geos_context, self_geom);
    // GEOS returns an "empty" point for an empty collection's envelope.
    // We don't allow that type, so we replace it with an empty collection.
    if (!envelope ||
        GEOSGeomTypeId_r(geos_context, envelope) == GEOS_POINT &&
        GEOSGetNumCoordinates_r(geos_context, envelope) == 0) {
      if (envelope) {
        GEOSGeom_destroy_r(geos_context, envelope);
      }
      envelope = GEOSGeom_createCollection_r(geos_context, GEOS_GEOMETRYCOLLECTION, NULL, 0);
    }
    result = rgeo_wrap_geos_geometry(self_data->factory, envelope, Qnil);
  }
  return result;
}


static VALUE method_geometry_boundary(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    GEOSContextHandle_t geos_context = self_data->geos_context;
    GEOSGeometry* boundary = GEOSBoundary_r(geos_context, self_geom);
    // GEOS returns NULL for the boundary of an empty collection.
    // Replace that with an empty collection.
    if (!boundary) {
      boundary = GEOSGeom_createCollection_r(geos_context, GEOS_GEOMETRYCOLLECTION, NULL, 0);
    }
    result = rgeo_wrap_geos_geometry(self_data->factory, boundary, Qnil);
  }
  return result;
}


static VALUE method_geometry_as_text(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    RGeo_FactoryData* factory_data = RGEO_FACTORY_DATA_PTR(self_data->factory);
    GEOSWKTWriter* wkt_writer = factory_data->wkt_writer;
    GEOSContextHandle_t geos_context = self_data->geos_context;
    if (!wkt_writer) {
      wkt_writer = GEOSWKTWriter_create_r(geos_context);
      factory_data->wkt_writer = wkt_writer;
    }
    char* str = GEOSWKTWriter_write_r(geos_context, wkt_writer, self_geom);
    if (str) {
      result = rb_str_new2(str);
      GEOSFree_r(geos_context, str);
    }
  }
  return result;
}


static VALUE method_geometry_as_binary(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    RGeo_FactoryData* factory_data = RGEO_FACTORY_DATA_PTR(self_data->factory);
    GEOSWKBWriter* wkb_writer = factory_data->wkb_writer;
    GEOSContextHandle_t geos_context = self_data->geos_context;
    if (!wkb_writer) {
      wkb_writer = GEOSWKBWriter_create_r(geos_context);
      factory_data->wkb_writer = wkb_writer;
    }
    size_t size;
    char* str = (char*)GEOSWKBWriter_write_r(geos_context, wkb_writer, self_geom, &size);
    if (str) {
      result = rb_str_new(str, size);
      GEOSFree_r(geos_context, str);
    }
  }
  return result;
}


static VALUE method_geometry_is_empty(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    char val = GEOSisEmpty_r(self_data->geos_context, self_geom);
    if (val == 0) {
      result = Qfalse;
    }
    else if (val == 1) {
      result = Qtrue;
    }
  }
  return result;
}


static VALUE method_geometry_is_simple(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    char val = GEOSisSimple_r(self_data->geos_context, self_geom);
    if (val == 0) {
      result = Qfalse;
    }
    else if (val == 1) {
      result = Qtrue;
    }
  }
  return result;
}


static VALUE method_geometry_equals(VALUE self, VALUE rhs)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    const GEOSGeometry* rhs_geom = rgeo_get_geos_geometry_safe(rhs);
    if (rhs_geom) {
      GEOSContextHandle_t self_context = self_data->geos_context;
      // GEOS has a bug where empty geometries are not spatially equal
      // to each other. Work around this case first.
      if (GEOSisEmpty_r(self_context, self_geom) == 1 &&
          GEOSisEmpty_r(RGEO_GEOMETRY_DATA_PTR(rhs)->geos_context, rhs_geom) == 1) {
        result = Qtrue;
      }
      else {
        char val = GEOSEquals_r(self_context, self_geom, rhs_geom);
        if (val == 0) {
          result = Qfalse;
        }
        else if (val == 1) {
          result = Qtrue;
        }
      }
    }
  }
  return result;
}


static VALUE method_geometry_eql(VALUE self, VALUE rhs)
{
  // This should be overridden by the subclass.
  return self == rhs ? Qtrue : Qfalse;
}


static VALUE method_geometry_disjoint(VALUE self, VALUE rhs)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    const GEOSGeometry* rhs_geom = rgeo_convert_to_geos_geometry(self_data->factory, rhs, Qnil);
    if (rhs_geom) {
      char val = GEOSDisjoint_r(self_data->geos_context, self_geom, rhs_geom);
      if (val == 0) {
        result = Qfalse;
      }
      else if (val == 1) {
        result = Qtrue;
      }
    }
  }
  return result;
}


static VALUE method_geometry_intersects(VALUE self, VALUE rhs)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    const GEOSGeometry* rhs_geom = rgeo_convert_to_geos_geometry(self_data->factory, rhs, Qnil);
    if (rhs_geom) {
      char val = GEOSIntersects_r(self_data->geos_context, self_geom, rhs_geom);
      if (val == 0) {
        result = Qfalse;
      }
      else if (val == 1) {
        result = Qtrue;
      }
    }
  }
  return result;
}


static VALUE method_geometry_touches(VALUE self, VALUE rhs)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    const GEOSGeometry* rhs_geom = rgeo_convert_to_geos_geometry(self_data->factory, rhs, Qnil);
    if (rhs_geom) {
      char val = GEOSTouches_r(self_data->geos_context, self_geom, rhs_geom);
      if (val == 0) {
        result = Qfalse;
      }
      else if (val == 1) {
        result = Qtrue;
      }
    }
  }
  return result;
}


static VALUE method_geometry_crosses(VALUE self, VALUE rhs)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    const GEOSGeometry* rhs_geom = rgeo_convert_to_geos_geometry(self_data->factory, rhs, Qnil);
    if (rhs_geom) {
      char val = GEOSCrosses_r(self_data->geos_context, self_geom, rhs_geom);
      if (val == 0) {
        result = Qfalse;
      }
      else if (val == 1) {
        result = Qtrue;
      }
    }
  }
  return result;
}


static VALUE method_geometry_within(VALUE self, VALUE rhs)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    const GEOSGeometry* rhs_geom = rgeo_convert_to_geos_geometry(self_data->factory, rhs, Qnil);
    if (rhs_geom) {
      char val = GEOSWithin_r(self_data->geos_context, self_geom, rhs_geom);
      if (val == 0) {
        result = Qfalse;
      }
      else if (val == 1) {
        result = Qtrue;
      }
    }
  }
  return result;
}


static VALUE method_geometry_contains(VALUE self, VALUE rhs)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    const GEOSGeometry* rhs_geom = rgeo_convert_to_geos_geometry(self_data->factory, rhs, Qnil);
    if (rhs_geom) {
      char val = GEOSContains_r(self_data->geos_context, self_geom, rhs_geom);
      if (val == 0) {
        result = Qfalse;
      }
      else if (val == 1) {
        result = Qtrue;
      }
    }
  }
  return result;
}


static VALUE method_geometry_overlaps(VALUE self, VALUE rhs)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    const GEOSGeometry* rhs_geom = rgeo_convert_to_geos_geometry(self_data->factory, rhs, Qnil);
    if (rhs_geom) {
      char val = GEOSOverlaps_r(self_data->geos_context, self_geom, rhs_geom);
      if (val == 0) {
        result = Qfalse;
      }
      else if (val == 1) {
        result = Qtrue;
      }
    }
  }
  return result;
}


static VALUE method_geometry_relate(VALUE self, VALUE rhs, VALUE pattern)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    const GEOSGeometry* rhs_geom = rgeo_convert_to_geos_geometry(self_data->factory, rhs, Qnil);
    if (rhs_geom) {
      char val = GEOSRelatePattern_r(self_data->geos_context, self_geom, rhs_geom, StringValuePtr(pattern));
      if (val == 0) {
        result = Qfalse;
      }
      else if (val == 1) {
        result = Qtrue;
      }
    }
  }
  return result;
}


static VALUE method_geometry_distance(VALUE self, VALUE rhs)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    const GEOSGeometry* rhs_geom = rgeo_convert_to_geos_geometry(self_data->factory, rhs, Qnil);
    if (rhs_geom) {
      double dist;
      if (GEOSDistance_r(self_data->geos_context, self_geom, rhs_geom, &dist)) {
        result = rb_float_new(dist);
      }
    }
  }
  return result;
}


static VALUE method_geometry_buffer(VALUE self, VALUE distance)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    VALUE factory = self_data->factory;
    int resolution = NUM2INT(RGEO_FACTORY_DATA_PTR(factory)->buffer_resolution);
    result = rgeo_wrap_geos_geometry(factory, GEOSBuffer_r(self_data->geos_context, self_geom, rb_num2dbl(distance), resolution), Qnil);
  }
  return result;
}


static VALUE method_geometry_convex_hull(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    result = rgeo_wrap_geos_geometry(self_data->factory, GEOSConvexHull_r(self_data->geos_context, self_geom), Qnil);
  }
  return result;
}


static VALUE method_geometry_intersection(VALUE self, VALUE rhs)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    VALUE factory = self_data->factory;
    const GEOSGeometry* rhs_geom = rgeo_convert_to_geos_geometry(factory, rhs, Qnil);
    if (rhs_geom) {
      result = rgeo_wrap_geos_geometry(factory, GEOSIntersection_r(self_data->geos_context, self_geom, rhs_geom), Qnil);
    }
  }
  return result;
}


static VALUE method_geometry_union(VALUE self, VALUE rhs)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    VALUE factory = self_data->factory;
    const GEOSGeometry* rhs_geom = rgeo_convert_to_geos_geometry(factory, rhs, Qnil);
    if (rhs_geom) {
      result = rgeo_wrap_geos_geometry(factory, GEOSUnion_r(self_data->geos_context, self_geom, rhs_geom), Qnil);
    }
  }
  return result;
}


static VALUE method_geometry_difference(VALUE self, VALUE rhs)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    VALUE factory = self_data->factory;
    const GEOSGeometry* rhs_geom = rgeo_convert_to_geos_geometry(factory, rhs, Qnil);
    if (rhs_geom) {
      result = rgeo_wrap_geos_geometry(factory, GEOSDifference_r(self_data->geos_context, self_geom, rhs_geom), Qnil);
    }
  }
  return result;
}


static VALUE method_geometry_sym_difference(VALUE self, VALUE rhs)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  const GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    VALUE factory = self_data->factory;
    const GEOSGeometry* rhs_geom = rgeo_convert_to_geos_geometry(factory, rhs, Qnil);
    if (rhs_geom) {
      result = rgeo_wrap_geos_geometry(factory, GEOSSymDifference_r(self_data->geos_context, self_geom, rhs_geom), Qnil);
    }
  }
  return result;
}


static VALUE alloc_geometry(VALUE klass)
{
  return rgeo_wrap_geos_geometry(Qnil, NULL, klass);
}


static VALUE method_geometry_initialize_copy(VALUE self, VALUE orig)
{
  // Clear out any existing value
  RGeo_GeometryData* self_data = RGEO_GEOMETRY_DATA_PTR(self);
  GEOSGeometry* self_geom = self_data->geom;
  if (self_geom) {
    GEOSGeom_destroy_r(self_data->geos_context, self_geom);
    self_data->geom = NULL;
    self_data->geos_context = NULL;
    self_data->factory = Qnil;
    self_data->klasses = Qnil;
  }
  
  // Copy value from orig
  const GEOSGeometry* geom = rgeo_get_geos_geometry_safe(orig);
  if (geom) {
    RGeo_GeometryData* orig_data = RGEO_GEOMETRY_DATA_PTR(orig);
    GEOSContextHandle_t orig_context = orig_data->geos_context;
    GEOSGeometry* clone_geom = GEOSGeom_clone_r(orig_context, geom);
    if (clone_geom) {
      GEOSSetSRID_r(orig_context, clone_geom, GEOSGetSRID_r(orig_context, geom));
      self_data->geom = clone_geom;
      self_data->geos_context = orig_context;
      self_data->factory = orig_data->factory;
      self_data->klasses = orig_data->klasses;
    }
  }
  return self;
}


/**** INITIALIZATION FUNCTION ****/


void rgeo_init_geos_geometry(RGeo_Globals* globals)
{
  VALUE geos_geometry_class = rb_define_class_under(globals->geos_module, "GeometryImpl", rb_cObject);
  globals->geos_geometry = geos_geometry_class;
  globals->feature_geometry = rb_const_get_at(globals->feature_module, rb_intern("Geometry"));
  
  rb_define_alloc_func(geos_geometry_class, alloc_geometry);
  rb_define_method(geos_geometry_class, "_set_factory", method_geometry_set_factory, 1);
  rb_define_method(geos_geometry_class, "initialize_copy", method_geometry_initialize_copy, 1);
  rb_define_method(geos_geometry_class, "initialized?", method_geometry_initialized_p, 0);
  rb_define_method(geos_geometry_class, "factory", method_geometry_factory, 0);
  rb_define_method(geos_geometry_class, "dimension", method_geometry_dimension, 0);
  rb_define_method(geos_geometry_class, "geometry_type", method_geometry_geometry_type, 0);
  rb_define_method(geos_geometry_class, "srid", method_geometry_srid, 0);
  rb_define_method(geos_geometry_class, "envelope", method_geometry_envelope, 0);
  rb_define_method(geos_geometry_class, "boundary", method_geometry_boundary, 0);
  rb_define_method(geos_geometry_class, "as_text", method_geometry_as_text, 0);
  rb_define_method(geos_geometry_class, "to_s", method_geometry_as_text, 0);
  rb_define_method(geos_geometry_class, "as_binary", method_geometry_as_binary, 0);
  rb_define_method(geos_geometry_class, "is_empty?", method_geometry_is_empty, 0);
  rb_define_method(geos_geometry_class, "is_simple?", method_geometry_is_simple, 0);
  rb_define_method(geos_geometry_class, "equals?", method_geometry_equals, 1);
  rb_define_method(geos_geometry_class, "==", method_geometry_equals, 1);
  rb_define_method(geos_geometry_class, "eql?", method_geometry_eql, 1);
  rb_define_method(geos_geometry_class, "disjoint?", method_geometry_disjoint, 1);
  rb_define_method(geos_geometry_class, "intersects?", method_geometry_intersects, 1);
  rb_define_method(geos_geometry_class, "touches?", method_geometry_touches, 1);
  rb_define_method(geos_geometry_class, "crosses?", method_geometry_crosses, 1);
  rb_define_method(geos_geometry_class, "within?", method_geometry_within, 1);
  rb_define_method(geos_geometry_class, "contains?", method_geometry_contains, 1);
  rb_define_method(geos_geometry_class, "overlaps?", method_geometry_overlaps, 1);
  rb_define_method(geos_geometry_class, "relate?", method_geometry_relate, 2);
  rb_define_method(geos_geometry_class, "distance", method_geometry_distance, 1);
  rb_define_method(geos_geometry_class, "buffer", method_geometry_buffer, 1);
  rb_define_method(geos_geometry_class, "convex_hull", method_geometry_convex_hull, 0);
  rb_define_method(geos_geometry_class, "intersection", method_geometry_intersection, 1);
  rb_define_method(geos_geometry_class, "*", method_geometry_intersection, 1);
  rb_define_method(geos_geometry_class, "union", method_geometry_union, 1);
  rb_define_method(geos_geometry_class, "+", method_geometry_union, 1);
  rb_define_method(geos_geometry_class, "difference", method_geometry_difference, 1);
  rb_define_method(geos_geometry_class, "-", method_geometry_difference, 1);
  rb_define_method(geos_geometry_class, "sym_difference", method_geometry_sym_difference, 1);
}


RGEO_END_C

#endif
