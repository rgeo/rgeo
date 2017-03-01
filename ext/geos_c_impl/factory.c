/*
  Factory and utility functions for GEOS wrapper
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

RGEO_BEGIN_C


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
  GEOSContextHandle_t context;

  context = data->geos_context;
  if (data->wkt_reader) {
    GEOSWKTReader_destroy_r(context, data->wkt_reader);
  }
  if (data->wkb_reader) {
    GEOSWKBReader_destroy_r(context, data->wkb_reader);
  }
  if (data->wkt_writer) {
    GEOSWKTWriter_destroy_r(context, data->wkt_writer);
  }
  if (data->wkb_writer) {
    GEOSWKBWriter_destroy_r(context, data->wkb_writer);
  }
  if (data->psych_wkt_reader) {
    GEOSWKTReader_destroy_r(context, data->psych_wkt_reader);
  }
  if (data->marshal_wkb_reader) {
    GEOSWKBReader_destroy_r(context, data->marshal_wkb_reader);
  }
  if (data->psych_wkt_writer) {
    GEOSWKTWriter_destroy_r(context, data->psych_wkt_writer);
  }
  if (data->marshal_wkb_writer) {
    GEOSWKBWriter_destroy_r(context, data->marshal_wkb_writer);
  }
  finishGEOS_r(context);
  free(data);
}


// Destroy function for geometry data. We destroy the internal
// GEOS geometry (if present) before freeing the data itself.

static void destroy_geometry_func(RGeo_GeometryData* data)
{
  const GEOSPreparedGeometry* prep;

  if (data->geom) {
    GEOSGeom_destroy_r(data->geos_context, data->geom);
  }
  prep = data->prep;
  if (prep && prep != (const GEOSPreparedGeometry*)1 && prep != (const GEOSPreparedGeometry*)2 &&
    prep != (const GEOSPreparedGeometry*)3)
  {
    GEOSPreparedGeom_destroy_r(data->geos_context, prep);
  }
  free(data);
}


// Mark function for factory data. This marks the wkt and wkb generator
// handles so they don't get collected.

static void mark_factory_func(RGeo_FactoryData* data)
{
  if (!NIL_P(data->wkrep_wkt_generator)) {
    rb_gc_mark(data->wkrep_wkt_generator);
  }
  if (!NIL_P(data->wkrep_wkb_generator)) {
    rb_gc_mark(data->wkrep_wkb_generator);
  }
  if (!NIL_P(data->wkrep_wkt_parser)) {
    rb_gc_mark(data->wkrep_wkt_parser);
  }
  if (!NIL_P(data->wkrep_wkb_parser)) {
    rb_gc_mark(data->wkrep_wkb_parser);
  }
  if (!NIL_P(data->proj4_obj)) {
    rb_gc_mark(data->proj4_obj);
  }
  if (!NIL_P(data->coord_sys_obj)) {
    rb_gc_mark(data->coord_sys_obj);
  }
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


// Mark function for globals data. This should mark any globals that
// need to be held through garbage collection (none at the moment.)

static void mark_globals_func(RGeo_Globals* data)
{
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
  RGeo_FactoryData* self_data;
  GEOSContextHandle_t self_context;
  GEOSWKTReader* wkt_reader;
  VALUE result;
  GEOSGeometry* geom;

  Check_Type(str, T_STRING);
  self_data = RGEO_FACTORY_DATA_PTR(self);
  self_context = self_data->geos_context;
  wkt_reader = self_data->wkt_reader;
  if (!wkt_reader) {
    wkt_reader = GEOSWKTReader_create_r(self_context);
    self_data->wkt_reader = wkt_reader;
  }
  result = Qnil;
  if (wkt_reader) {
    geom = GEOSWKTReader_read_r(self_context, wkt_reader, RSTRING_PTR(str));
    if (geom) {
      result = rgeo_wrap_geos_geometry(self, geom, Qnil);
    }
  }
  return result;
}


static VALUE method_factory_parse_wkb(VALUE self, VALUE str)
{
  RGeo_FactoryData* self_data;
  GEOSContextHandle_t self_context;
  GEOSWKBReader* wkb_reader;
  VALUE result;
  GEOSGeometry* geom;

  Check_Type(str, T_STRING);
  self_data = RGEO_FACTORY_DATA_PTR(self);
  self_context = self_data->geos_context;
  wkb_reader = self_data->wkb_reader;
  if (!wkb_reader) {
    wkb_reader = GEOSWKBReader_create_r(self_context);
    self_data->wkb_reader = wkb_reader;
  }
  result = Qnil;
  if (wkb_reader) {
    geom = GEOSWKBReader_read_r(self_context, wkb_reader, (unsigned char*)RSTRING_PTR(str), (size_t)RSTRING_LEN(str));
    if (geom) {
      result = rgeo_wrap_geos_geometry(self, geom, Qnil);
    }
  }
  return result;
}


static VALUE method_factory_read_for_marshal(VALUE self, VALUE str)
{
  RGeo_FactoryData* self_data;
  GEOSContextHandle_t self_context;
  GEOSWKBReader* wkb_reader;
  VALUE result;
  GEOSGeometry* geom;

  Check_Type(str, T_STRING);
  self_data = RGEO_FACTORY_DATA_PTR(self);
  self_context = self_data->geos_context;
  wkb_reader = self_data->marshal_wkb_reader;
  if (!wkb_reader) {
    wkb_reader = GEOSWKBReader_create_r(self_context);
    self_data->marshal_wkb_reader = wkb_reader;
  }
  result = Qnil;
  if (wkb_reader) {
    geom = GEOSWKBReader_read_r(self_context, wkb_reader, (unsigned char*)RSTRING_PTR(str), (size_t)RSTRING_LEN(str));
    if (geom) {
      result = rgeo_wrap_geos_geometry(self, geom, Qnil);
    }
  }
  return result;
}


static VALUE method_factory_read_for_psych(VALUE self, VALUE str)
{
  RGeo_FactoryData* self_data;
  GEOSContextHandle_t self_context;
  GEOSWKTReader* wkt_reader;
  VALUE result;
  GEOSGeometry* geom;

  Check_Type(str, T_STRING);
  self_data = RGEO_FACTORY_DATA_PTR(self);
  self_context = self_data->geos_context;
  wkt_reader = self_data->psych_wkt_reader;
  if (!wkt_reader) {
    wkt_reader = GEOSWKTReader_create_r(self_context);
    self_data->psych_wkt_reader = wkt_reader;
  }
  result = Qnil;
  if (wkt_reader) {
    geom = GEOSWKTReader_read_r(self_context, wkt_reader, RSTRING_PTR(str));
    if (geom) {
      result = rgeo_wrap_geos_geometry(self, geom, Qnil);
    }
  }
  return result;
}


static VALUE method_factory_write_for_marshal(VALUE self, VALUE obj)
{
  RGeo_FactoryData* self_data;
  GEOSContextHandle_t self_context;
  GEOSWKBWriter* wkb_writer;
  const GEOSGeometry* geom;
  VALUE result;
  char* str;
  size_t size;
  char has_3d;
#ifndef RGEO_GEOS_SUPPORTS_SETOUTPUTDIMENSION
  RGeo_Globals* globals;
  VALUE wkb_generator;
#endif

  self_data = RGEO_FACTORY_DATA_PTR(self);
  self_context = self_data->geos_context;
  has_3d = self_data->flags & RGEO_FACTORYFLAGS_SUPPORTS_Z_OR_M;
#ifndef RGEO_GEOS_SUPPORTS_SETOUTPUTDIMENSION
  if (has_3d) {
    globals = self_data->globals;
    wkb_generator = globals->marshal_wkb_generator;
    if (NIL_P(wkb_generator)) {
      wkb_generator = rb_funcall(
        rb_const_get_at(globals->geos_module, rb_intern("Utils")),
        rb_intern("marshal_wkb_generator"), 0);
      globals->marshal_wkb_generator = wkb_generator;
    }
    return rb_funcall(wkb_generator, globals->id_generate, 1, obj);
  }
#endif
  wkb_writer = self_data->marshal_wkb_writer;
  if (!wkb_writer) {
    wkb_writer = GEOSWKBWriter_create_r(self_context);
    if (has_3d) {
      GEOSWKBWriter_setOutputDimension_r(self_context, wkb_writer, 3);
    }
    self_data->marshal_wkb_writer = wkb_writer;
  }
  result = Qnil;
  if (wkb_writer) {
    geom = rgeo_get_geos_geometry_safe(obj);
    if (geom) {
      str = (char*)GEOSWKBWriter_write_r(self_context, wkb_writer, geom, &size);
      if (str) {
        result = rb_str_new(str, size);
        GEOSFree_r(self_context, str);
      }
    }
  }
  return result;
}


static VALUE method_factory_write_for_psych(VALUE self, VALUE obj)
{
  RGeo_FactoryData* self_data;
  GEOSContextHandle_t self_context;
  GEOSWKTWriter* wkt_writer;
  const GEOSGeometry* geom;
  VALUE result;
  char* str;
  char has_3d;
#ifndef RGEO_GEOS_SUPPORTS_SETOUTPUTDIMENSION
  RGeo_Globals* globals;
  VALUE wkt_generator;
#endif

  self_data = RGEO_FACTORY_DATA_PTR(self);
  self_context = self_data->geos_context;
  has_3d = self_data->flags & RGEO_FACTORYFLAGS_SUPPORTS_Z_OR_M;
#ifndef RGEO_GEOS_SUPPORTS_SETOUTPUTDIMENSION
  if (has_3d) {
    globals = self_data->globals;
    wkt_generator = globals->psych_wkt_generator;
    if (NIL_P(wkt_generator)) {
      wkt_generator = rb_funcall(
        rb_const_get_at(globals->geos_module, rb_intern("Utils")),
        rb_intern("psych_wkt_generator"), 0);
      globals->psych_wkt_generator = wkt_generator;
    }
    return rb_funcall(wkt_generator, globals->id_generate, 1, obj);
  }
#endif
  wkt_writer = self_data->psych_wkt_writer;
  if (!wkt_writer) {
    wkt_writer = GEOSWKTWriter_create_r(self_context);
    if (has_3d) {
      GEOSWKTWriter_setOutputDimension_r(self_context, wkt_writer, 3);
    }
    self_data->psych_wkt_writer = wkt_writer;
  }
  result = Qnil;
  if (wkt_writer) {
    geom = rgeo_get_geos_geometry_safe(obj);
    if (geom) {
      str = GEOSWKTWriter_write_r(self_context, wkt_writer, geom);
      if (str) {
        result = rb_str_new2(str);
        GEOSFree_r(self_context, str);
      }
    }
  }
  return result;
}


static VALUE cmethod_factory_geos_version(VALUE klass)
{
  return rb_str_new2(GEOS_VERSION);
}


static VALUE cmethod_factory_supports_unary_union(VALUE klass)
{
#ifdef RGEO_GEOS_SUPPORTS_UNARYUNION
  return Qtrue;
#else
  return Qfalse;
#endif
}

static VALUE cmethod_factory_create(VALUE klass, VALUE flags, VALUE srid, VALUE buffer_resolution,
  VALUE wkt_generator, VALUE wkb_generator, VALUE proj4_obj, VALUE coord_sys_obj)
{
  VALUE result;
  RGeo_FactoryData* data;
  GEOSContextHandle_t context;
  VALUE wrapped_globals;

  result = Qnil;
  data = ALLOC(RGeo_FactoryData);
  if (data) {
    context = initGEOS_r(message_handler, message_handler);
    if (context) {
      wrapped_globals = rb_const_get_at(klass, rb_intern("INTERNAL_CGLOBALS"));
      data->globals = (RGeo_Globals*)DATA_PTR(wrapped_globals);
      data->geos_context = context;
      data->flags = NUM2INT(flags);
      data->srid = NUM2INT(srid);
      data->buffer_resolution = NUM2INT(buffer_resolution);
      data->wkt_reader = NULL;
      data->wkb_reader = NULL;
      data->wkt_writer = NULL;
      data->wkb_writer = NULL;
      data->psych_wkt_reader = NULL;
      data->marshal_wkb_reader = NULL;
      data->psych_wkt_writer = NULL;
      data->marshal_wkb_writer = NULL;
      data->wkrep_wkt_generator = wkt_generator;
      data->wkrep_wkb_generator = wkb_generator;
      data->wkrep_wkt_parser = Qnil;
      data->wkrep_wkb_parser = Qnil;
      data->proj4_obj = proj4_obj;
      data->coord_sys_obj = coord_sys_obj;
      result = Data_Wrap_Struct(klass, mark_factory_func, destroy_factory_func, data);
    }
    else {
      free(data);
    }
  }
  return result;
}


static VALUE alloc_factory(VALUE klass)
{
  return cmethod_factory_create(klass, INT2NUM(0), INT2NUM(0), INT2NUM(0), Qnil, Qnil, Qnil, Qnil);
}


static VALUE method_factory_initialize_copy(VALUE self, VALUE orig)
{
  RGeo_FactoryData* self_data;
  RGeo_FactoryData* orig_data;
  GEOSContextHandle_t context;

  // Clear out existing data
  self_data = RGEO_FACTORY_DATA_PTR(self);
  context = self_data->geos_context;
  if (self_data->wkt_reader) {
    GEOSWKTReader_destroy_r(context, self_data->wkt_reader);
    self_data->wkt_reader = NULL;
  }
  if (self_data->wkb_reader) {
    GEOSWKBReader_destroy_r(context, self_data->wkb_reader);
    self_data->wkb_reader = NULL;
  }
  if (self_data->wkt_writer) {
    GEOSWKTWriter_destroy_r(context, self_data->wkt_writer);
    self_data->wkt_writer = NULL;
  }
  if (self_data->wkb_writer) {
    GEOSWKBWriter_destroy_r(context, self_data->wkb_writer);
    self_data->wkb_writer = NULL;
  }
  if (self_data->psych_wkt_reader) {
    GEOSWKTReader_destroy_r(context, self_data->psych_wkt_reader);
    self_data->psych_wkt_reader = NULL;
  }
  if (self_data->marshal_wkb_reader) {
    GEOSWKBReader_destroy_r(context, self_data->marshal_wkb_reader);
    self_data->marshal_wkb_reader = NULL;
  }
  if (self_data->psych_wkt_writer) {
    GEOSWKTWriter_destroy_r(context, self_data->psych_wkt_writer);
    self_data->psych_wkt_writer = NULL;
  }
  if (self_data->marshal_wkb_writer) {
    GEOSWKBWriter_destroy_r(context, self_data->marshal_wkb_writer);
    self_data->marshal_wkb_writer = NULL;
  }
  self_data->wkrep_wkt_generator = Qnil;
  self_data->wkrep_wkb_generator = Qnil;
  self_data->wkrep_wkt_parser = Qnil;
  self_data->wkrep_wkb_parser = Qnil;
  self_data->proj4_obj = Qnil;
  self_data->coord_sys_obj = Qnil;

  // Copy new data from original object
  if (TYPE(orig) == T_DATA && RDATA(orig)->dfree == (RUBY_DATA_FUNC)destroy_factory_func) {
    orig_data = RGEO_FACTORY_DATA_PTR(orig);
    self_data->flags = orig_data->flags;
    self_data->srid = orig_data->srid;
    self_data->buffer_resolution = orig_data->buffer_resolution;
    self_data->wkrep_wkt_generator = orig_data->wkrep_wkt_generator;
    self_data->wkrep_wkb_generator = orig_data->wkrep_wkb_generator;
    self_data->wkrep_wkt_parser = orig_data->wkrep_wkt_parser;
    self_data->wkrep_wkb_parser = orig_data->wkrep_wkb_parser;
    self_data->proj4_obj = orig_data->proj4_obj;
    self_data->coord_sys_obj = orig_data->coord_sys_obj;
  }
  return self;
}


static VALUE method_set_wkrep_parsers(VALUE self, VALUE wkt_parser, VALUE wkb_parser)
{
  RGeo_FactoryData* self_data;

  self_data = RGEO_FACTORY_DATA_PTR(self);
  self_data->wkrep_wkt_parser = wkt_parser;
  self_data->wkrep_wkb_parser = wkb_parser;

  return self;
}


static VALUE method_get_proj4(VALUE self)
{
  return RGEO_FACTORY_DATA_PTR(self)->proj4_obj;
}


static VALUE method_get_coord_sys(VALUE self)
{
  return RGEO_FACTORY_DATA_PTR(self)->coord_sys_obj;
}


static VALUE method_get_wkt_generator(VALUE self)
{
  return RGEO_FACTORY_DATA_PTR(self)->wkrep_wkt_generator;
}


static VALUE method_get_wkb_generator(VALUE self)
{
  return RGEO_FACTORY_DATA_PTR(self)->wkrep_wkb_generator;
}


static VALUE method_get_wkt_parser(VALUE self)
{
  return RGEO_FACTORY_DATA_PTR(self)->wkrep_wkt_parser;
}


static VALUE method_get_wkb_parser(VALUE self)
{
  return RGEO_FACTORY_DATA_PTR(self)->wkrep_wkb_parser;
}


static VALUE alloc_geometry(VALUE klass)
{
  return rgeo_wrap_geos_geometry(Qnil, NULL, klass);
}


/**** INITIALIZATION FUNCTION ****/


