/*
  -----------------------------------------------------------------------------

  Line string methods for GEOS wrapper

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


#ifndef RGEO_GEOS_LINE_STRING_INCLUDED
#define RGEO_GEOS_LINE_STRING_INCLUDED

#include <ruby.h>
#include <geos_c.h>

#include "factory.h"

RGEO_BEGIN_C


/*
  Initializes the line string module. This should be called after
  the geometry module is initialized.
*/
void rgeo_init_geos_line_string(RGeo_Globals* globals);

/*
  Determines whether the given GEOS line string is closed.
  Returns Qtrue if true, Qfalse if false, or Qnil on an error.
*/
VALUE rgeo_is_geos_line_string_closed(GEOSContextHandle_t context, const GEOSGeometry* geom);


RGEO_END_C

#endif
