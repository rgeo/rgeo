# -----------------------------------------------------------------------------
#
# Common methods for LineString features
#
# -----------------------------------------------------------------------------

module RGeo
  module ImplHelper # :nodoc:
    module BasicLineStringMethods # :nodoc:
      def initialize(factory_, points_)
        _set_factory(factory_)
        @points = points_.map do |elem_|
          elem_ = Feature.cast(elem_, factory_, Feature::Point)
          raise Error::InvalidGeometry, "Could not cast #{elem_}" unless elem_
          elem_
        end
        _validate_geometry
      end

      def _validate_geometry
        if @points.size == 1
          raise Error::InvalidGeometry, "LineString cannot have 1 point"
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
        array_ << @points.first << @points.last if !is_empty? && !is_closed?
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
          rhs_.points.each_with_index { |p_, i_| return false unless @points[i_].rep_equals?(p_) }
        else
          false
        end
      end

      def hash
        @hash ||= begin
          hash_ = [factory, geometry_type].hash
          @points.inject(hash_) { |h_, p_| (1_664_525 * h_ + p_.hash).hash }
        end
      end

      def _copy_state_from(obj_) # :nodoc:
        super
        @points = obj_.points
      end

      def coordinates
        @points.map(&:coordinates)
      end
    end

    module BasicLineMethods # :nodoc:
      def initialize(factory_, start_, end_)
        _set_factory(factory_)
        cstart_ = Feature.cast(start_, factory_, Feature::Point)
        unless cstart_
          raise Error::InvalidGeometry, "Could not cast start: #{start_}"
        end
        cend_ = Feature.cast(end_, factory_, Feature::Point)
        raise Error::InvalidGeometry, "Could not cast end: #{end_}" unless cend_
        @points = [cstart_, cend_]
        _validate_geometry
      end

      def _validate_geometry # :nodoc:
        super
        if @points.size > 2
          raise Error::InvalidGeometry, "Line must have 0 or 2 points"
        end
      end

      def geometry_type
        Feature::Line
      end

      def coordinates
        @points.map(&:coordinates)
      end
    end

    module BasicLinearRingMethods # :nodoc:
      def _validate_geometry # :nodoc:
        super
        if @points.size > 0
          @points << @points.first if @points.first != @points.last
          if !@factory.property(:uses_lenient_assertions) && !is_ring?
            raise Error::InvalidGeometry, "LinearRing failed ring test"
          end
        end
      end

      def geometry_type
        Feature::LinearRing
      end
    end
  end
end