RGeo_Globals* rgeo_init_geos_factory()
{
  RGeo_Globals* globals;
  VALUE rgeo_module;
  VALUE geos_factory_class;
  VALUE wrapped_globals;
  VALUE feature_module;

  globals = ALLOC(RGeo_Globals);

  // Cache some modules so we don't have to look them up by name every time
  rgeo_module = rb_define_module("RGeo");
  feature_module = rb_define_module_under(rgeo_module, "Feature");
  globals->feature_module = feature_module;
  globals->geos_module = rb_define_module_under(rgeo_module, "Geos");
  globals->feature_geometry = rb_const_get_at(feature_module, rb_intern("Geometry"));
  globals->feature_point = rb_const_get_at(feature_module, rb_intern("Point"));
  globals->feature_line_string = rb_const_get_at(feature_module, rb_intern("LineString"));
  globals->feature_linear_ring = rb_const_get_at(feature_module, rb_intern("LinearRing"));
  globals->feature_line = rb_const_get_at(feature_module, rb_intern("Line"));
  globals->feature_polygon = rb_const_get_at(feature_module, rb_intern("Polygon"));
  globals->feature_geometry_collection = rb_const_get_at(feature_module, rb_intern("GeometryCollection"));
  globals->feature_multi_point = rb_const_get_at(feature_module, rb_intern("MultiPoint"));
  globals->feature_multi_line_string = rb_const_get_at(feature_module, rb_intern("MultiLineString"));
  globals->feature_multi_polygon = rb_const_get_at(feature_module, rb_intern("MultiPolygon"));

  // Cache some commonly used names
  globals->id_cast = rb_intern("cast");
  globals->id_eql = rb_intern("eql?");
  globals->id_generate = rb_intern("generate");
  globals->id_enum_for = rb_intern("enum_for");
  globals->id_hash = rb_intern("hash");
  globals->sym_force_new = ID2SYM(rb_intern("force_new"));
  globals->sym_keep_subtype = ID2SYM(rb_intern("keep_subtype"));
#ifndef RGEO_GEOS_SUPPORTS_SETOUTPUTDIMENSION
  globals->psych_wkt_generator = Qnil;
  globals->marshal_wkb_generator = Qnil;
#endif

  // Add C methods to the factory.
  geos_factory_class = rb_define_class_under(globals->geos_module, "CAPIFactory", rb_cObject);
  rb_define_alloc_func(geos_factory_class, alloc_factory);
  rb_define_method(geos_factory_class, "initialize_copy", method_factory_initialize_copy, 1);
  rb_define_method(geos_factory_class, "_parse_wkt_impl", method_factory_parse_wkt, 1);
  rb_define_method(geos_factory_class, "_parse_wkb_impl", method_factory_parse_wkb, 1);
  rb_define_method(geos_factory_class, "_srid", method_factory_srid, 0);
  rb_define_method(geos_factory_class, "_buffer_resolution", method_factory_buffer_resolution, 0);
  rb_define_method(geos_factory_class, "_flags", method_factory_flags, 0);
  rb_define_method(geos_factory_class, "_set_wkrep_parsers", method_set_wkrep_parsers, 2);
  rb_define_method(geos_factory_class, "_proj4", method_get_proj4, 0);
  rb_define_method(geos_factory_class, "_coord_sys", method_get_coord_sys, 0);
  rb_define_method(geos_factory_class, "_wkt_generator", method_get_wkt_generator, 0);
  rb_define_method(geos_factory_class, "_wkb_generator", method_get_wkb_generator, 0);
  rb_define_method(geos_factory_class, "_wkt_parser", method_get_wkt_parser, 0);
  rb_define_method(geos_factory_class, "_wkb_parser", method_get_wkb_parser, 0);
  rb_define_method(geos_factory_class, "_read_for_marshal", method_factory_read_for_marshal, 1);
  rb_define_method(geos_factory_class, "_write_for_marshal", method_factory_write_for_marshal, 1);
  rb_define_method(geos_factory_class, "_read_for_psych", method_factory_read_for_psych, 1);
  rb_define_method(geos_factory_class, "_write_for_psych", method_factory_write_for_psych, 1);
  rb_define_module_function(geos_factory_class, "_create", cmethod_factory_create, 7);
  rb_define_module_function(geos_factory_class, "_geos_version", cmethod_factory_geos_version, 0);
  rb_define_module_function(geos_factory_class, "_supports_unary_union?", cmethod_factory_supports_unary_union, 0);

  // Pre-define implementation classes and set up allocation methods
  globals->geos_geometry = rb_define_class_under(globals->geos_module, "CAPIGeometryImpl", rb_cObject);
  rb_define_alloc_func(globals->geos_geometry, alloc_geometry);
  globals->geos_point = rb_define_class_under(globals->geos_module, "CAPIPointImpl", rb_cObject);
  rb_define_alloc_func(globals->geos_point, alloc_geometry);
  globals->geos_line_string = rb_define_class_under(globals->geos_module, "CAPILineStringImpl", rb_cObject);
  rb_define_alloc_func(globals->geos_line_string, alloc_geometry);
  globals->geos_linear_ring = rb_define_class_under(globals->geos_module, "CAPILinearRingImpl", rb_cObject);
  rb_define_alloc_func(globals->geos_linear_ring, alloc_geometry);
  globals->geos_line = rb_define_class_under(globals->geos_module, "CAPILineImpl", rb_cObject);
  rb_define_alloc_func(globals->geos_line, alloc_geometry);
  globals->geos_polygon = rb_define_class_under(globals->geos_module, "CAPIPolygonImpl", rb_cObject);
  rb_define_alloc_func(globals->geos_polygon, alloc_geometry);
  globals->geos_geometry_collection = rb_define_class_under(globals->geos_module, "CAPIGeometryCollectionImpl", rb_cObject);
  rb_define_alloc_func(globals->geos_geometry_collection, alloc_geometry);
  globals->geos_multi_point = rb_define_class_under(globals->geos_module, "CAPIMultiPointImpl", rb_cObject);
  rb_define_alloc_func(globals->geos_multi_point, alloc_geometry);
  globals->geos_multi_line_string = rb_define_class_under(globals->geos_module, "CAPIMultiLineStringImpl", rb_cObject);
  rb_define_alloc_func(globals->geos_multi_line_string, alloc_geometry);
  globals->geos_multi_polygon = rb_define_class_under(globals->geos_module, "CAPIMultiPolygonImpl", rb_cObject);
  rb_define_alloc_func(globals->geos_multi_polygon, alloc_geometry);

  // Wrap the globals in a Ruby object and store it off so we have access
  // to it later. Each factory instance will reference it internally.
  wrapped_globals = Data_Wrap_Struct(rb_cObject, mark_globals_func, destroy_globals_func, globals);
  rb_define_const(geos_factory_class, "INTERNAL_CGLOBALS", wrapped_globals);

  return globals;
}


