# -----------------------------------------------------------------------------
#
# Common methods for Point features
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

  module ImplHelper  # :nodoc:


    module BasicPointMethods  # :nodoc:


      def initialize(factory_, x_, y_, *extra_)
        _set_factory(factory_)
        @x = x_.to_f
        @y = y_.to_f
        @z = factory_.property(:has_z_coordinate) ? extra_.shift.to_f : nil
        @m = factory_.property(:has_m_coordinate) ? extra_.shift.to_f : nil
        if extra_.size > 0
          raise ::ArgumentError, "Too many arguments for point initializer"
        end
        _validate_geometry
      end


      def x
        @x
      end


      def y
        @y
      end


      def z
        @z
      end


      def m
        @m
      end


      def dimension
        0
      end


      def geometry_type
        Feature::Point
      end


      def is_empty?
        false
      end


      def is_simple?
        true
      end


      def envelope
        self
      end


      def boundary
        factory.collection([])
      end


      def convex_hull
        self
      end


      def equals?(rhs_)
        return false unless rhs_.is_a?(self.class) && rhs_.factory == self.factory
        case rhs_
        when Feature::Point
          rhs_.x == @x && rhs_.y == @y
        when Feature::LineString
          rhs_.num_points > 0 && rhs_.points.all?{ |elem_| equals?(elem_) }
        when Feature::GeometryCollection
          rhs_.num_geometries > 0 && rhs_.all?{ |elem_| equals?(elem_) }
        else
          false
        end
      end


      def rep_equals?(rhs_)
        rhs_.is_a?(self.class) && rhs_.factory.eql?(@factory) && @x == rhs_.x && @y == rhs_.y && @z == rhs_.z && @m == rhs_.m
      end


    end


  end

end
