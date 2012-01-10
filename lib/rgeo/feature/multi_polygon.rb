# -----------------------------------------------------------------------------
#
# MultiPolygon feature interface
#
# -----------------------------------------------------------------------------
# Copyright 2010-2012 Daniel Azuma
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the copyright holder, nor the names of any other
#   contributors to this software, may be used to endorse or promote products
#   derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# -----------------------------------------------------------------------------
;


module RGeo

  module Feature


    # == SFS 1.1 Description
    #
    # A MultiPolygon is a MultiSurface whose elements are Polygons.
    #
    # The assertions for MultiPolygons are as follows.
    #
    # a) The interiors of 2 Polygons that are elements of a MultiPolygon
    # may not intersect.
    #
    # b) The boundaries of any 2 Polygons that are elements of a
    # MultiPolygon may not "cross" and may touch at only a finite number
    # of Points. NOTE: Crossing is prevented by assertion (a) above.
    #
    # c) A MultiPolygon is defined as topologically closed.
    #
    # d) A MultiPolygon may not have cut lines, spikes or punctures, a
    # MultiPolygon is a regular closed Point set:
    #
    # e) The interior of a MultiPolygon with more than 1 Polygon is not
    # connected, the number of connected components of the interior of a
    # MultiPolygon is equal to the number of Polygons in the MultiPolygon.
    #
    # The boundary of a MultiPolygon is a set of closed Curves
    # (LineStrings) corresponding to the boundaries of its element
    # Polygons. Each Curve in the boundary of the MultiPolygon is in the
    # boundary of exactly 1 element Polygon, and every Curve in the
    # boundary of an element Polygon is in the boundary of the
    # MultiPolygon.
    #
    # NOTE: The subclass of Surface named Polyhedral Surface is a faceted
    # Surface whose facets are Polygons. A Polyhedral Surface is not a
    # MultiPolygon because it violates the rule for MultiPolygons that the
    # boundaries of the element Polygons intersect only at a finite number
    # of Points.
    #
    # == Notes
    #
    # MultiPolygon is defined as a module and is provided primarily
    # for the sake of documentation. Implementations need not necessarily
    # include this module itself. Therefore, you should not depend on the
    # kind_of? method to check type. Instead, use the provided check_type
    # class method (or === operator) defined in the Type module.

    module MultiPolygon

      include MultiSurface
      extend Type


    end


  end

end
