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

      private

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

      private

      def validate_geometry
        super
        if @points.size > 0
          @points << @points.first if @points.first != @points.last
          @points = @points.chunk { |x| x }.map(&:first)
          if !@factory.property(:uses_lenient_assertions) && !is_ring?
            raise Error::InvalidGeometry, "LinearRing failed ring test"
          end
        end
      end
    end
  end
end
