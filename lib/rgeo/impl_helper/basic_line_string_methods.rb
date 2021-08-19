# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Common methods for LineString features
#
# -----------------------------------------------------------------------------

module RGeo
  module ImplHelper # :nodoc:
    module BasicLineStringMethods # :nodoc:
      def initialize(factory, points)
        self.factory = factory
        @points = points.map do |elem|
          elem = Feature.cast(elem, factory, Feature::Point)
          raise Error::InvalidGeometry, "Could not cast #{elem}" unless elem
          elem
        end
        # LineStrings in general need to check that there's not one point
        # GEOS doesn't allow instantiation of single point LineStrings so
        # we should handle it.
        if @points.size == 1
          raise Error::InvalidGeometry, "LineString Cannot Have 1 Point"
        end
        prepare_geometry
      end

      def num_points
        @points.size
      end

      def point_n(n)
        n < 0 ? nil : @points[n]
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
        array = []
        array << @points.first << @points.last if !is_empty? && !is_closed?
        factory.multipoint([array])
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

      def rep_equals?(rhs)
        if rhs.is_a?(self.class) && rhs.factory.eql?(@factory) && @points.size == rhs.num_points
          rhs.points.each_with_index { |p, i| return false unless @points[i].rep_equals?(p) }
        else
          false
        end
      end

      def hash
        @hash ||= begin
          hash = [factory, geometry_type].hash
          @points.inject(hash) { |h, p| (1_664_525 * h + p.hash).hash }
        end
      end

      def coordinates
        @points.map(&:coordinates)
      end

      def contains?(rhs)
        if Feature::Point === rhs
          contains_point?(rhs)
        else
          raise(Error::UnsupportedOperation,
                "Method LineString#contains? is only defined for Point")
        end
      end

      private

      def contains_point?(point)
        @points.each_cons(2) do |start_point, end_point|
          return true if point_intersect_segment?(point, start_point, end_point)
        end
        false
      end

      def point_intersect_segment?(point, start_point, end_point)
        return false unless point_collinear?(point, start_point, end_point)

        if start_point.x != end_point.x
          between_coordinate?(point.x, start_point.x, end_point.x)
        else
          between_coordinate?(point.y, start_point.y, end_point.y)
        end
      end

      def point_collinear?(a, b, c)
        (b.x - a.x) * (c.y - a.y) == (c.x - a.x) * (b.y - a.y)
      end

      def between_coordinate?(coord, start_coord, end_coord)
        end_coord >= coord && coord >= start_coord ||
          start_coord >= coord && coord >= end_coord
      end

      def copy_state_from(obj)
        super
        @points = obj.points
      end
    end

    module BasicLineMethods # :nodoc:
      def initialize(factory, start, stop)
        self.factory = factory
        cstart = Feature.cast(start, factory, Feature::Point)
        unless cstart
          raise Error::InvalidGeometry, "Could not cast start: #{start}"
        end
        cstop = Feature.cast(stop, factory, Feature::Point)
        raise Error::InvalidGeometry, "Could not cast end: #{stop}" unless cstop
        @points = [cstart, cstop]
        prepare_geometry
      end

      def geometry_type
        Feature::Line
      end

      def coordinates
        @points.map(&:coordinates)
      end
    end

    module BasicLinearRingMethods # :nodoc:
      def initialize(factory, points)
        super
        unless @points.size >= 4 || @points.size == 0
          raise Error::InvalidGeometry, "LinearRings must have 0 or >= 4 points"
        end
      end

      def geometry_type
        Feature::LinearRing
      end

      def ccw?
        RGeo::Cartesian::Analysis.ccw?(self)
      end

      private

      def prepare_geometry
        super
        if @points.size > 0
          @points << @points.first if @points.first != @points.last
          @points = @points.chunk { |x| x }.map(&:first)
        end
      end
    end
  end
end
