/*
  Geometry base class methods for GEOS wrapper
*/


#ifndef RGEO_GEOS_GEOMETRY_INCLUDED
#define RGEO_GEOS_GEOMETRY_INCLUDED

#include "factory.h"

RGEO_BEGIN_C


/*
  Initializes the geometry module. This should be called after the factory
  module is initialized, but before any of the other modules.
*/
void rgeo_init_geos_geometry(RGeo_Globals* globals);


RGEO_END_C

#endif
