# -----------------------------------------------------------------------------
#
# Surface feature interface
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
    # A Surface is a 2-dimensional geometric object.
    #
    # A simple Surface consists of a single "patch" that is associated with
    # one "exterior boundary" and 0 or more "interior" boundaries. Simple
    # Surfaces in 3-dimensional space are isomorphic to planar Surfaces.
    # Polyhedral Surfaces are formed by "stitching" together simple
    # Surfaces along their boundaries, polyhedral Surfaces in 3-dimensional
    # space may not be planar as a whole.
    #
    # The boundary of a simple Surface is the set of closed Curves
    # corresponding to its "exterior" and "interior" boundaries.
    #
    # The only instantiable subclass of Surface defined in this
    # specification, Polygon, is a simple Surface that is planar.
    #
    # == Notes
    #
    # Surface is defined as a module and is provided primarily
    # for the sake of documentation. Implementations need not necessarily
    # include this module itself. Therefore, you should not depend on the
    # kind_of? method to check type. Instead, use the provided check_type
    # class method (or === operator) defined in the Type module.
    #
    # Some implementations may support higher dimensional points.

    module Surface

      include Geometry
      extend Type


      # === SFS 1.1 Description
      #
      # The area of this Surface, as measured in the spatial reference
      # system of this Surface.
      #
      # === Notes
      #
      # Returns a floating-point scalar value.

      def area
        raise Error::UnsupportedOperation, "Method Surface#area not defined."
      end


      # === SFS 1.1 Description
      #
      # The mathematical centroid for this Surface as a Point. The result
      # is not guaranteed to be on this Surface.
      #
      # === Notes
      #
      # Returns an object that supports the Point interface.

      def centroid
        raise Error::UnsupportedOperation, "Method Surface#centroid not defined."
      end


      # === SFS 1.1 Description
      #
      # A Point guaranteed to be on this Surface.
      #
      # === Notes
      #
      # Returns an object that supports the Point interface.

      def point_on_surface
        raise Error::UnsupportedOperation, "Method Surface#point_on_surface not defined."
      end


    end


  end

end