/**** OTHER PUBLIC FUNCTIONS ****/


VALUE rgeo_wrap_geos_geometry(VALUE factory, GEOSGeometry* geom, VALUE klass)
{
  VALUE result;
  RGeo_FactoryData* factory_data;
  GEOSContextHandle_t factory_context;
  VALUE klasses;
  RGeo_Globals* globals;
  VALUE inferred_klass;
  char is_collection;
  RGeo_GeometryData* data;

  result = Qnil;
  if (geom || !NIL_P(klass)) {
    factory_data = NIL_P(factory) ? NULL : RGEO_FACTORY_DATA_PTR(factory);
    factory_context = factory_data ? factory_data->geos_context : NULL;
    globals = factory_data ? factory_data->globals : NULL;

    // We don't allow "empty" points, so replace such objects with
    // an empty collection.
    if (geom && factory) {
      if (GEOSGeomTypeId_r(factory_context, geom) == GEOS_POINT && GEOSGetNumCoordinates_r(factory_context, geom) == 0) {
        GEOSGeom_destroy_r(factory_context, geom);
        geom = GEOSGeom_createCollection_r(factory_context, GEOS_GEOMETRYCOLLECTION, NULL, 0);
        klass = globals->geos_geometry_collection;
      }
    }

    klasses = Qnil;
    if (TYPE(klass) != T_CLASS) {
      inferred_klass = Qnil;
      is_collection = 0;
      switch (GEOSGeomTypeId_r(factory_context, geom)) {
      case GEOS_POINT:
        inferred_klass = globals->geos_point;
        break;
      case GEOS_LINESTRING:
        inferred_klass = globals->geos_line_string;
        break;
      case GEOS_LINEARRING:
        inferred_klass = globals->geos_linear_ring;
        break;
      case GEOS_POLYGON:
        inferred_klass = globals->geos_polygon;
        break;
      case GEOS_MULTIPOINT:
        inferred_klass = globals->geos_multi_point;
        is_collection = 1;
        break;
      case GEOS_MULTILINESTRING:
        inferred_klass = globals->geos_multi_line_string;
        is_collection = 1;
        break;
      case GEOS_MULTIPOLYGON:
        inferred_klass = globals->geos_multi_polygon;
        is_collection = 1;
        break;
      case GEOS_GEOMETRYCOLLECTION:
        inferred_klass = globals->geos_geometry_collection;
        is_collection = 1;
        break;
      default:
        inferred_klass = globals->geos_geometry;
        break;
      }
      if (TYPE(klass) == T_ARRAY && is_collection) {
        klasses = klass;
      }
      klass = inferred_klass;
    }
    data = ALLOC(RGeo_GeometryData);
    if (data) {
      if (geom) {
        GEOSSetSRID_r(factory_context, geom, factory_data->srid);
      }
      data->geos_context = factory_context;
      data->geom = geom;
      data->prep = factory_data && ((factory_data->flags & RGEO_FACTORYFLAGS_PREPARE_HEURISTIC) != 0) ?
        (GEOSPreparedGeometry*)1 : NULL;
      data->factory = factory;
      data->klasses = klasses;
      result = Data_Wrap_Struct(klass, mark_geometry_func, destroy_geometry_func, data);
    }
  }
  return result;
}


