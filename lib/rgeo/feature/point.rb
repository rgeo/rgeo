# -----------------------------------------------------------------------------
#
# Point feature interface
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
    # A Point is a 0-dimensional geometric object and represents a single
    # location in coordinate space. A Point has an x-coordinate value and
    # a y-coordinate value.
    #
    # The boundary of a Point is the empty set.
    #
    # == Notes
    #
    # Point is defined as a module and is provided primarily
    # for the sake of documentation. Implementations need not necessarily
    # include this module itself. Therefore, you should not depend on the
    # kind_of? method to check type. Instead, use the provided check_type
    # class method (or === operator) defined in the Type module.
    #
    # Some implementations may support higher dimensional points.

    module Point

      include Geometry
      extend Type


      # === SFS 1.1 Description
      #
      # The x-coordinate value for this Point.
      #
      # === Notes
      #
      # Returns a floating-point scalar value.

      def x
        raise Error::UnsupportedOperation, "Method Point#x not defined."
      end


      # === SFS 1.1 Description
      #
      # The y-coordinate value for this Point.
      #
      # === Notes
      #
      # Returns a floating-point scalar value.

      def y
        raise Error::UnsupportedOperation, "Method Point#y not defined."
      end


      # Returns the z-coordinate for this Point as a floating-point
      # scalar value.
      #
      # This method may not be available if the point's factory does
      # not support Z coordinates.

      def z
        raise Error::UnsupportedOperation, "Method Point#z not defined."
      end


      # Returns the m-coordinate for this Point as a floating-point
      # scalar value.
      #
      # This method may not be available if the point's factory does
      # not support M coordinates.

      def m
        raise Error::UnsupportedOperation, "Method Point#m not defined."
      end


    end


  end

end
