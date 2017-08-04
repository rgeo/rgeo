/*
  Geometry collection methods for GEOS wrapper
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

#include "coordinates.h"

RGEO_BEGIN_C


/**** INTERNAL IMPLEMENTATION OF CREATE ****/


// Main implementation of the "create" class method for geometry collections.
// You must pass in the correct GEOS geometry type ID.

static VALUE create_geometry_collection(VALUE module, int type, VALUE factory, VALUE array)
{
  VALUE result;
  unsigned int len;
  GEOSGeometry** geoms;
  RGeo_FactoryData* factory_data;
  GEOSContextHandle_t geos_context;
  VALUE klass;
  unsigned int i;
  unsigned int j;
  VALUE klasses;
  VALUE cast_type;
  GEOSGeometry* geom;
  GEOSGeometry* collection;
  char problem;
  GEOSGeometry* igeom;
  GEOSGeometry* jgeom;

  result = Qnil;
  Check_Type(array, T_ARRAY);
  len = (unsigned int)RARRAY_LEN(array);
  geoms = ALLOC_N(GEOSGeometry*, len == 0 ? 1 : len);
  if (geoms) {
    factory_data = RGEO_FACTORY_DATA_PTR(factory);
    geos_context = factory_data->geos_context;
    klasses = Qnil;
    cast_type = Qnil;
    switch (type) {
    case GEOS_MULTIPOINT:
      cast_type = factory_data->globals->feature_point;
      break;
    case GEOS_MULTILINESTRING:
      cast_type = factory_data->globals->feature_line_string;
      break;
    case GEOS_MULTIPOLYGON:
      cast_type = factory_data->globals->feature_polygon;
      break;
    }
    for (i=0; i<len; ++i) {
      geom = rgeo_convert_to_detached_geos_geometry(rb_ary_entry(array, i), factory, cast_type, &klass);
      if (!geom) {
        break;
      }
      geoms[i] = geom;
      if (!NIL_P(klass) && NIL_P(klasses)) {
        klasses = rb_ary_new2(len);
        for (j=0; j<i; ++j) {
          rb_ary_push(klasses, Qnil);
        }
      }
      if (!NIL_P(klasses)) {
        rb_ary_push(klasses, klass);
      }
    }
    if (i != len) {
      for (j=0; j<i; ++j) {
        GEOSGeom_destroy_r(geos_context, geoms[j]);
      }
    }
    else {
      collection = GEOSGeom_createCollection_r(geos_context, type, geoms, len);
      // Due to a limitation of GEOS, the MultiPolygon assertions are not checked.
      // We do that manually here.
      if (collection && type == GEOS_MULTIPOLYGON && (factory_data->flags & 1) == 0) {
        problem = 0;
        for (i=1; i<len; ++i) {
          for (j=0; j<i; ++j) {
            igeom = geoms[i];
            jgeom = geoms[j];
            problem = GEOSRelatePattern_r(geos_context, igeom, jgeom, "2********");
            if (problem) {
              break;
            }
            problem = GEOSRelatePattern_r(geos_context, igeom, jgeom, "****1****");
            if (problem) {
              break;
            }
          }
          if (problem) {
            break;
          }
        }
        if (problem) {
          GEOSGeom_destroy_r(geos_context, collection);
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
    }
    free(geoms);
  }

  return result;
}


/**** RUBY METHOD DEFINITIONS ****/


static VALUE method_geometry_collection_eql(VALUE self, VALUE rhs)
{
  VALUE result;
  RGeo_GeometryData* self_data;

  result = rgeo_geos_klasses_and_factories_eql(self, rhs);
  if (RTEST(result)) {
    self_data = RGEO_GEOMETRY_DATA_PTR(self);
    result = rgeo_geos_geometry_collections_eql(self_data->geos_context, self_data->geom, RGEO_GEOMETRY_DATA_PTR(rhs)->geom, RGEO_FACTORY_DATA_PTR(self_data->factory)->flags & RGEO_FACTORYFLAGS_SUPPORTS_Z_OR_M);
  }
  return result;
}


static VALUE method_geometry_collection_hash(VALUE self)
{
  st_index_t hash;
  RGeo_GeometryData* self_data;
  VALUE factory;

  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  factory = self_data->factory;
  hash = rb_hash_start(0);
  hash = rgeo_geos_objbase_hash(factory,
    RGEO_FACTORY_DATA_PTR(factory)->globals->feature_geometry_collection, hash);
  hash = rgeo_geos_geometry_collection_hash(self_data->geos_context, self_data->geom, hash);
  return LONG2FIX(rb_hash_end(hash));
}


static VALUE method_geometry_collection_geometry_type(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  if (self_data->geom) {
    result = RGEO_FACTORY_DATA_PTR(self_data->factory)->globals->feature_geometry_collection;
  }
  return result;
}


static VALUE method_geometry_collection_num_geometries(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    result = INT2NUM(GEOSGetNumGeometries_r(self_data->geos_context, self_geom));
  }
  return result;
}


static VALUE impl_geometry_n(VALUE self, VALUE n, char allow_negatives)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  VALUE klasses;
  int i;
  int len;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    klasses = self_data->klasses;
    i = NUM2INT(n);
    if (allow_negatives || i >= 0) {
      GEOSContextHandle_t self_context = self_data->geos_context;
      len = GEOSGetNumGeometries_r(self_context, self_geom);
      if (i < 0) {
        i += len;
      }
      if (i >= 0 && i < len) {
        result = rgeo_wrap_geos_geometry_clone(self_data->factory,
          GEOSGetGeometryN_r(self_context, self_geom, i),
          NIL_P(klasses) ? Qnil : rb_ary_entry(klasses, i));
      }
    }
  }
  return result;
}


