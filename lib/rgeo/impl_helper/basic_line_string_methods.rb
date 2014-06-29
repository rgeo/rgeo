# -----------------------------------------------------------------------------
#
# Common methods for LineString features
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


    module BasicLineStringMethods  # :nodoc:


      def initialize(factory_, points_)
        _set_factory(factory_)
        @points = points_.map do |elem_|
          elem_ = Feature.cast(elem_, factory_, Feature::Point)
          unless elem_
            raise Error::InvalidGeometry, "Could not cast #{elem_}"
          end
          elem_
        end
        _validate_geometry
      end


      def _validate_geometry
        if @points.size == 1
          raise Error::InvalidGeometry, 'LineString cannot have 1 point'
        end
      end


      def num_points
        @points.size
      end


      def point_n(n_)
        n_ < 0 ? nil : @points[n_]
      end


      def points
        @points.dup
      end


      def dimension
        1
      end


      def geometry_type
        Feature::LineString
      end


      def is_empty?
        @points.size == 0
      end


      def boundary
        array_ = []
        if !is_empty? && !is_closed?
          array_ << @points.first << @points.last
        end
        factory.multi_point([array_])
      end


      def start_point
        @points.first
      end


      def end_point
        @points.last
      end


      def is_closed?
        unless defined?(@is_closed)
          @is_closed = @points.size > 2 && @points.first == @points.last
        end
        @is_closed
      end


      def is_ring?
        is_closed? && is_simple?
      end


      def rep_equals?(rhs_)
        if rhs_.is_a?(self.class) && rhs_.factory.eql?(@factory) && @points.size == rhs_.num_points
          rhs_.points.each_with_index{ |p_, i_| return false unless @points[i_].rep_equals?(p_) }
        else
          false
        end
      end


      def hash
        @hash ||= begin
          hash_ = [factory, geometry_type].hash
          @points.inject(hash_){ |h_, p_| (1664525 * h_ + p_.hash).hash }
        end
      end


      def _copy_state_from(obj_)  # :nodoc:
        super
        @points = obj_.points
      end


    end


    module BasicLineMethods  # :nodoc:


      def initialize(factory_, start_, end_)
        _set_factory(factory_)
        cstart_ = Feature.cast(start_, factory_, Feature::Point)
        unless cstart_
          raise Error::InvalidGeometry, "Could not cast start: #{start_}"
        end
        cend_ = Feature.cast(end_, factory_, Feature::Point)
        unless cend_
          raise Error::InvalidGeometry, "Could not cast end: #{end_}"
        end
        @points = [cstart_, cend_]
        _validate_geometry
      end


      def _validate_geometry  # :nodoc:
        super
        if @points.size > 2
          raise Error::InvalidGeometry, 'Line must have 0 or 2 points'
        end
      end


      def geometry_type
        Feature::Line
      end


    end


    module BasicLinearRingMethods  # :nodoc:


      def _validate_geometry  # :nodoc:
        super
        if @points.size > 0
          @points << @points.first if @points.first != @points.last
          (1...@points.length-1).each do |i|
            @points.delete_at i if @points[i] == @points[i+1]
          end
          if !@factory.property(:uses_lenient_assertions) && !is_ring?
            raise Error::InvalidGeometry, 'LinearRing failed ring test'
          end
        end
      end


      def geometry_type
        Feature::LinearRing
      end


    end


  end

end
