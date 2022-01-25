# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Common methods for Polygon features
#
# -----------------------------------------------------------------------------

module RGeo
  module ImplHelper # :nodoc:
    module BasicPolygonMethods # :nodoc:
      def initialize(factory, exterior_ring, interior_rings)
        self.factory = factory
        @exterior_ring = Feature.cast(exterior_ring, factory, Feature::LinearRing)
        unless @exterior_ring
          raise Error::InvalidGeometry, "Failed to cast exterior ring #{exterior_ring}"
        end
        @interior_rings = (interior_rings || []).map do |elem|
          elem = Feature.cast(elem, factory, Feature::LinearRing)
          unless elem
            raise Error::InvalidGeometry, "Could not cast interior ring #{elem}"
          end
          elem
        end
        validate_geometry
      end

      def exterior_ring
        @exterior_ring
      end

      def num_interior_rings
        @interior_rings.size
      end

      def interior_ring_n(n)
        n < 0 ? nil : @interior_rings[n]
      end

      def interior_rings
        @interior_rings.dup
      end

      def dimension
        2
      end

      def geometry_type
        Feature::Polygon
      end

      def empty?
        @exterior_ring.empty?
      end

      def is_empty?
        warn "The is_empty? method is deprecated, please use the empty? counterpart, will be removed in v3" unless ENV["RGEO_SILENCE_DEPRECATION"]
        empty?
      end

      def boundary
        array = []
        array << @exterior_ring unless @exterior_ring.empty?
        array.concat(@interior_rings)
        factory.multi_line_string(array)
      end

      def rep_equals?(rhs)
        if rhs.is_a?(self.class) && rhs.factory.eql?(@factory) && @exterior_ring.rep_equals?(rhs.exterior_ring) && @interior_rings.size == rhs.num_interior_rings
          rhs.interior_rings.each_with_index { |r, i| return false unless @interior_rings[i].rep_equals?(r) }
        else
          false
        end
      end

      def hash
        @hash ||= begin
          hash = [geometry_type, @exterior_ring].hash
          @interior_rings.inject(hash) { |h, r| (1_664_525 * h + r.hash).hash }
        end
      end

      def coordinates
        ([@exterior_ring] + @interior_rings).map(&:coordinates)
      end

      def contains?(rhs)
        if Feature::Point === rhs
          contains_point?(rhs)
        else
          raise(Error::UnsupportedOperation,
            "Method Polygon#contains? is only defined for Point"
          )
        end
      end

      private

      def contains_point?(point)
        ring_encloses_point?(@exterior_ring, point) &&
          !@interior_rings.any? do |exclusion|
            ring_encloses_point?(exclusion, point, on_border_return: true)
          end
      end

      def ring_encloses_point?(ring, point, on_border_return: false)
        # This is an implementation of the ray casting algorithm, greatly inspired
        # by https://wrf.ecse.rpi.edu/Research/Short_Notes/pnpoly.html
        # Since this algorithm does not handle point on edge, we check first if
        # the ring is on the border.
        # on_border_return is used for exclusion ring
        return on_border_return if ring.contains?(point)
        encloses_point = false
        ring.points.each_cons(2) do |start_point, end_point|
          next unless (point.y < end_point.y) != (point.y < start_point.y)

          if point.x < (end_point.x - start_point.x) * (point.y - start_point.y) /
                       (end_point.y - start_point.y) + start_point.x
            encloses_point = !encloses_point
          end
        end
        encloses_point
      end


      def copy_state_from(obj)
        super
        @exterior_ring = obj.exterior_ring
        @interior_rings = obj.interior_rings
      end
    end
  end
end