static VALUE method_geometry_collection_geometry_n(VALUE self, VALUE n)
{
  return impl_geometry_n(self, n, 0);
}


static VALUE method_geometry_collection_brackets(VALUE self, VALUE n)
{
  return impl_geometry_n(self, n, 1);
}


static VALUE method_geometry_collection_each(VALUE self)
{
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  int len;
  VALUE klasses;
  int i;
  VALUE elem;
  const GEOSGeometry* elem_geom;

  self_data = RGEO_GEOMETRY_DATA_PTR(self);

  if (rb_block_given_p()) {
    self_geom = self_data->geom;
    if (self_geom) {
      GEOSContextHandle_t self_context = self_data->geos_context;
      len = GEOSGetNumGeometries_r(self_context, self_geom);
      if (len > 0) {
        klasses = self_data->klasses;
        for (i=0; i<len; ++i) {
          elem_geom = GEOSGetGeometryN_r(self_context, self_geom, i);
          elem = rgeo_wrap_geos_geometry_clone(self_data->factory, elem_geom, NIL_P(klasses) ? Qnil : rb_ary_entry(klasses, i));
          if (!NIL_P(elem)) {
            rb_yield(elem);
          }
        }
      }
    }
    return self;
  }
  else {
    return rb_funcall(self, RGEO_FACTORY_DATA_PTR(self_data->factory)->globals->id_enum_for, 0);
  }
}

static VALUE method_multi_point_geometry_type(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  if (self_data->geom) {
    result = RGEO_FACTORY_DATA_PTR(self_data->factory)->globals->feature_multi_point;
  }
  return result;
}


static VALUE method_multi_point_hash(VALUE self)
{
  st_index_t hash;
  RGeo_GeometryData* self_data;
  VALUE factory;

  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  factory = self_data->factory;
  hash = rb_hash_start(0);
  hash = rgeo_geos_objbase_hash(factory,
    RGEO_FACTORY_DATA_PTR(factory)->globals->feature_multi_point, hash);
  hash = rgeo_geos_geometry_collection_hash(self_data->geos_context, self_data->geom, hash);
  return LONG2FIX(rb_hash_end(hash));
}


