/*
  Line string methods for GEOS wrapper
*/

#include "preface.h"

#ifdef RGEO_GEOS_SUPPORTED

#include <geos_c.h>
#include <ruby.h>
#include <string.h>

#include "coordinates.h"
#include "factory.h"
#include "geometry.h"
#include "globals.h"
#include "line_string.h"
#include "point.h"

RGEO_BEGIN_C

static VALUE
method_line_string_geometry_type(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  if (self_data->geom) {
    result = rgeo_feature_line_string_module;
  }
  return result;
}

static VALUE
method_linear_ring_geometry_type(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  if (self_data->geom) {
    result = rgeo_feature_linear_ring_module;
  }
  return result;
}

static VALUE
method_line_geometry_type(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  if (self_data->geom) {
    result = rgeo_feature_line_module;
  }
  return result;
}

static VALUE
method_line_string_length(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  double len;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    if (GEOSLength(self_geom, &len)) {
      result = rb_float_new(len);
    }
  }
  return result;
}

static VALUE
method_line_string_num_points(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    result = INT2NUM(GEOSGetNumCoordinates(self_geom));
  }
  return result;
}

static VALUE
method_line_string_coordinates(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  const GEOSCoordSequence* coord_sequence;
  int flags;
  int has_z, has_m;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;

  if (self_geom) {
    flags = RGEO_FACTORY_DATA_PTR(self_data->factory)->flags;
    has_z = (flags & RGEO_FACTORYFLAGS_SUPPORTS_Z) ? 1 : 0;
    has_m = (flags & RGEO_FACTORYFLAGS_SUPPORTS_M) ? 1 : 0;
    coord_sequence = GEOSGeom_getCoordSeq(self_geom);
    if (coord_sequence) {
      result =
        extract_points_from_coordinate_sequence(coord_sequence, has_z, has_m);
    }
  }
  return result;
}

static VALUE
get_point_from_coordseq(VALUE self,
                        const GEOSCoordSequence* coord_seq,
                        unsigned int i,
                        char has_z,
                        char has_m)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  double x, y, z, m;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  z = 0.0;
  m = 0.0;

  if (GEOSCoordSeq_getX(coord_seq, i, &x)) {
    if (GEOSCoordSeq_getY(coord_seq, i, &y)) {
      if (has_z) {
        GEOSCoordSeq_getZ(coord_seq, i, &z);
      }
      if (has_m) {
        GEOSCoordSeq_getM(coord_seq, i, &m);
      }
      result = rgeo_create_geos_point(self_data->factory, x, y, z, m);
    }
  }
  return result;
}

static VALUE
method_line_string_point_n(VALUE self, VALUE n)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  const GEOSCoordSequence* coord_seq;
  int si;
  unsigned int i;
  unsigned int size;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    coord_seq = GEOSGeom_getCoordSeq(self_geom);
    if (coord_seq) {
      int flags = RGEO_FACTORY_DATA_PTR(self_data->factory)->flags;
      char has_z = (flags & RGEO_FACTORYFLAGS_SUPPORTS_Z) ? 1 : 0;
      char has_m = (flags & RGEO_FACTORYFLAGS_SUPPORTS_M) ? 1 : 0;
      si = RB_NUM2INT(n);
      if (si >= 0) {
        i = si;
        if (GEOSCoordSeq_getSize(coord_seq, &size)) {
          if (i < size) {
            result = get_point_from_coordseq(self, coord_seq, i, has_z, has_m);
          }
        }
      }
    }
  }
  return result;
}

static VALUE
method_line_string_points(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  const GEOSCoordSequence* coord_seq;
  unsigned int size;
  unsigned int i;
  VALUE point;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    coord_seq = GEOSGeom_getCoordSeq(self_geom);
    if (coord_seq) {
      int flags = RGEO_FACTORY_DATA_PTR(self_data->factory)->flags;
      char has_z = (flags & RGEO_FACTORYFLAGS_SUPPORTS_Z) ? 1 : 0;
      char has_m = (flags & RGEO_FACTORYFLAGS_SUPPORTS_M) ? 1 : 0;
      if (GEOSCoordSeq_getSize(coord_seq, &size)) {
        result = rb_ary_new2(size);
        for (i = 0; i < size; ++i) {
          point = get_point_from_coordseq(self, coord_seq, i, has_z, has_m);
          if (!NIL_P(point)) {
            rb_ary_store(result, i, point);
          }
        }
      }
    }
  }
  return result;
}

static VALUE
method_line_string_start_point(VALUE self)
{
  return method_line_string_point_n(self, INT2NUM(0));
}

