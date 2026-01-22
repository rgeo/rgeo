/*
  Preface header for GEOS wrapper

  Requires GEOS 3.14.0 or later (for M-coordinate support via GEOSCoordSeq_setM)
*/

// Minimum GEOS 3.14+ (native M-coordinate support)
#ifdef HAVE_GEOSCOORDSEQ_SETM
#define RGEO_GEOS_SUPPORTED
#endif

// Optional GEOS 3.14+ features that may not be in all builds
#ifdef HAVE_GEOSCLUSTERDBSCAN
#define RGEO_GEOS_CLUSTERING
#endif

#ifdef HAVE_GEOSLINESUBSTRING
#define RGEO_GEOS_LINE_SUBSTRING
#endif

#ifdef HAVE_GEOSCOVERAGEISVALID
#define RGEO_GEOS_COVERAGE
#endif

#ifdef HAVE_GEOSSISSIMPLEDETAIL
#define RGEO_GEOS_SIMPLE_DETAIL
#endif

// Legacy alias - all above features when available
#if defined(RGEO_GEOS_CLUSTERING) && defined(RGEO_GEOS_COVERAGE) &&            \
  defined(RGEO_GEOS_SIMPLE_DETAIL)
#define RGEO_GEOS_314
#endif

#ifdef HAVE_RB_GC_MARK_MOVABLE
#define mark rb_gc_mark_movable
#else
#define mark rb_gc_mark
#endif

#ifdef __cplusplus
#define RGEO_BEGIN_C                                                           \
  extern "C"                                                                   \
  {
#define RGEO_END_C }
#else
#define RGEO_BEGIN_C
#define RGEO_END_C
#endif

// https://ozlabs.org/~rusty/index.cgi/tech/2008-04-01.html
#define streq(a, b) (!strcmp((a), (b)))

// When using ruby ALLOC* macros, we are using ruby_xmalloc, which counterpart
// is ruby_xfree. This macro helps enforcing that by showing us the way.
#define FREE ruby_xfree
