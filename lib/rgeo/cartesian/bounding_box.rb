# -----------------------------------------------------------------------------
#
# Cartesian bounding box
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

  module Cartesian


    # This is a bounding box for Cartesian data.
    # The simple cartesian implementation uses this internally to compute
    # envelopes. You may also use it directly to compute and represent
    # bounding boxes.
    #
    # A bounding box is a set of ranges in each dimension: X, Y, as well
    # as Z and M if supported. You can compute a bounding box for one or
    # more geometry objects by creating a new bounding box object, and
    # adding the geometries to it. You may then query it for the bounds,
    # or use it to determine whether it encloses other geometries or
    # bounding boxes.

    class BoundingBox


      # Create a new empty bounding box with the given factory.
      #
      # The factory defines the coordinate system for the bounding box,
      # and also defines whether it should track Z and M coordinates.
      # All geometries will be cast to this factory when added to this
      # bounding box, and any generated envelope geometry will have this
      # as its factory.
      #
      # Options include:
      #
      # [<tt>:ignore_z</tt>]
      #   If true, ignore z coordinates even if the factory supports them.
      #   Default is false.
      # [<tt>:ignore_m</tt>]
      #   If true, ignore m coordinates even if the factory supports them.
      #   Default is false.

      def initialize(factory_, opts_={})
        @factory = factory_
        @has_z = !opts_[:ignore_z] && factory_.property(:has_z_coordinate) ? true : false
        @has_m = !opts_[:ignore_m] && factory_.property(:has_m_coordinate) ? true : false
        @min_x = @max_x = @min_y = @max_y = @min_z = @max_z = @min_m = @max_m = nil
      end


      def eql?(rhs_)  # :nodoc:
        rhs_.is_a?(BoundingBox) && @factory == rhs_.factory &&
          @min_x == rhs_.min_x && @max_x == rhs_.max_x &&
          @min_y == rhs_.min_y && @max_y == rhs_.max_y &&
          @min_z == rhs_.min_z && @max_z == rhs_.max_z &&
          @min_m == rhs_.min_m && @max_m == rhs_.max_m
      end
      alias_method :==, :eql?


      # Returns the bounding box's factory.

      def factory
        @factory
      end


      # Returns true if this bounding box is still empty.

      def empty?
        @min_x.nil?
      end


      # Returns true if this bounding box tracks Z coordinates.

      def has_z
        @has_z
      end


      # Returns true if this bounding box tracks M coordinates.

      def has_m
        @has_m
      end


      # Returns the minimum X, or nil if this bounding box is empty.

      def min_x
        @min_x
      end


      # Returns the maximum X, or nil if this bounding box is empty.

      def max_x
        @max_x
      end


      # Returns the minimum Y, or nil if this bounding box is empty.

      def min_y
        @min_y
      end


      # Returns the maximum Y, or nil if this bounding box is empty.

      def max_y
        @max_y
      end


      # Returns the minimum Z, or nil if this bounding box is empty.

      def min_z
        @min_z
      end


      # Returns the maximum Z, or nil if this bounding box is empty.

      def max_z
        @max_z
      end


      # Returns the minimum M, or nil if this bounding box is empty.

      def min_m
        @min_m
      end


      # Returns the maximum M, or nil if this bounding box is empty.

      def max_m
        @max_m
      end


      # Returns a point representing the minimum extent in all dimensions,
      # or nil if this bounding box is empty.

      def min_point
        if @min_x
          extras_ = []
          extras_ << @min_z if @has_z
          extras_ << @min_m if @has_m
          @factory.point(@min_x, @min_y, *extras_)
        else
          nil
        end
      end


      # Returns a point representing the maximum extent in all dimensions,
      # or nil if this bounding box is empty.

      def max_point
        if @min_x
          extras_ = []
          extras_ << @max_z if @has_z
          extras_ << @max_m if @has_m
          @factory.point(@max_x, @max_y, *extras_)
        else
          nil
        end
      end


      # Adjusts the extents of this bounding box to encompass the given
      # object, which may be a geometry or another bounding box.
      # Returns self.

      def add(geometry_)
        case geometry_
        when BoundingBox
          add(geometry_.min_point)
          add(geometry_.max_point)
        when Feature::Geometry
          if geometry_.factory == @factory
            _add_geometry(geometry_)
          else
            _add_geometry(Factory.cast(geometry_, @factory))
          end
        end
        self
      end


      # Converts this bounding box to an envelope polygon.
      # Returns the empty collection if this bounding box is empty.

      def to_geometry
        if @min_x
          extras_ = []
          extras_ << @min_z if @has_z
          extras_ << @min_m if @has_m
          point_min_ = @factory.point(@min_x, @min_y, *extras_)
          if @min_x == @max_x && @min_y == @max_y
            point_min_
          else
            extras_ = []
            extras_ << @max_z if @has_z
            extras_ << @max_m if @has_m
            point_max_ = @factory.point(@max_x, @max_y, *extras_)
            if @min_x == @max_x || @min_y == @max_y
              @factory.line(point_min_, point_max_)
            else
              @factory.polygon(@factory.linear_ring([point_min_,
                @factory.point(@max_x, @min_y, *extras_), point_max_,
                @factory.point(@min_x, @max_y, *extras_), point_min_]))
            end
          end
        else
          @factory.collection([])
        end
      end


      # Returns true if this bounding box contains the given object,
      # which may be a geometry or another bounding box.
      #
      # Supports these options:
      #
      # [<tt>:ignore_z</tt>]
      #   Ignore the Z coordinate when testing, even if both objects
      #   have Z. Default is false.
      # [<tt>:ignore_m</tt>]
      #   Ignore the M coordinate when testing, even if both objects
      #   have M. Default is false.

      def contains?(rhs_, opts_={})
        if Feature::Geometry === rhs_
          contains?(BoundingBox.new(@factory).add(rhs_))
        elsif rhs_.empty?
          true
        elsif empty?
          false
        elsif @min_x > rhs_.min_x || @max_x < rhs_.max_x || @min_y > rhs_.min_y || @max_y < rhs_.max_y
          false
        elsif @has_m && rhs_.has_m && !opts_[:ignore_m] && (@min_m > rhs_.min_m || @max_m < rhs_.max_m)
          false
        elsif @has_z && rhs_.has_z && !opts_[:ignore_z] && (@min_z > rhs_.min_z || @max_z < rhs_.max_z)
          false
        else
          true
        end
      end


      def _add_geometry(geometry_)  # :nodoc:
        case geometry_
        when Feature::Point
          _add_point(geometry_)
        when Feature::LineString
          geometry_.points.each{ |p_| _add_point(p_) }
        when Feature::Polygon
          geometry_.exterior_ring.points.each{ |p_| _add_point(p_) }
        when Feature::MultiPoint
          geometry_.each{ |p_| _add_point(p_) }
        when Feature::MultiLineString
          geometry_.each{ |line_| line_.points.each{ |p_| _add_point(p_) } }
        when Feature::MultiPolygon
          geometry_.each{ |poly_| poly_.exterior_ring.points.each{ |p_| _add_point(p_) } }
        when Feature::GeometryCollection
          geometry_.each{ |g_| _add_geometry(g_) }
        end
      end


      def _add_point(point_)  # :nodoc:
        if @min_x
          x_ = point_.x
          @min_x = x_ if x_ < @min_x
          @max_x = x_ if x_ > @max_x
          y_ = point_.y
          @min_y = y_ if y_ < @min_y
          @max_y = y_ if y_ > @max_y
          if @has_z
            z_ = point_.z
            @min_z = z_ if z_ < @min_z
            @max_z = z_ if z_ > @max_z
          end
          if @has_m
            m_ = point_.m
            @min_m = m_ if m_ < @min_m
            @max_m = m_ if m_ > @max_m
          end
        else
          @min_x = @max_x = point_.x
          @min_y = @max_y = point_.y
          @min_z = @max_z = point_.z if @has_z
          @min_m = @max_m = point_.m if @has_m
        end
      end


    end


  end

end
