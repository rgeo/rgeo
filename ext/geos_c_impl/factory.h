/*
  Factory and utility functions for GEOS wrapper
*/

#ifndef RGEO_GEOS_FACTORY_INCLUDED
#define RGEO_GEOS_FACTORY_INCLUDED

#include <ruby.h>
#include <geos_c.h>

RGEO_BEGIN_C

/*
  Wrapped structure for Factory objects.
  A factory encapsulates the GEOS context, and GEOS serializer settings.
  It also stores the SRID for all geometries created by this factory,
  and the resolution for buffers created for this factory's geometries.
*/
typedef struct {
  GEOSContextHandle_t geos_context;
  GEOSWKTReader* wkt_reader;
  GEOSWKBReader* wkb_reader;
  GEOSWKTWriter* wkt_writer;
  GEOSWKBWriter* wkb_writer;
  VALUE wkrep_wkt_generator;
  VALUE wkrep_wkb_generator;
  VALUE wkrep_wkt_parser;
  VALUE wkrep_wkb_parser;
  GEOSWKTReader* psych_wkt_reader;
  GEOSWKBReader* marshal_wkb_reader;
  GEOSWKTWriter* psych_wkt_writer;
  GEOSWKBWriter* marshal_wkb_writer;
  VALUE proj4_obj;
  VALUE coord_sys_obj;
  int flags;
  int srid;
  int buffer_resolution;
} RGeo_FactoryData;

#define RGEO_FACTORYFLAGS_LENIENT_MULTIPOLYGON 1
#define RGEO_FACTORYFLAGS_SUPPORTS_Z 2
#define RGEO_FACTORYFLAGS_SUPPORTS_M 4
#define RGEO_FACTORYFLAGS_SUPPORTS_Z_OR_M 6
#define RGEO_FACTORYFLAGS_PREPARE_HEURISTIC 8


/*
  Wrapped structure for Geometry objects.
  Includes a handle to the underlying GEOS geometry itself (which could
  be null for an uninitialized geometry).
  It also provides a handle to the factory that created this geometry.

  The klasses object is used by geometry collections. Its value is
  generally an array of the ruby classes for the colletion's elements,
  so that we can reproduce the exact class for those elements in cases
  where the class cannot be inferred directly from the GEOS type (as
  in Line objects, which have no GEOS type). Any array element, or the
  array itself, could be Qnil, indicating fall back to the default
  inferred from the GEOS type.

  The GEOS context handle is also included here. Ideally, it would be
  available by following the factory reference and getting it from the
  factory data. However, one use case is in the destroy_geometry_func
  in factory.c, and Rubinius 1.1.1 seems to crash when you try to
  evaluate a DATA_PTR from that function, so we copy the context handle
  here so the destroy_geometry_func can get to it.
*/
typedef struct {
  GEOSContextHandle_t geos_context;
  GEOSGeometry* geom;
  const GEOSPreparedGeometry* prep;
  VALUE factory;
  VALUE klasses;
} RGeo_GeometryData;


// Data types which indicate how RGeo types should be managed by Ruby.
extern const rb_data_type_t rgeo_factory_type;

extern const rb_data_type_t rgeo_geometry_type;


// Convenient macros for checking the type of data from Ruby
#define RGEO_FACTORY_TYPEDDATA_P(object) (_RGEO_TYPEDDATA_P(object, &rgeo_factory_type))
#define RGEO_GEOMETRY_TYPEDDATA_P(object) (_RGEO_TYPEDDATA_P(object, &rgeo_geometry_type))

#define _RGEO_TYPEDDATA_P(object, data_type) (TYPE(object) == T_DATA && RTYPEDDATA(object)->typed_flag == 1 && RTYPEDDATA(object)->type == data_type)

// Returns the RGeo_FactoryData* given a ruby Factory object
#define RGEO_FACTORY_DATA_PTR(factory) ((RGeo_FactoryData*)RTYPEDDATA_DATA(factory))

// Returns the RGeo_GeometryData* given a ruby Geometry object
#define RGEO_GEOMETRY_DATA_PTR(geometry) ((RGeo_GeometryData*)RTYPEDDATA_DATA(geometry))


/*
  Initializes the factory module. This should be called first in the
  initialization process.
*/
void rgeo_init_geos_factory();

