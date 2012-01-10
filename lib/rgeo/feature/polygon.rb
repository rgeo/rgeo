# -----------------------------------------------------------------------------
#
# Polygon feature interface
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
    # A Polygon is a planar Surface defined by 1 exterior boundary and 0 or
    # more interior boundaries. Each interior boundary defines a hole in
    # the Polygon.
    #
    # The assertions for Polygons (the rules that define valid Polygons)
    # are as follows:
    #
    # (a) Polygons are topologically closed;
    #
    # (b) The boundary of a Polygon consists of a set of LinearRings that
    # make up its exterior and interior boundaries;
    #
    # (c) No two Rings in the boundary cross and the Rings in the boundary
    # of a Polygon may intersect at a Point but only as a tangent;
    #
    # (d) A Polygon may not have cut lines, spikes or punctures;
    #
    # (e) The interior of every Polygon is a connected point set;
    #
    # (f) The exterior of a Polygon with 1 or more holes is not connected.
    # Each hole defines a connected component of the exterior.
    #
    # In the above assertions, interior, closure and exterior have the
    # standard topological definitions. The combination of (a) and (c) make
    # a Polygon a regular closed Point set.
    #
    # Polygons are simple geometric objects.
    #
    # == Notes
    #
    # Polygon is defined as a module and is provided primarily
    # for the sake of documentation. Implementations need not necessarily
    # include this module itself. Therefore, you should not depend on the
    # kind_of? method to check type. Instead, use the provided check_type
    # class method (or === operator) defined in the Type module.

    module Polygon

      include Surface
      extend Type


      # === SFS 1.1 Description
      #
      # Returns the exterior ring of this Polygon.
      #
      # === Notes
      #
      # Returns an object that supports the LinearRing interface.

      def exterior_ring
        raise Error::UnsupportedOperation, "Method Polygon#exterior_ring not defined."
      end


      # === SFS 1.1 Description
      #
      # Returns the number of interiorRings in this Polygon.
      #
      # === Notes
      #
      # Returns an integer.

      def num_interior_rings
        raise Error::UnsupportedOperation, "Method Polygon#num_interior_rings not defined."
      end


      # === SFS 1.1 Description
      #
      # Returns the Nth interiorRing for this Polygon as a LineString.
      #
      # === Notes
      #
      # Returns an object that supports the LinearRing interface, or nil
      # if the given N is out of range. N is zero-based.
      # Does not support negative indexes.

      def interior_ring_n(n_)
        raise Error::UnsupportedOperation, "Method Polygon#interior_ring_n not defined."
      end


      # Returns the interior rings as a (possibly empty) array of objects
      # that support the LinearRing interface.

      def interior_rings
        raise Error::UnsupportedOperation, "Method Polygon#interior_rings not defined."
      end


    end


  end

end