static VALUE method_multi_point_coordinates(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  GEOSContextHandle_t context;
  const GEOSCoordSequence* coord_sequence;

  const GEOSGeometry* point;
  unsigned int count;
  unsigned int i;
  int zCoordinate;

  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;

  if(self_geom) {
    zCoordinate = RGEO_FACTORY_DATA_PTR(self_data->factory)->flags & RGEO_FACTORYFLAGS_SUPPORTS_Z_OR_M;
    context = self_data->geos_context;
    count = GEOSGetNumGeometries_r(context, self_geom);
    result = rb_ary_new2(count);
    for(i = 0; i < count; ++i) {
      point = GEOSGetGeometryN_r(context, self_geom, i);
      coord_sequence = GEOSGeom_getCoordSeq_r(context, point);
      rb_ary_push(result, rb_ary_pop(extract_points_from_coordinate_sequence(context, coord_sequence, zCoordinate)));
    }
  }

  return result;
}


static VALUE method_multi_line_string_geometry_type(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  if (self_data->geom) {
    result = RGEO_FACTORY_DATA_PTR(self_data->factory)->globals->feature_multi_line_string;
  }
  return result;
}


static VALUE method_multi_line_string_hash(VALUE self)
{
  st_index_t hash;
  RGeo_GeometryData* self_data;
  VALUE factory;

  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  factory = self_data->factory;
  hash = rb_hash_start(0);
  hash = rgeo_geos_objbase_hash(factory,
    RGEO_FACTORY_DATA_PTR(factory)->globals->feature_multi_line_string, hash);
  hash = rgeo_geos_geometry_collection_hash(self_data->geos_context, self_data->geom, hash);
  return LONG2FIX(rb_hash_end(hash));
}

static VALUE method_geometry_collection_node(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  GEOSGeometry* noded;
  GEOSContextHandle_t context;

  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  context = self_data->geos_context;

  noded = GEOSNode_r(context, self_geom);
  result = rgeo_wrap_geos_geometry(self_data->factory, noded, Qnil);

  return result;
}

static VALUE method_multi_line_string_coordinates(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  GEOSContextHandle_t context;
  const GEOSCoordSequence* coord_sequence;

  const GEOSGeometry* line_string;
  unsigned int count;
  unsigned int i;
  int zCoordinate;

  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  
  if(self_geom) {
    zCoordinate = RGEO_FACTORY_DATA_PTR(self_data->factory)->flags & RGEO_FACTORYFLAGS_SUPPORTS_Z_OR_M;
    context = self_data->geos_context;
    count = GEOSGetNumGeometries_r(context, self_geom);
    result = rb_ary_new2(count);
    for(i = 0; i < count; ++i) {
      line_string = GEOSGetGeometryN_r(context, self_geom, i);
      coord_sequence = GEOSGeom_getCoordSeq_r(context, line_string);
      rb_ary_push(result, extract_points_from_coordinate_sequence(context, coord_sequence, zCoordinate));
    }
  }

  return result;
}

static VALUE method_multi_line_string_length(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  double len;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    if (GEOSLength_r(self_data->geos_context, self_geom, &len)) {
      result = rb_float_new(len);
    }
  }
  return result;
}