static VALUE
method_line_string_end_point(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  unsigned int n;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    n = GEOSGetNumCoordinates(self_geom);
    if (n > 0) {
      result = method_line_string_point_n(self, INT2NUM(n - 1));
    }
  }
  return result;
}

static VALUE
method_line_string_project_point(VALUE self, VALUE point)
{
  VALUE result = Qnil;
  VALUE factory;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  const GEOSGeometry* geos_point;
  int state = 0;

  double location;

  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  factory = self_data->factory;
  self_geom = self_data->geom;

  if (self_geom && point) {
    geos_point = rgeo_convert_to_geos_geometry(
      factory, point, rgeo_geos_point_class, &state);
    if (state) {
      rb_jump_tag(state);
    }

    location = GEOSProject(self_geom, geos_point);
    result = DBL2NUM(location);
  }
  return result;
}

static VALUE
method_line_string_interpolate_point(VALUE self, VALUE loc_num)
{
  VALUE result = Qnil;
  VALUE factory;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  GEOSGeometry* geos_point;

  double location;

  location = NUM2DBL(loc_num);
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  factory = self_data->factory;
  self_geom = self_data->geom;

  if (self_geom) {
    geos_point = GEOSInterpolate(self_geom, location);
    result =
      rgeo_wrap_geos_geometry(factory, geos_point, rgeo_geos_point_class);
  }

  return result;
}

static VALUE
method_line_string_substring(VALUE self, VALUE start_fraction, VALUE end_fraction)
{
  VALUE result = Qnil;
  VALUE factory;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  GEOSGeometry* substring;

  double start_frac = NUM2DBL(start_fraction);
  double end_frac = NUM2DBL(end_fraction);

  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  factory = self_data->factory;
  self_geom = self_data->geom;

  if (self_geom) {
    substring = GEOSLineSubstring(self_geom, start_frac, end_frac);
    if (substring) {
      result = rgeo_wrap_geos_geometry(factory, substring, rgeo_geos_line_string_class);
    }
  }

  return result;
}

static VALUE
method_line_string_is_closed(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    result = rgeo_is_geos_line_string_closed(self_geom);
  }
  return result;
}

static VALUE
method_line_string_is_ring(VALUE self)
{
  VALUE result;
  RGeo_GeometryData* self_data;
  const GEOSGeometry* self_geom;
  char val;

  result = Qnil;
  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  self_geom = self_data->geom;
  if (self_geom) {
    val = GEOSisRing(self_geom);
    if (val == 0) {
      result = Qfalse;
    } else if (val == 1) {
      result = Qtrue;
    }
  }
  return result;
}

static VALUE
method_line_string_eql(VALUE self, VALUE rhs)
{
  VALUE result;
  RGeo_GeometryData* self_data;

  result = rgeo_geos_klasses_and_factories_eql(self, rhs);
  if (RTEST(result)) {
    self_data = RGEO_GEOMETRY_DATA_PTR(self);
    result = rgeo_geos_geometries_strict_eql(self_data->geom,
                                             RGEO_GEOMETRY_DATA_PTR(rhs)->geom);
  }
  return result;
}

static VALUE
method_line_string_hash(VALUE self)
{
  st_index_t hash;
  RGeo_GeometryData* self_data;
  VALUE factory;

  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  factory = self_data->factory;
  hash = rb_hash_start(0);
  hash = rgeo_geos_objbase_hash(factory, rgeo_feature_line_string_module, hash);
  hash = rgeo_geos_coordseq_hash(self_data->geom, hash);
  return LONG2FIX(rb_hash_end(hash));
}

static VALUE
method_linear_ring_hash(VALUE self)
{
  st_index_t hash;
  RGeo_GeometryData* self_data;
  VALUE factory;

  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  factory = self_data->factory;
  hash = rb_hash_start(0);
  hash = rgeo_geos_objbase_hash(factory, rgeo_feature_linear_ring_module, hash);
  hash = rgeo_geos_coordseq_hash(self_data->geom, hash);
  return LONG2FIX(rb_hash_end(hash));
}

static VALUE
method_line_hash(VALUE self)
{
  st_index_t hash;
  RGeo_GeometryData* self_data;
  VALUE factory;

  self_data = RGEO_GEOMETRY_DATA_PTR(self);
  factory = self_data->factory;
  hash = rb_hash_start(0);
  hash = rgeo_geos_objbase_hash(factory, rgeo_feature_line_module, hash);
  hash = rgeo_geos_coordseq_hash(self_data->geom, hash);
  return LONG2FIX(rb_hash_end(hash));
}