VALUE rgeo_wrap_geos_geometry_clone(VALUE factory, const GEOSGeometry* geom, VALUE klass)
{
  VALUE result;
  GEOSGeometry* clone_geom;

  result = Qnil;
  if (geom) {
    clone_geom = GEOSGeom_clone_r(RGEO_FACTORY_DATA_PTR(factory)->geos_context, geom);
    if (clone_geom) {
      result = rgeo_wrap_geos_geometry(factory, clone_geom, klass);
    }
  }
  return result;
}


const GEOSGeometry* rgeo_convert_to_geos_geometry(VALUE factory, VALUE obj, VALUE type)
{
  VALUE object;
  const GEOSGeometry* geom;
  RGeo_Globals* globals;

  if (NIL_P(type) && TYPE(obj) == T_DATA && RDATA(obj)->dfree == (RUBY_DATA_FUNC)destroy_geometry_func && RGEO_GEOMETRY_DATA_PTR(obj)->factory == factory) {
    object = obj;
  }
  else {
    globals = RGEO_FACTORY_DATA_PTR(factory)->globals;
    object = rb_funcall(globals->feature_module, globals->id_cast, 3, obj, factory, type);
  }
  geom = NULL;
  if (!NIL_P(object)) {
    geom = RGEO_GEOMETRY_DATA_PTR(object)->geom;
  }
  return geom;
}


