# -----------------------------------------------------------------------------
#
# Common methods for Point features
#
# -----------------------------------------------------------------------------

module RGeo
  module ImplHelper # :nodoc:
    module BasicPointMethods # :nodoc:
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
        return false unless rhs_.is_a?(self.class) && rhs_.factory == factory
        case rhs_
        when Feature::Point
          rhs_.x == @x && rhs_.y == @y
        when Feature::LineString
          rhs_.num_points > 0 && rhs_.points.all? { |elem_| equals?(elem_) }
        when Feature::GeometryCollection
          rhs_.num_geometries > 0 && rhs_.all? { |elem_| equals?(elem_) }
        else
          false
        end
      end

      def rep_equals?(rhs_)
        rhs_.is_a?(self.class) && rhs_.factory.eql?(@factory) && @x == rhs_.x && @y == rhs_.y && @z == rhs_.z && @m == rhs_.m
      end

      def hash
        @hash ||= [factory, geometry_type, @x, @y, @z, @m].hash
      end

      def _copy_state_from(obj_) # :nodoc:
        super
        @x = obj_.x
        @y = obj_.y
        @z = obj_.z
        @m = obj_.m
      end

      def coordinates
        [x, y].tap do |coords|
          coords << z if factory.property(:has_z_coordinate)
          coords << m if factory.property(:has_m_coordinate)
        end
      end
    end
  end
end
