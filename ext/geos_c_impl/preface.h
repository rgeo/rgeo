/*
  Preface header for GEOS wrapper
*/


#ifdef HAVE_GEOS_C_H
#ifdef HAVE_GEOSSETSRID_R
#define RGEO_GEOS_SUPPORTED
#endif
#endif

#ifdef HAVE_GEOSPREPAREDCONTAINS_R
#define RGEO_GEOS_SUPPORTS_PREPARED1
#endif
#ifdef HAVE_GEOSPREPAREDDISJOINT_R
#define RGEO_GEOS_SUPPORTS_PREPARED2
#endif
#ifdef HAVE_GEOSWKTWWRITER_SETOUTPUTDIMENSION_R
#define RGEO_GEOS_SUPPORTS_SETOUTPUTDIMENSION
#endif
#ifdef HAVE_GEOSUNARYUNION_R
#define RGEO_GEOS_SUPPORTS_UNARYUNION
#endif
#ifdef HAVE_RB_MEMHASH
#define RGEO_SUPPORTS_NEW_HASHING
#endif

#ifndef RGEO_SUPPORTS_NEW_HASHING
#define st_index_t int
#define rb_memhash(x,y) rgeo_internal_memhash(x,y)
#define rb_hash_start(x) ((st_index_t)(x ^ 0xdeadbeef))
#define rb_hash_end(x) ((st_index_t)(x ^ 0xbeefdead))
#endif

#ifdef __cplusplus
#define RGEO_BEGIN_C extern "C" {
#define RGEO_END_C }
#else
#define RGEO_BEGIN_C
#define RGEO_END_C
#endif
