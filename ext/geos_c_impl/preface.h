/*
  Preface header for GEOS wrapper

  Requires GEOS 3.14.0 or later
*/

// Minimum GEOS 3.12+ (native M-coordinate support)
#ifdef HAVE_GEOSCOORDSEQ_SETM
#define RGEO_GEOS_SUPPORTED
#endif

// GEOS 3.14+ features (optional)
#ifdef HAVE_GEOSLINESUBSTRING
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