static VALUE method_multi_line_string_is_closed(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  GEOSContextHandle_t self_context;
  int len;
  int i;
  const GEOSGeometry* geom;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    self_context = self_data->geos_context;
    result = Qtrue;
    len = GEOSGetNumGeometries_r(self_context, self_geom);
    if (len > 0) {
      for (i=0; i<len; ++i) {
        geom = GEOSGetGeometryN_r(self_context, self_geom, i);
        if (geom) {
          result = rgeo_is_geos_line_string_closed(self_context, self_geom);
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
  VALUE result;
  RGeo_GeometryData* self_data;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  if (self_data->geom) {
    result = RGEO_FACTORY_DATA_PTR(self_data->factory)->globals->feature_multi_polygon;
  }
  return result;
}


static VALUE method_multi_polygon_hash(VALUE self)
{
  st_index_t hash;
  RGeo_GeometryData* self_data;
  VALUE factory;

  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  factory = self_data->factory;
  hash = rb_hash_start(0);
  hash = rgeo_geos_objbase_hash(factory,
    RGEO_FACTORY_DATA_PTR(factory)->globals->feature_multi_polygon, hash);
  hash = rgeo_geos_geometry_collection_hash(self_data->geos_context, self_data->geom, hash);
  return LONG2FIX(rb_hash_end(hash));
}


static VALUE method_multi_polygon_coordinates(VALUE self)
{
  VALUE result = Qnil;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  GEOSContextHandle_t context;

  const GEOSGeometry* poly;
  unsigned int count;
  unsigned int i;
  int zCoordinate;

  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  
  if(self_geom) {
    zCoordinate = RGEO_FACTORY_DATA_PTR(self_data->factory)->flags & RGEO_FACTORYFLAGS_SUPPORTS_Z_OR_M;
    context = self_data->geos_context;
    count = GEOSGetNumGeometries_r(context, self_geom);
    result = rb_ary_new2(count);
    for(i = 0; i < count; ++i) {
      poly = GEOSGetGeometryN_r(context, self_geom, i);
      rb_ary_push(result, extract_points_from_polygon(context, poly, zCoordinate));
    }
  }

  return result;
}


static VALUE method_multi_polygon_area(VALUE self)
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


static VALUE method_multi_polygon_centroid(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    result = rgeo_wrap_geos_geometry(self_data->factory, GEOSGetCentroid_r(self_data->geos_context, self_geom), Qnil);
  }
  return result;
}


static VALUE method_multi_polygon_point_on_surface(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    result = rgeo_wrap_geos_geometry(self_data->factory, GEOSPointOnSurface_r(self_data->geos_context, self_geom), Qnil);
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
  VALUE geos_geometry_collection_methods;
  VALUE geos_multi_point_methods;
  VALUE geos_multi_line_string_methods;
  VALUE geos_multi_polygon_methods;

  // Class methods for geometry collection classes
  rb_define_module_function(globals->geos_geometry_collection, "create", cmethod_geometry_collection_create, 2);
  rb_define_module_function(globals->geos_multi_point, "create", cmethod_multi_point_create, 2);
  rb_define_module_function(globals->geos_multi_line_string, "create", cmethod_multi_line_string_create, 2);
  rb_define_module_function(globals->geos_multi_polygon, "create", cmethod_multi_polygon_create, 2);

  // Methods for GeometryCollectionImpl
  geos_geometry_collection_methods = rb_define_module_under(globals->geos_module, "CAPIGeometryCollectionMethods");
  rb_define_method(geos_geometry_collection_methods, "rep_equals?", method_geometry_collection_eql, 1);
  rb_define_method(geos_geometry_collection_methods, "eql?", method_geometry_collection_eql, 1);
  rb_define_method(geos_geometry_collection_methods, "hash", method_geometry_collection_hash, 0);
  rb_define_method(geos_geometry_collection_methods, "geometry_type", method_geometry_collection_geometry_type, 0);
  rb_define_method(geos_geometry_collection_methods, "num_geometries", method_geometry_collection_num_geometries, 0);
  rb_define_method(geos_geometry_collection_methods, "size", method_geometry_collection_num_geometries, 0);
  rb_define_method(geos_geometry_collection_methods, "geometry_n", method_geometry_collection_geometry_n, 1);
  rb_define_method(geos_geometry_collection_methods, "[]", method_geometry_collection_brackets, 1);
  rb_define_method(geos_geometry_collection_methods, "each", method_geometry_collection_each, 0);
  rb_define_method(geos_geometry_collection_methods, "node", method_geometry_collection_node, 0);


  // Methods for MultiPointImpl
  geos_multi_point_methods = rb_define_module_under(globals->geos_module, "CAPIMultiPointMethods");
  rb_define_method(geos_multi_point_methods, "geometry_type", method_multi_point_geometry_type, 0);
  rb_define_method(geos_multi_point_methods, "hash", method_multi_point_hash, 0);
  rb_define_method(geos_multi_point_methods, "coordinates", method_multi_point_coordinates, 0);

  // Methods for MultiLineStringImpl
  geos_multi_line_string_methods = rb_define_module_under(globals->geos_module, "CAPIMultiLineStringMethods");
  rb_define_method(geos_multi_line_string_methods, "geometry_type", method_multi_line_string_geometry_type, 0);
  rb_define_method(geos_multi_line_string_methods, "length", method_multi_line_string_length, 0);
  rb_define_method(geos_multi_line_string_methods, "is_closed?", method_multi_line_string_is_closed, 0);
  rb_define_method(geos_multi_line_string_methods, "hash", method_multi_line_string_hash, 0);
  rb_define_method(geos_multi_line_string_methods, "coordinates", method_multi_line_string_coordinates, 0);

  // Methods for MultiPolygonImpl
  geos_multi_polygon_methods = rb_define_module_under(globals->geos_module, "CAPIMultiPolygonMethods");
  rb_define_method(geos_multi_polygon_methods, "geometry_type", method_multi_polygon_geometry_type, 0);
  rb_define_method(geos_multi_polygon_methods, "area", method_multi_polygon_area, 0);
  rb_define_method(geos_multi_polygon_methods, "centroid", method_multi_polygon_centroid, 0);
  rb_define_method(geos_multi_polygon_methods, "point_on_surface", method_multi_polygon_point_on_surface, 0);
  rb_define_method(geos_multi_polygon_methods, "hash", method_multi_polygon_hash, 0);
  rb_define_method(geos_multi_polygon_methods, "coordinates", method_multi_polygon_coordinates, 0);
}


/**** OTHER PUBLIC FUNCTIONS ****/


VALUE rgeo_geos_geometry_collections_eql(GEOSContextHandle_t context, const GEOSGeometry* geom1, const GEOSGeometry* geom2, char check_z)
{
  VALUE result;
  int len1;
  int len2;
  int i;
  const GEOSGeometry* sub_geom1;
  const GEOSGeometry* sub_geom2;
  int type1;
  int type2;

  result = Qnil;
  if (geom1 && geom2) {
    len1 = GEOSGetNumGeometries_r(context, geom1);
    len2 = GEOSGetNumGeometries_r(context, geom2);
    if (len1 >= 0 && len2 >= 0) {
      if (len1 == len2) {
        result = Qtrue;
        for (i=0; i<len1; ++i) {
          sub_geom1 = GEOSGetGeometryN_r(context, geom1, i);
          sub_geom2 = GEOSGetGeometryN_r(context, geom2, i);
          if (sub_geom1 && sub_geom2) {
            type1 = GEOSGeomTypeId_r(context, sub_geom1);
            type2 = GEOSGeomTypeId_r(context, sub_geom2);
            if (type1 >= 0 && type2 >= 0) {
              if (type1 == type2) {
                switch (type1) {
                case GEOS_POINT:
                case GEOS_LINESTRING:
                case GEOS_LINEARRING:
                  result = rgeo_geos_coordseqs_eql(context, sub_geom1, sub_geom2, check_z);
                  break;
                case GEOS_POLYGON:
                  result = rgeo_geos_polygons_eql(context, sub_geom1, sub_geom2, check_z);
                  break;
                case GEOS_GEOMETRYCOLLECTION:
                case GEOS_MULTIPOINT:
                case GEOS_MULTILINESTRING:
                case GEOS_MULTIPOLYGON:
                  result = rgeo_geos_geometry_collections_eql(context, sub_geom1, sub_geom2, check_z);
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


st_index_t rgeo_geos_geometry_collection_hash(GEOSContextHandle_t context, const GEOSGeometry* geom, st_index_t hash)
{
  const GEOSGeometry* sub_geom;
  int type;
  unsigned int len;
  unsigned int i;

  if (geom) {
    len = GEOSGetNumGeometries_r(context, geom);
    for (i=0; i<len; ++i) {
      sub_geom = GEOSGetGeometryN_r(context, geom, i);
      if (sub_geom) {
        type = GEOSGeomTypeId_r(context, sub_geom);
        if (type >= 0) {
          hash = hash ^ type;
          switch (type) {
          case GEOS_POINT:
          case GEOS_LINESTRING:
          case GEOS_LINEARRING:
            hash = rgeo_geos_coordseq_hash(context, sub_geom, hash);
            break;
          case GEOS_POLYGON:
            hash = rgeo_geos_polygon_hash(context, sub_geom, hash);
            break;
          case GEOS_GEOMETRYCOLLECTION:
          case GEOS_MULTIPOINT:
          case GEOS_MULTILINESTRING:
          case GEOS_MULTIPOLYGON:
            hash = rgeo_geos_geometry_collection_hash(context, sub_geom, hash);
            break;
          }
        }
      }
    }
  }
  return hash;
}


RGEO_END_C

#endif
