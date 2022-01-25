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
        validate_geometry
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

      def empty?
        @points.size == 0
      end

      def is_empty?
        warn "The is_empty? method is deprecated, please use the empty? counterpart, will be removed in v3" unless ENV["RGEO_SILENCE_DEPRECATION"]
        empty?
      end

      def boundary
        array = []
        array << @points.first << @points.last if !empty? && !closed?
        factory.multipoint([array])
      end

      def start_point
        @points.first
      end

      def end_point
        @points.last
      end

      def closed?
        unless defined?(@closed)
          @closed = @points.size > 2 && @points.first == @points.last
        end
        @closed
      end

      def is_closed?
        warn "The is_closed? method is deprecated, please use the closed? counterpart, will be removed in v3" unless ENV["RGEO_SILENCE_DEPRECATION"]
        closed?
      end

      def ring?
        closed? && simple?
      end

      def is_ring?
        warn "The is_ring? method is deprecated, please use the ring? counterpart, will be removed in v3" unless ENV["RGEO_SILENCE_DEPRECATION"]
        ring?
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

      def validate_geometry
        if @points.size == 1
          raise Error::InvalidGeometry, "LineString cannot have 1 point"
        end
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
        validate_geometry
      end

      def geometry_type
        Feature::Line
      end

      def coordinates
        @points.map(&:coordinates)
      end

      private

      def validate_geometry
        super
        if @points.size > 2
          raise Error::InvalidGeometry, "Line must have 0 or 2 points"
        end
      end
    end

    module BasicLinearRingMethods # :nodoc:
      def geometry_type
        Feature::LinearRing
      end

      def ccw?
        RGeo::Cartesian::Analysis.ccw?(self)
      end

      private

      def validate_geometry
        super
        if @points.size > 0
          @points << @points.first if @points.first != @points.last
          @points = @points.chunk { |x| x }.map(&:first)
          if !@factory.property(:uses_lenient_assertions) && !ring?
            raise Error::InvalidGeometry, "LinearRing failed ring test"
          end
        end
      end
    end
  end
end