static GEOSCoordSequence*
coord_seq_from_array(VALUE factory, VALUE array, char close)
{
  VALUE point_type;
  unsigned int len;
  int flags;
  char has_z, has_m;
  unsigned int dims;
  double* coords;
  unsigned int i;
  char good;
  const GEOSGeometry* entry_geom;
  const GEOSCoordSequence* entry_cs;
  double x;
  GEOSCoordSequence* coord_seq;
  int state = 0;

  Check_Type(array, T_ARRAY);
  point_type = rgeo_feature_point_module;
  len = (unsigned int)RARRAY_LEN(array);
  flags = RGEO_FACTORY_DATA_PTR(factory)->flags;
  has_z = (flags & RGEO_FACTORYFLAGS_SUPPORTS_Z) ? 1 : 0;
  has_m = (flags & RGEO_FACTORYFLAGS_SUPPORTS_M) ? 1 : 0;
  dims = 2 + has_z + has_m;
  coords = ALLOC_N(double, len == 0 ? 1 : len * dims);
  if (!coords) {
    return NULL;
  }
  for (i = 0; i < len; ++i) {
    good = 0;

    entry_geom = rgeo_convert_to_geos_geometry(
      factory, rb_ary_entry(array, i), point_type, &state);
    if (state) {
      FREE(coords);
      rb_jump_tag(state);
    }

    entry_cs = GEOSGeom_getCoordSeq(entry_geom);
    if (entry_cs) {
      unsigned int idx = 0;
      if (GEOSCoordSeq_getX(entry_cs, 0, &x)) {
        coords[i * dims + idx++] = x;
        if (GEOSCoordSeq_getY(entry_cs, 0, &x)) {
          coords[i * dims + idx++] = x;
          good = 1;
          if (has_z) {
            if (GEOSCoordSeq_getZ(entry_cs, 0, &x)) {
              coords[i * dims + idx++] = x;
            } else {
              coords[i * dims + idx++] = 0.0;
            }
          }
          if (has_m) {
            if (GEOSCoordSeq_getM(entry_cs, 0, &x)) {
              coords[i * dims + idx++] = x;
            } else {
              coords[i * dims + idx++] = 0.0;
            }
          }
        }
      }
    }
    if (!good) {
      FREE(coords);
      return NULL;
    }
  }
  if (len > 0 && close) {
    if (coords[0] == coords[(len - 1) * dims] &&
        coords[1] == coords[(len - 1) * dims + 1]) {
      close = 0;
    }
  } else {
    close = 0;
  }
  coord_seq = GEOSCoordSeq_createWithDimensions(len + close, has_z ? 1 : 0, has_m ? 1 : 0);
  if (coord_seq) {
    for (i = 0; i < len; ++i) {
      unsigned int idx = 0;
      GEOSCoordSeq_setX(coord_seq, i, coords[i * dims + idx++]);
      GEOSCoordSeq_setY(coord_seq, i, coords[i * dims + idx++]);
      if (has_z) {
        GEOSCoordSeq_setZ(coord_seq, i, coords[i * dims + idx++]);
      }
      if (has_m) {
        GEOSCoordSeq_setM(coord_seq, i, coords[i * dims + idx++]);
      }
    }
    if (close) {
      unsigned int idx = 0;
      GEOSCoordSeq_setX(coord_seq, len, coords[idx++]);
      GEOSCoordSeq_setY(coord_seq, len, coords[idx++]);
      if (has_z) {
        GEOSCoordSeq_setZ(coord_seq, len, coords[idx++]);
      }
      if (has_m) {
        GEOSCoordSeq_setM(coord_seq, len, coords[idx++]);
      }
    }
  }
  FREE(coords);
  return coord_seq;
}

static VALUE
cmethod_create_line_string(VALUE module, VALUE factory, VALUE array)
{
  VALUE result;
  GEOSCoordSequence* coord_seq;
  GEOSGeometry* geom;

  result = Qnil;
  coord_seq = coord_seq_from_array(factory, array, 0);
  if (coord_seq) {
    geom = GEOSGeom_createLineString(coord_seq);
    if (geom) {
      result =
        rgeo_wrap_geos_geometry(factory, geom, rgeo_geos_line_string_class);
    }
  }
  return result;
}