/*
  Given a GEOS geometry handle, wraps it in a ruby Geometry object of the
  given klass. The geometry is then owned by the ruby object, so make sure
  you clone the GEOS object first if something else thinks it owns it.
  You may pass Qnil for the klass to have the klass auto-detected. (But
  note that it cannot auto-detect the Line type because GEOS doesn't
  explicitly represent that type-- it will come out as LineString.)
  You may also pass a ruby Array for the klass if the geometry is a
  collection of some sort. In this case, the array elements should be the
  classes for the elements of the collection.
  Returns Qnil if the wrapping failed for any reason.
*/
VALUE rgeo_wrap_geos_geometry(VALUE factory, GEOSGeometry* geom, VALUE klass);

/*
  Same as rgeo_wrap_geos_geometry except that it wraps a clone of the
  given geom, so the original geom doesn't change ownership.
*/
VALUE rgeo_wrap_geos_geometry_clone(VALUE factory, const GEOSGeometry* geom, VALUE klass);

/*
  Gets the GEOS geometry for a given ruby Geometry object. If the given
  ruby object is not a GEOS geometry implementation, it is converted to a
  GEOS implementation first. You may also optionally cast it to a type,
  specified by an appropriate feature module. Passing Qnil for the type
  disables this auto-cast. The returned GEOS geometry is owned by rgeo,
  and you should not dispose it or take ownership of it yourself.
*/
const GEOSGeometry* rgeo_convert_to_geos_geometry(VALUE factory, VALUE obj, VALUE type);

/*
  Gets a GEOS geometry for a given ruby Geometry object. You must provide
  a GEOS factory for the geometry; the object is cast to that factory if
  it is not already of it. You may also optionally cast it to a type,
  specified by an appropriate feature module. Passing Qnil for the type
  disables this auto-cast. The returned GEOS geometry is owned by the
  caller-- that is, if the original ruby object is already of the desired
  factory, the returned GEOS geometry is a clone of the original.

  If the klasses parameter is not NULL, its referent is set to the
  klasses saved in the original ruby Geometry object (if any), or else to
  the class of the converted GEOS object. This is so that you can use the
  result of this function to build a GEOS-backed clone of the original
  geometry, or to include the given geometry in a collection while keeping
  the klasses intact.
*/
GEOSGeometry* rgeo_convert_to_detached_geos_geometry(VALUE obj, VALUE factory, VALUE type, VALUE* klasses);

/*
  Returns 1 if the given ruby object is a GEOS Geometry implementation,
  or 0 if not.
*/
char rgeo_is_geos_object(VALUE obj);

/*
  Raises a rgeo error if the object is not a GEOS Geometry implementation.
*/
void rgeo_check_geos_object(VALUE obj);

/*
  Gets the underlying GEOS geometry for a given ruby object. Returns NULL
  if the given ruby object is not a GEOS geometry wrapper.
*/
const GEOSGeometry* rgeo_get_geos_geometry_safe(VALUE obj);

/*
  Compares the coordinate sequences for two given GEOS geometries.
  The two given geometries MUST be of types backed directly by
  coordinate sequences-- i.e. points or line strings.
  Returns Qtrue if the two coordinate sequences are equal, Qfalse
  if they are inequal, or Qnil if an error occurs.
*/
VALUE rgeo_geos_coordseqs_eql(GEOSContextHandle_t context, const GEOSGeometry* geom1, const GEOSGeometry* geom2, char check_z);

/*
  Compares the ruby classes and geometry factories of the two given ruby
  objects. Returns Qtrue if everything is equal (that is, the two objects
  are of the same type and factory), or Qfalse otherwise.
*/
VALUE rgeo_geos_klasses_and_factories_eql(VALUE obj1, VALUE obj2);

/*
  A tool for building up hash values.
  You must pass in the context, a geos geometry, and a seed hash.
  Returns an updated hash.
  This call is useful in sequence, and should be bracketed by calls to
  rb_hash_start and rb_hash_end.
*/
st_index_t rgeo_geos_coordseq_hash(GEOSContextHandle_t context, const GEOSGeometry* geom, st_index_t hash);

/*
  A tool for building up hash values.
  You must pass in a factory, a feature type module, and a seed hash.
  Returns an updated hash.
  This call is useful in sequence, and should be bracketed by calls to
  rb_hash_start and rb_hash_end.
*/
st_index_t rgeo_geos_objbase_hash(VALUE factory, VALUE type_module, st_index_t hash);

/*
  Internal tool for creating simple (FNV-1A 32 bit) hashes.
*/
st_index_t rgeo_internal_memhash(const void* ptr, long len);


RGEO_END_C

#endif
