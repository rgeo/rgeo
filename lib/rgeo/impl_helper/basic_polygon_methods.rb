# -----------------------------------------------------------------------------
#
# Common methods for Polygon features
#
# -----------------------------------------------------------------------------

module RGeo
  module ImplHelper # :nodoc:
    module BasicPolygonMethods # :nodoc:
      def initialize(factory_, exterior_ring_, interior_rings_)
        _set_factory(factory_)
        @exterior_ring = Feature.cast(exterior_ring_, factory_, Feature::LinearRing)
        unless @exterior_ring
          raise Error::InvalidGeometry, "Failed to cast exterior ring #{exterior_ring_}"
        end
        @interior_rings = (interior_rings_ || []).map do |elem_|
          elem_ = Feature.cast(elem_, factory_, Feature::LinearRing)
          unless elem_
            raise Error::InvalidGeometry, "Could not cast interior ring #{elem_}"
          end
          elem_
        end
        _validate_geometry
      end

      def exterior_ring
        @exterior_ring
      end

      def num_interior_rings
        @interior_rings.size
      end

      def interior_ring_n(n_)
        n_ < 0 ? nil : @interior_rings[n_]
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

      def is_empty?
        @exterior_ring.is_empty?
      end

      def boundary
        array_ = []
        array_ << @exterior_ring unless @exterior_ring.is_empty?
        array_.concat(@interior_rings)
        factory.multi_line_string(array_)
      end

      def rep_equals?(rhs_)
        if rhs_.is_a?(self.class) && rhs_.factory.eql?(@factory) && @exterior_ring.rep_equals?(rhs_.exterior_ring) && @interior_rings.size == rhs_.num_interior_rings
          rhs_.interior_rings.each_with_index { |r_, i_| return false unless @interior_rings[i_].rep_equals?(r_) }
        else
          false
        end
      end

      def hash
        @hash ||= begin
          hash_ = [geometry_type, @exterior_ring].hash
          @interior_rings.inject(hash_) { |h_, r_| (1_664_525 * h_ + r_.hash).hash }
        end
      end

      def _copy_state_from(obj_) # :nodoc:
        super
        @exterior_ring = obj_.exterior_ring
        @interior_rings = obj_.interior_rings
      end

      def coordinates
        ([@exterior_ring] + @interior_rings).map(&:coordinates)
      end
    end
  end
end
