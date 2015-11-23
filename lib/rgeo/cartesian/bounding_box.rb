# -----------------------------------------------------------------------------
#
# Cartesian bounding box
#
# -----------------------------------------------------------------------------

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
      # Create a bounding box given two corner points.
      # The bounding box will be given the factory of the first point.
      # You may also provide the same options available to
      # BoundingBox.new.

      def self.create_from_points(point1_, point2_, opts_ = {})
        factory_ = point1_.factory
        new(factory_, opts_)._add_geometry(point1_).add(point2_)
      end

      # Create a bounding box given a geometry to surround.
      # The bounding box will be given the factory of the geometry.
      # You may also provide the same options available to
      # BoundingBox.new.

      def self.create_from_geometry(geom_, opts_ = {})
        factory_ = geom_.factory
        new(factory_, opts_)._add_geometry(geom_)
      end

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

      def initialize(factory_, opts_ = {})
        @factory = factory_
        if (values_ = opts_[:raw])
          @has_z, @has_m, @min_x, @max_x, @min_y, @max_y, @min_z, @max_z, @min_m, @max_m = values_
        else
          @has_z = !opts_[:ignore_z] && factory_.property(:has_z_coordinate) ? true : false
          @has_m = !opts_[:ignore_m] && factory_.property(:has_m_coordinate) ? true : false
          @min_x = @max_x = @min_y = @max_y = @min_z = @max_z = @min_m = @max_m = nil
        end
      end

      def eql?(rhs_) # :nodoc:
        rhs_.is_a?(BoundingBox) && @factory == rhs_.factory &&
          @min_x == rhs_.min_x && @max_x == rhs_.max_x &&
          @min_y == rhs_.min_y && @max_y == rhs_.max_y &&
          @min_z == rhs_.min_z && @max_z == rhs_.max_z &&
          @min_m == rhs_.min_m && @max_m == rhs_.max_m
      end
      alias_method :==, :eql?

      # Returns the bounding box's factory.

      attr_reader :factory

      # Returns true if this bounding box is still empty.

      def empty?
        @min_x.nil?
      end

      # Returns true if this bounding box is degenerate. That is,
      # it is nonempty but contains only a single point because both
      # the X and Y spans are 0. Infinitesimal boxes are also
      # always degenerate.

      def infinitesimal?
        @min_x && @min_x == @max_x && @min_y == @max_y
      end

      # Returns true if this bounding box is degenerate. That is,
      # it is nonempty but has zero area because either or both
      # of the X or Y spans are 0.

      def degenerate?
        @min_x && (@min_x == @max_x || @min_y == @max_y)
      end

      # Returns true if this bounding box tracks Z coordinates.

      attr_reader :has_z

      # Returns true if this bounding box tracks M coordinates.

      attr_reader :has_m

      # Returns the minimum X, or nil if this bounding box is empty.

      attr_reader :min_x

      # Returns the maximum X, or nil if this bounding box is empty.

      attr_reader :max_x

      # Returns the midpoint X, or nil if this bounding box is empty.

      def center_x
        @max_x ? (@max_x + @min_x) * 0.5 : nil
      end

      # Returns the X span, or 0 if this bounding box is empty.

      def x_span
        @max_x ? @max_x - @min_x : 0
      end

      # Returns the minimum Y, or nil if this bounding box is empty.

      attr_reader :min_y

      # Returns the maximum Y, or nil if this bounding box is empty.

      attr_reader :max_y

      # Returns the midpoint Y, or nil if this bounding box is empty.

      def center_y
        @max_y ? (@max_y + @min_y) * 0.5 : nil
      end

      # Returns the Y span, or 0 if this bounding box is empty.

      def y_span
        @max_y ? @max_y - @min_y : 0
      end

      # Returns the minimum Z, or nil if this bounding box is empty.

      attr_reader :min_z

      # Returns the maximum Z, or nil if this bounding box is empty.

      attr_reader :max_z

      # Returns the midpoint Z, or nil if this bounding box is empty or has no Z.

      def center_z
        @max_z ? (@max_z + @min_z) * 0.5 : nil
      end

      # Returns the Z span, 0 if this bounding box is empty, or nil if it has no Z.

      def z_span
        @has_z ? (@max_z ? @max_z - @min_z : 0) : nil
      end

      # Returns the minimum M, or nil if this bounding box is empty.

      attr_reader :min_m

      # Returns the maximum M, or nil if this bounding box is empty.

      attr_reader :max_m

      # Returns the midpoint M, or nil if this bounding box is empty or has no M.

      def center_m
        @max_m ? (@max_m + @min_m) * 0.5 : nil
      end

      # Returns the M span, 0 if this bounding box is empty, or nil if it has no M.

      def m_span
        @has_m ? (@max_m ? @max_m - @min_m : 0) : nil
      end

      # Returns a point representing the minimum extent in all dimensions,
      # or nil if this bounding box is empty.

      def min_point
        if @min_x
          extras_ = []
          extras_ << @min_z if @has_z
          extras_ << @min_m if @has_m
          @factory.point(@min_x, @min_y, *extras_)
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
            _add_geometry(Feature.cast(geometry_, @factory))
          end
        end
        self
      end

      # Converts this bounding box to an envelope, which will be the
      # empty collection (if the bounding box is empty), a point (if the
      # bounding box is not empty but both spans are 0), a line (if only
      # one of the two spans is 0) or a polygon (if neither span is 0).

      def to_geometry
        if @min_x
          extras_ = []
          extras_ << @min_z if @has_z
          extras_ << @min_m if @has_m
          point_min_ = @factory.point(@min_x, @min_y, *extras_)
          if infinitesimal?
            point_min_
          else
            extras_ = []
            extras_ << @max_z if @has_z
            extras_ << @max_m if @has_m
            point_max_ = @factory.point(@max_x, @max_y, *extras_)
            if degenerate?
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

      def contains?(rhs_, opts_ = {})
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

      # Returns this bounding box subdivided, as an array of bounding boxes.
      # If this bounding box is empty, returns the empty array.
      # If this bounding box is a point, returns a one-element array
      # containing the current point.
      # If the x or y span is 0, bisects the line.
      # Otherwise, generally returns a 4-1 subdivision in the X-Y plane.
      # Does not subdivide on Z or M.
      #
      # [<tt>:bisect_factor</tt>]
      #   An optional floating point value that should be greater than 1.0.
      #   If the ratio between the larger span and the smaller span is
      #   greater than this factor, the bounding box is divided only in
      #   half instead of fourths.

      def subdivide(opts_ = {})
        return [] if empty?
        if infinitesimal?
          return [
            BoundingBox.new(@factory, raw: [@has_z, @has_m,
                                            @min_x, @max_x, @min_y, @max_y, @min_z, @max_z, @min_m, @max_m])
          ]
        end
        factor_ = opts_[:bisect_factor]
        factor_ ||= 1 if degenerate?
        if factor_
          if x_span > y_span * factor_
            return [
              BoundingBox.new(@factory, raw: [@has_z, @has_m,
                                              @min_x, center_x, @min_y, @max_y, @min_z, @max_z, @min_m, @max_m]),
              BoundingBox.new(@factory, raw: [@has_z, @has_m,
                                              center_x, @max_x, @min_y, @max_y, @min_z, @max_z, @min_m, @max_m])
            ]
          elsif y_span > x_span * factor_
            return [
              BoundingBox.new(@factory, raw: [@has_z, @has_m,
                                              @min_x, @max_x, @min_y, center_y, @min_z, @max_z, @min_m, @max_m]),
              BoundingBox.new(@factory, raw: [@has_z, @has_m,
                                              @min_x, @max_x, center_y, @max_y, @min_z, @max_z, @min_m, @max_m])
            ]
          end
        end
        [
          BoundingBox.new(@factory, raw: [@has_z, @has_m,
                                          @min_x, center_x, @min_y, center_y, @min_z, @max_z, @min_m, @max_m]),
          BoundingBox.new(@factory, raw: [@has_z, @has_m,
                                          center_x, @max_x, @min_y, center_y, @min_z, @max_z, @min_m, @max_m]),
          BoundingBox.new(@factory, raw: [@has_z, @has_m,
                                          @min_x, center_x, center_y, @max_y, @min_z, @max_z, @min_m, @max_m]),
          BoundingBox.new(@factory, raw: [@has_z, @has_m,
                                          center_x, @max_x, center_y, @max_y, @min_z, @max_z, @min_m, @max_m])
        ]
      end

      def _add_geometry(geometry_) # :nodoc:
        case geometry_
        when Feature::Point
          _add_point(geometry_)
        when Feature::LineString
          geometry_.points.each { |p_| _add_point(p_) }
        when Feature::Polygon
          geometry_.exterior_ring.points.each { |p_| _add_point(p_) }
        when Feature::MultiPoint
          geometry_.each { |p_| _add_point(p_) }
        when Feature::MultiLineString
          geometry_.each { |line_| line_.points.each { |p_| _add_point(p_) } }
        when Feature::MultiPolygon
          geometry_.each { |poly_| poly_.exterior_ring.points.each { |p_| _add_point(p_) } }
        when Feature::GeometryCollection
          geometry_.each { |g_| _add_geometry(g_) }
        end
        self
      end

      def _add_point(point_) # :nodoc:
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