GEOSGeometry* rgeo_convert_to_detached_geos_geometry(VALUE obj, VALUE factory, VALUE type, VALUE* klasses)
{
  VALUE object;
  GEOSGeometry* geom;
  RGeo_GeometryData* object_data;
  const GEOSPreparedGeometry* prep;
  RGeo_Globals* globals;

  if (klasses) {
    *klasses = Qnil;
  }
  globals = RGEO_FACTORY_DATA_PTR(factory)->globals;
  object = rb_funcall(globals->feature_module, globals->id_cast, 5, obj, factory, type, globals->sym_force_new, globals->sym_keep_subtype);
  geom = NULL;
  if (!NIL_P(object)) {
    object_data = RGEO_GEOMETRY_DATA_PTR(object);
    geom = object_data->geom;
    if (klasses) {
      *klasses = object_data->klasses;
      if (NIL_P(*klasses)) {
        *klasses = CLASS_OF(object);
      }
    }
    prep = object_data->prep;
    if (prep && prep != (GEOSPreparedGeometry*)1 && prep != (GEOSPreparedGeometry*)2) {
      GEOSPreparedGeom_destroy_r(object_data->geos_context, prep);
    }
    object_data->geos_context = NULL;
    object_data->geom = NULL;
    object_data->prep = NULL;
    object_data->factory = Qnil;
    object_data->klasses = Qnil;
  }
  return geom;
}