static VALUE
cmethod_create_linear_ring(VALUE module, VALUE factory, VALUE array)
{
  VALUE result;
  GEOSCoordSequence* coord_seq;
  GEOSGeometry* geom;

  result = Qnil;
  coord_seq = coord_seq_from_array(factory, array, 1);
  if (coord_seq) {
    geom = GEOSGeom_createLinearRing(coord_seq);
    if (geom) {
      result =
        rgeo_wrap_geos_geometry(factory, geom, rgeo_geos_linear_ring_class);
    }
  }
  return result;
}

static void
populate_geom_into_coord_seq(const GEOSGeometry* geom,
                             GEOSCoordSequence* coord_seq,
                             unsigned int i,
                             char has_z,
                             char has_m)
{
  const GEOSCoordSequence* cs;
  double x;

  cs = GEOSGeom_getCoordSeq(geom);
  x = 0;
  if (cs) {
    GEOSCoordSeq_getX(cs, 0, &x);
  }
  GEOSCoordSeq_setX(coord_seq, i, x);
  x = 0;
  if (cs) {
    GEOSCoordSeq_getY(cs, 0, &x);
  }
  GEOSCoordSeq_setY(coord_seq, i, x);
  if (has_z) {
    x = 0;
    if (cs) {
      GEOSCoordSeq_getZ(cs, 0, &x);
    }
    GEOSCoordSeq_setZ(coord_seq, i, x);
  }
  if (has_m) {
    x = 0;
    if (cs) {
      GEOSCoordSeq_getM(cs, 0, &x);
    }
    GEOSCoordSeq_setM(coord_seq, i, x);
  }
}

static VALUE
cmethod_create_line(VALUE module, VALUE factory, VALUE start, VALUE end)
{
  VALUE result;
  RGeo_FactoryData* factory_data;
  char has_z, has_m;
  VALUE point_type;
  const GEOSGeometry* start_geom;
  const GEOSGeometry* end_geom;
  GEOSCoordSequence* coord_seq;
  GEOSGeometry* geom;
  int state = 0;

  result = Qnil;
  factory_data = RGEO_FACTORY_DATA_PTR(factory);
  has_z = (factory_data->flags & RGEO_FACTORYFLAGS_SUPPORTS_Z) ? 1 : 0;
  has_m = (factory_data->flags & RGEO_FACTORYFLAGS_SUPPORTS_M) ? 1 : 0;
  point_type = rgeo_feature_point_module;

  start_geom =
    rgeo_convert_to_geos_geometry(factory, start, point_type, &state);
  if (state) {
    rb_jump_tag(state);
  }

  end_geom = rgeo_convert_to_geos_geometry(factory, end, point_type, &state);
  if (state) {
    rb_jump_tag(state);
  }

  coord_seq = GEOSCoordSeq_createWithDimensions(2, has_z, has_m);
  if (coord_seq) {
    populate_geom_into_coord_seq(start_geom, coord_seq, 0, has_z, has_m);
    populate_geom_into_coord_seq(end_geom, coord_seq, 1, has_z, has_m);
    geom = GEOSGeom_createLineString(coord_seq);
    if (geom) {
      result = rgeo_wrap_geos_geometry(factory, geom, rgeo_geos_line_class);
    }
  }

  return result;
}

static VALUE
impl_copy_from(VALUE klass, VALUE factory, VALUE original, char subtype)
{
  VALUE result;
  const GEOSGeometry* original_geom;
  const GEOSCoordSequence* original_coord_seq;
  GEOSCoordSequence* coord_seq;
  GEOSGeometry* geom;

  result = Qnil;
  original_geom = RGEO_GEOMETRY_DATA_PTR(original)->geom;
  if (original_geom) {
    if (subtype == 1 && GEOSGetNumCoordinates(original_geom) != 2) {
      original_geom = NULL;
    }
    if (original_geom) {
      original_coord_seq = GEOSGeom_getCoordSeq(original_geom);
      if (original_coord_seq) {
        coord_seq = GEOSCoordSeq_clone(original_coord_seq);
        if (coord_seq) {
          geom = subtype == 2 ? GEOSGeom_createLinearRing(coord_seq)
                              : GEOSGeom_createLineString(coord_seq);
          if (geom) {
            result = rgeo_wrap_geos_geometry(factory, geom, klass);
          }
        }
      }
    }
  }
  return result;
}

static VALUE
cmethod_line_string_copy_from(VALUE klass, VALUE factory, VALUE original)
{
  return impl_copy_from(klass, factory, original, 0);
}

static VALUE
cmethod_line_copy_from(VALUE klass, VALUE factory, VALUE original)
{
  return impl_copy_from(klass, factory, original, 1);
}

static VALUE
cmethod_linear_ring_copy_from(VALUE klass, VALUE factory, VALUE original)
{
  return impl_copy_from(klass, factory, original, 2);
}

