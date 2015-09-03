/*
  Geometry collection methods for GEOS wrapper
*/


#ifndef RGEO_GEOS_GEOMETRY_COLLECTION_INCLUDED
#define RGEO_GEOS_GEOMETRY_COLLECTION_INCLUDED

#include <ruby.h>
#include <geos_c.h>

#include "factory.h"

RGEO_BEGIN_C


/*
  Initializes the geometry collection module. This should be called after
  the geometry module is initialized.
*/
void rgeo_init_geos_geometry_collection(RGeo_Globals* globals);

/*
  Comopares the contents of two geometry collections. Does not test the
  types of the collections themselves, but tests the types, values, and
  contents of all the contents. The two given geometries MUST be
  collection types-- i.e. GeometryCollection, MultiPoint, MultiLineString,
  or MultiPolygon.
  Returns Qtrue if the contents of the two geometry collections are equal,
  Qfalse if they are inequal, or Qnil if an error occurs.
*/
VALUE rgeo_geos_geometry_collections_eql(GEOSContextHandle_t context, const GEOSGeometry* geom1, const GEOSGeometry* geom2, char check_z);

/*
  A tool for building up hash values.
  You must pass in the context, a geos geometry, and a seed hash.
  Returns an updated hash.
  This call is useful in sequence, and should be bracketed by calls to
  rb_hash_start and rb_hash_end.
*/
st_index_t rgeo_geos_geometry_collection_hash(GEOSContextHandle_t context, const GEOSGeometry* geom, st_index_t hash);


RGEO_END_C

#endif
