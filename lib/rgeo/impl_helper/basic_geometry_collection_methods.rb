# -----------------------------------------------------------------------------
#
# Common methods for GeometryCollection features
#
# -----------------------------------------------------------------------------

module RGeo
  module ImplHelper # :nodoc:
    module BasicGeometryCollectionMethods # :nodoc:
      def initialize(factory_, elements_)
        _set_factory(factory_)
        @elements = elements_.map do |elem_|
          elem_ = Feature.cast(elem_, factory_)
          raise Error::InvalidGeometry, "Could not cast #{elem_}" unless elem_
          elem_
        end
        _validate_geometry
      end

      def num_geometries
        @elements.size
      end

      def geometry_n(n_)
        n_ < 0 ? nil : @elements[n_]
      end

      def [](n_)
        @elements[n_]
      end

      def each(&block_)
        @elements.each(&block_)
      end

      def dimension
        unless defined?(@dimension)
          @dimension = -1
          @elements.each do |elem_|
            dim_ = elem_.dimension
            @dimension = dim_ if @dimension < dim_
          end
        end
        @dimension
      end

      def geometry_type
        Feature::GeometryCollection
      end

      def is_empty?
        @elements.size == 0
      end

      def rep_equals?(rhs_)
        if rhs_.is_a?(self.class) && rhs_.factory.eql?(@factory) && @elements.size == rhs_.num_geometries
          rhs_.each_with_index { |p_, i_| return false unless @elements[i_].rep_equals?(p_) }
        else
          false
        end
      end

      def hash
        @hash ||= begin
          hash_ = [factory, geometry_type].hash
          @elements.inject(hash_) { |h_, g_| (1_664_525 * h_ + g_.hash).hash }
        end
      end

      def _copy_state_from(obj_) # :nodoc:
        super
        @elements = obj_._elements
      end

      def _elements # :nodoc:
        @elements
      end
    end

    module BasicMultiLineStringMethods  # :nodoc:
      def initialize(factory_, elements_)
        _set_factory(factory_)
        @elements = elements_.map do |elem_|
          elem_ = Feature.cast(elem_, factory_, Feature::LineString, :keep_subtype)
          raise Error::InvalidGeometry, "Could not cast #{elem_}" unless elem_
          elem_
        end
        _validate_geometry
      end

      def geometry_type
        Feature::MultiLineString
      end

      def is_closed?
        all?(&:is_closed?)
      end

      def length
        @elements.inject(0.0) { |sum_, obj_| sum_ + obj_.length }
      end

      def _add_boundary(hash_, point_)  # :nodoc:
        hval_ = [point_.x, point_.y].hash
        (hash_[hval_] ||= [point_, 0])[1] += 1
      end

      def boundary
        hash_ = {}
        @elements.each do |line_|
          if !line_.is_empty? && !line_.is_closed?
            _add_boundary(hash_, line_.start_point)
            _add_boundary(hash_, line_.end_point)
          end
        end
        array_ = []
        hash_.each do |_hval_, data_|
          array_ << data_[0] if data_[1].odd?
        end
        factory.multi_point([array_])
      end

      def coordinates
        @elements.map(&:coordinates)
      end
    end

    module BasicMultiPointMethods # :nodoc:
      def initialize(factory_, elements_)
        _set_factory(factory_)
        @elements = elements_.map do |elem_|
          elem_ = Feature.cast(elem_, factory_, Feature::Point, :keep_subtype)
          raise Error::InvalidGeometry, "Could not cast #{elem_}" unless elem_
          elem_
        end
        _validate_geometry
      end

      def geometry_type
        Feature::MultiPoint
      end

      def boundary
        factory.collection([])
      end

      def coordinates
        @elements.map(&:coordinates)
      end
    end

    module BasicMultiPolygonMethods # :nodoc:
      def initialize(factory_, elements_)
        _set_factory(factory_)
        @elements = elements_.map do |elem_|
          elem_ = Feature.cast(elem_, factory_, Feature::Polygon, :keep_subtype)
          raise Error::InvalidGeometry, "Could not cast #{elem_}" unless elem_
          elem_
        end
        _validate_geometry
      end

      def geometry_type
        Feature::MultiPolygon
      end

      def area
        @elements.inject(0.0) { |sum_, obj_| sum_ + obj_.area }
      end

      def boundary
        array_ = []
        @elements.each do |poly_|
          array_ << poly_.exterior_ring unless poly_.is_empty?
          array_.concat(poly_.interior_rings)
        end
        factory.multi_line_string(array_)
      end

      def coordinates
        @elements.map(&:coordinates)
      end
    end
  end
end