void
rgeo_init_geos_line_string()
{
  VALUE geos_line_string_methods;
  VALUE geos_linear_ring_methods;
  VALUE geos_line_methods;

  // Class methods for CAPILineStringImpl
  rb_define_module_function(
    rgeo_geos_line_string_class, "create", cmethod_create_line_string, 2);
  rb_define_module_function(rgeo_geos_line_string_class,
                            "_copy_from",
                            cmethod_line_string_copy_from,
                            2);

  // Class methods for CAPILinearRingImpl
  rb_define_module_function(
    rgeo_geos_linear_ring_class, "create", cmethod_create_linear_ring, 2);
  rb_define_module_function(rgeo_geos_linear_ring_class,
                            "_copy_from",
                            cmethod_linear_ring_copy_from,
                            2);

  // Class methods for CAPILineImpl
  rb_define_module_function(
    rgeo_geos_line_class, "create", cmethod_create_line, 3);
  rb_define_module_function(
    rgeo_geos_line_class, "_copy_from", cmethod_line_copy_from, 2);

  // CAPILineStringMethods module
  geos_line_string_methods =
    rb_define_module_under(rgeo_geos_module, "CAPILineStringMethods");
  rb_define_method(
    geos_line_string_methods, "rep_equals?", method_line_string_eql, 1);
  rb_define_method(geos_line_string_methods, "eql?", method_line_string_eql, 1);
  rb_define_method(
    geos_line_string_methods, "hash", method_line_string_hash, 0);
  rb_define_method(geos_line_string_methods,
                   "geometry_type",
                   method_line_string_geometry_type,
                   0);
  rb_define_method(
    geos_line_string_methods, "length", method_line_string_length, 0);
  rb_define_method(
    geos_line_string_methods, "num_points", method_line_string_num_points, 0);
  rb_define_method(
    geos_line_string_methods, "point_n", method_line_string_point_n, 1);
  rb_define_method(
    geos_line_string_methods, "points", method_line_string_points, 0);
  rb_define_method(
    geos_line_string_methods, "start_point", method_line_string_start_point, 0);
  rb_define_method(
    geos_line_string_methods, "end_point", method_line_string_end_point, 0);
  rb_define_method(geos_line_string_methods,
                   "project_point",
                   method_line_string_project_point,
                   1);
  rb_define_method(geos_line_string_methods,
                   "interpolate_point",
                   method_line_string_interpolate_point,
                   1);
  rb_define_method(geos_line_string_methods,
                   "line_substring",
                   method_line_string_substring,
                   2);
  rb_define_method(
    geos_line_string_methods, "closed?", method_line_string_is_closed, 0);
  rb_define_method(
    geos_line_string_methods, "ring?", method_line_string_is_ring, 0);
  rb_define_method(
    geos_line_string_methods, "coordinates", method_line_string_coordinates, 0);

  // CAPILinearRingMethods module
  geos_linear_ring_methods =
    rb_define_module_under(rgeo_geos_module, "CAPILinearRingMethods");
  rb_define_method(geos_linear_ring_methods,
                   "geometry_type",
                   method_linear_ring_geometry_type,
                   0);
  rb_define_method(
    geos_linear_ring_methods, "hash", method_linear_ring_hash, 0);

  // CAPILineMethods module
  geos_line_methods =
    rb_define_module_under(rgeo_geos_module, "CAPILineMethods");
  rb_define_method(
    geos_line_methods, "geometry_type", method_line_geometry_type, 0);
  rb_define_method(geos_line_methods, "hash", method_line_hash, 0);
}

VALUE
rgeo_is_geos_line_string_closed(const GEOSGeometry* geom)
{
  VALUE result;
  unsigned int n;
  double x1, x2, y1, y2;
  const GEOSCoordSequence* coord_seq;

  result = Qnil;
  n = GEOSGetNumCoordinates(geom);
  if (n > 0) {
    coord_seq = GEOSGeom_getCoordSeq(geom);
    if (GEOSCoordSeq_getX(coord_seq, 0, &x1)) {
      if (GEOSCoordSeq_getX(coord_seq, n - 1, &x2)) {
        if (x1 == x2) {
          if (GEOSCoordSeq_getY(coord_seq, 0, &y1)) {
            if (GEOSCoordSeq_getY(coord_seq, n - 1, &y2)) {
              result = y1 == y2 ? Qtrue : Qfalse;
            }
          }
        } else {
          result = Qfalse;
        }
      }
    }
  }
  return result;
}

RGEO_END_C

#endif
