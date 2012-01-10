/*
  -----------------------------------------------------------------------------

  Geometry collection methods for GEOS wrapper

  -----------------------------------------------------------------------------
  Copyright 2010-2012 Daniel Azuma

  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
  * Neither the name of the copyright holder, nor the names of any other
    contributors to this software, may be used to endorse or promote products
    derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
  -----------------------------------------------------------------------------
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


RGEO_END_C

#endif