char rgeo_is_geos_object(VALUE obj)
{
  return (TYPE(obj) == T_DATA && RDATA(obj)->dfree == (RUBY_DATA_FUNC)destroy_geometry_func) ? 1 : 0;
}


const GEOSGeometry* rgeo_get_geos_geometry_safe(VALUE obj)
{
  return (TYPE(obj) == T_DATA && RDATA(obj)->dfree == (RUBY_DATA_FUNC)destroy_geometry_func) ? (const GEOSGeometry*)(RGEO_GEOMETRY_DATA_PTR(obj)->geom) : NULL;
}


VALUE rgeo_geos_coordseqs_eql(GEOSContextHandle_t context, const GEOSGeometry* geom1, const GEOSGeometry* geom2, char check_z)
{
  VALUE result;
  const GEOSCoordSequence* cs1;
  const GEOSCoordSequence* cs2;
  unsigned int len1;
  unsigned int len2;
  unsigned int i;
  double val1, val2;

  result = Qnil;
  if (geom1 && geom2) {
    cs1 = GEOSGeom_getCoordSeq_r(context, geom1);
    cs2 = GEOSGeom_getCoordSeq_r(context, geom2);
    if (cs1 && cs2) {
      len1 = 0;
      len2 = 0;
      if (GEOSCoordSeq_getSize_r(context, cs1, &len1) && GEOSCoordSeq_getSize_r(context, cs2, &len2)) {
        if (len1 == len2) {
          result = Qtrue;
          for (i=0; i<len1; ++i) {
            if (GEOSCoordSeq_getX_r(context, cs1, i, &val1) && GEOSCoordSeq_getX_r(context, cs2, i, &val2)) {
              if (val1 == val2) {
                if (GEOSCoordSeq_getY_r(context, cs1, i, &val1) && GEOSCoordSeq_getY_r(context, cs2, i, &val2)) {
                  if (val1 == val2) {
                    if (check_z) {
                      val1 = 0;
                      if (!GEOSCoordSeq_getZ_r(context, cs1, i, &val1)) {
                        result = Qnil;
                        break;
                      }
                      val2 = 0;
                      if (!GEOSCoordSeq_getZ_r(context, cs2, i, &val2)) {
                        result = Qnil;
                        break;
                      }
                      if (val1 != val2) {
                        result = Qfalse;
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
  }
  return result;
}


VALUE rgeo_geos_klasses_and_factories_eql(VALUE obj1, VALUE obj2)
{
  VALUE result;
  VALUE factory;

  result = Qnil;
  if (rb_obj_class(obj1) != rb_obj_class(obj2)) {
    result = Qfalse;
  }
  else {
    factory = RGEO_GEOMETRY_DATA_PTR(obj1)->factory;
    result = rb_funcall(factory, RGEO_FACTORY_DATA_PTR(factory)->globals->id_eql, 1, RGEO_GEOMETRY_DATA_PTR(obj2)->factory);
  }
  return result;
}


typedef struct {
  st_index_t seed_hash;
  double x;
  double y;
  double z;
} RGeo_Coordseq_Hash_Struct;

st_index_t rgeo_geos_coordseq_hash(GEOSContextHandle_t context, const GEOSGeometry* geom, st_index_t hash)
{
  const GEOSCoordSequence* cs;
  unsigned int len;
  unsigned int i;
  RGeo_Coordseq_Hash_Struct hash_struct;

  if (geom) {
    cs = GEOSGeom_getCoordSeq_r(context, geom);
    if (cs) {
      if (GEOSCoordSeq_getSize_r(context, cs, &len)) {
        for (i=0; i<len; ++i) {
          if (GEOSCoordSeq_getX_r(context, cs, i, &hash_struct.x)) {
            if (GEOSCoordSeq_getY_r(context, cs, i, &hash_struct.y)) {
              if (!GEOSCoordSeq_getY_r(context, cs, i, &hash_struct.z)) {
                hash_struct.z = 0;
              }
              hash_struct.seed_hash = hash;
              hash = rb_memhash(&hash_struct, sizeof(RGeo_Coordseq_Hash_Struct));
            }
          }
        }
      }
    }
  }
  return hash;
}


typedef struct {
  st_index_t seed_hash;
  st_index_t h1;
  st_index_t h2;
} RGeo_Objbase_Hash_Struct;

st_index_t rgeo_geos_objbase_hash(VALUE factory, VALUE type_module, st_index_t hash)
{
  ID hash_method;
  RGeo_Objbase_Hash_Struct hash_struct;

  hash_method = RGEO_FACTORY_DATA_PTR(factory)->globals->id_hash;
  hash_struct.seed_hash = hash;
  hash_struct.h1 = FIX2LONG(rb_funcall(factory, hash_method, 0));
  hash_struct.h2 = FIX2LONG(rb_funcall(type_module, hash_method, 0));
  return rb_memhash(&hash_struct, sizeof(RGeo_Objbase_Hash_Struct));
}


st_index_t rgeo_internal_memhash(const void* ptr, long len)
{
  const char* bytes;
  st_index_t hval;
  long i;

  bytes = (const char*)ptr;
  hval = 0x811c9dc5;
  for (i=0; i<len; ++i) {
    hval ^= (unsigned int)(*bytes++);
    hval *= 0x01000193;
  }
  return hval;
}


RGEO_END_C

#endif
