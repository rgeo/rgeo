/*
  Geometry base class methods for GEOS wrapper
*/


#ifndef RGEO_GEOS_GEOMETRY_INCLUDED
#define RGEO_GEOS_GEOMETRY_INCLUDED

RGEO_BEGIN_C


/*
  Initializes the geometry module. This should be called after the factory
  module is initialized, but before any of the other modules.
*/
void rgeo_init_geos_geometry();


RGEO_END_C

#endif
