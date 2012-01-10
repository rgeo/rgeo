# -----------------------------------------------------------------------------
#
# Curve feature interface
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
    # A Curve is a 1-dimensional geometric object usually stored as a
    # sequence of Points, with the subtype of Curve specifying the form of
    # the interpolation between Points. This part of ISO 19125 defines only
    # one subclass of Curve, LineString, which uses linear interpolation
    # between Points.
    #
    # A Curve is a 1-dimensional geometric object that is the homeomorphic
    # image of a real, closed interval D=[a,b] under a mapping f:[a,b]->R2.
    #
    # A Curve is simple if it does not pass through the same Point twice.
    #
    # A Curve is closed if its start Point is equal to its end Point.
    #
    # The boundary of a closed Curve is empty.
    #
    # A Curve that is simple and closed is a Ring.
    #
    # The boundary of a non-closed Curve consists of its two end Points.
    #
    # A Curve is defined as topologically closed.
    #
    # == Notes
    #
    # Curve is defined as a module and is provided primarily
    # for the sake of documentation. Implementations need not necessarily
    # include this module itself. Therefore, you should not depend on the
    # kind_of? method to check type. Instead, use the provided check_type
    # class method (or === operator) defined in the Type module.
    #
    # Some implementations may support higher dimensional points.

    module Curve

      include Geometry
      extend Type


      # === SFS 1.1 Description
      #
      # The length of this Curve in its associated spatial reference.
      #
      # === Notes
      #
      # Returns a floating-point scalar value.

      def length
        raise Error::UnsupportedOperation, "Method Curve#length not defined."
      end


      # === SFS 1.1 Description
      #
      # The start Point of this Curve.
      #
      # === Notes
      #
      # Returns an object that supports the Point interface.

      def start_point
        raise Error::UnsupportedOperation, "Method Curve#start_point not defined."
      end


      # === SFS 1.1 Description
      #
      # The end Point of this Curve.
      #
      # === Notes
      #
      # Returns an object that supports the Point interface.

      def end_point
        raise Error::UnsupportedOperation, "Method Curve#end_point not defined."
      end


      # === SFS 1.1 Description
      #
      # Returns true if this Curve is closed [StartPoint() = EndPoint()].
      #
      # === Notes
      #
      # Returns a boolean value. Note that this is different from the SFS
      # specification, which stipulates an integer return value.

      def is_closed?
        raise Error::UnsupportedOperation, "Method Curve#is_closed? not defined."
      end


      # === SFS 1.1 Description
      #
      # Returns true if this Curve is closed [StartPoint() = EndPoint()]
      # and this Curve is simple (does not pass through the same Point
      # more than once).
      #
      # === Notes
      #
      # Returns a boolean value. Note that this is different from the SFS
      # specification, which stipulates an integer return value.

      def is_ring?
        raise Error::UnsupportedOperation, "Method Curve#is_ring? not defined."
      end


    end


  end

end
