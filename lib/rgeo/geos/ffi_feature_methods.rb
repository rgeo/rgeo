# -----------------------------------------------------------------------------
#
# FFI-GEOS geometry implementation
#
# -----------------------------------------------------------------------------

module RGeo
  module Geos
    module FFIGeometryMethods # :nodoc:
      include Feature::Instance

      def initialize(factory_, fg_geom_, klasses_)
        @factory = factory_
        @fg_geom = fg_geom_
        @_fg_prep = factory_._auto_prepare ? 1 : 0
        @_klasses = klasses_
        fg_geom_.srid = factory_.srid
      end

      def inspect
        "#<#{self.class}:0x#{object_id.to_s(16)} #{as_text.inspect}>"
      end

      # Marshal support

      def marshal_dump # :nodoc:
        [@factory, @factory._write_for_marshal(self)]
      end

      def marshal_load(data_) # :nodoc:
        @factory = data_[0]
        @fg_geom = @factory._read_for_marshal(data_[1])
        @fg_geom.srid = @factory.srid
        @_fg_prep = @factory._auto_prepare ? 1 : 0
        @_klasses = nil
      end

      # Psych support

      def encode_with(coder_) # :nodoc:
        coder_["factory"] = @factory
        str_ = @factory._write_for_psych(self)
        str_ = str_.encode("US-ASCII") if str_.respond_to?(:encode)
        coder_["wkt"] = str_
      end

      def init_with(coder_)  # :nodoc:
        @factory = coder_["factory"]
        @fg_geom = @factory._read_for_psych(coder_["wkt"])
        @fg_geom.srid = @factory.srid
        @_fg_prep = @factory._auto_prepare ? 1 : 0
        @_klasses = nil
      end

      attr_reader :factory
      attr_reader :fg_geom

      attr_reader :_klasses  # :nodoc:

      def initialize_copy(orig_)
        @factory = orig_.factory
        @fg_geom = orig_.fg_geom.clone
        @fg_geom.srid = orig_.fg_geom.srid
        @_fg_prep = @factory._auto_prepare ? 1 : 0
        @_klasses = orig_._klasses
      end

      def srid
        @fg_geom.srid
      end

      def dimension
        Utils.ffi_compute_dimension(@fg_geom)
      end

      def geometry_type
        Feature::Geometry
      end

      def prepared?
        !@_fg_prep.is_a?(::Integer)
      end

      def prepare!
        if @_fg_prep.is_a?(::Integer)
          @_fg_prep = ::Geos::PreparedGeometry.new(@fg_geom)
        end
        self
      end

      def envelope
        @factory._wrap_fg_geom(@fg_geom.envelope, nil)
      end

      def boundary
        if self.class == FFIGeometryCollectionImpl
          nil
        else
          @factory._wrap_fg_geom(@fg_geom.boundary, nil)
        end
      end

      def as_text
        str_ = @factory._generate_wkt(self)
        str_.force_encoding("US-ASCII") if str_.respond_to?(:force_encoding)
        str_
      end
      alias_method :to_s, :as_text

      def as_binary
        @factory._generate_wkb(self)
      end

      def is_empty?
        @fg_geom.empty?
      end

      def is_simple?
        @fg_geom.simple?
      end

      def equals?(rhs_)
        return false unless rhs_.is_a?(::RGeo::Feature::Instance)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        if !fg_
          false
        # GEOS has a bug where empty geometries are not spatially equal
        # to each other. Work around this case first.
        elsif fg_.empty? && @fg_geom.empty?
          true
        else
          @fg_geom.eql?(fg_)
        end
      end
      alias_method :==, :equals?

      def disjoint?(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        if fg_
          prep_ = _request_prepared if Utils.ffi_supports_prepared_level_2
          prep_ ? prep_.disjoint?(fg_) : @fg_geom.disjoint?(fg_)
        else
          false
        end
      end

      def intersects?(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        if fg_
          prep_ = _request_prepared if Utils.ffi_supports_prepared_level_1
          prep_ ? prep_.intersects?(fg_) : @fg_geom.intersects?(fg_)
        else
          false
        end
      end

      def touches?(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        if fg_
          prep_ = _request_prepared if Utils.ffi_supports_prepared_level_2
          prep_ ? prep_.touches?(fg_) : @fg_geom.touches?(fg_)
        else
          false
        end
      end

      def crosses?(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        if fg_
          prep_ = _request_prepared if Utils.ffi_supports_prepared_level_2
          prep_ ? prep_.crosses?(fg_) : @fg_geom.crosses?(fg_)
        else
          false
        end
      end

      def within?(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        if fg_
          prep_ = _request_prepared if Utils.ffi_supports_prepared_level_2
          prep_ ? prep_.within?(fg_) : @fg_geom.within?(fg_)
        else
          false
        end
      end

      def contains?(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        if fg_
          prep_ = _request_prepared if Utils.ffi_supports_prepared_level_1
          prep_ ? prep_.contains?(fg_) : @fg_geom.contains?(fg_)
        else
          false
        end
      end

      def overlaps?(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        if fg_
          prep_ = _request_prepared if Utils.ffi_supports_prepared_level_2
          prep_ ? prep_.overlaps?(fg_) : @fg_geom.overlaps?(fg_)
        else
          false
        end
      end

      def relate?(rhs_, pattern_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        fg_ ? @fg_geom.relate_pattern(fg_, pattern_) : nil
      end
      alias_method :relate, :relate? # DEPRECATED

      def distance(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        fg_ ? @fg_geom.distance(fg_) : nil
      end

      def buffer(distance_)
        @factory._wrap_fg_geom(@fg_geom.buffer(distance_, @factory.buffer_resolution), nil)
      end

      def convex_hull
        @factory._wrap_fg_geom(@fg_geom.convex_hull, nil)
      end

      def intersection(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        fg_ ? @factory._wrap_fg_geom(@fg_geom.intersection(fg_), nil) : nil
      end

      alias_method :*, :intersection

      def union(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        fg_ ? @factory._wrap_fg_geom(@fg_geom.union(fg_), nil) : nil
      end

      alias_method :+, :union

      def unary_union
        return unless @fg_geom.respond_to?(:unary_union)
        @factory.wrap_fg_geom(@fg_geom.unary_union)
      end

      def difference(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        fg_ ? @factory._wrap_fg_geom(@fg_geom.difference(fg_), nil) : nil
      end

      alias_method :-, :difference

      def sym_difference(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        fg_ ? @factory._wrap_fg_geom(@fg_geom.sym_difference(fg_), nil) : nil
      end

      def eql?(rhs_)
        rep_equals?(rhs_)
      end

      def _detach_fg_geom # :nodoc:
        fg_ = @fg_geom
        @fg_geom = nil
        fg_
      end

      def _request_prepared # :nodoc:
        case @_fg_prep
        when 0
          nil
        when 1
          @_fg_prep = 2
          nil
        when 2
          @_fg_prep = ::Geos::PreparedGeometry.new(@fg_geom)
        else
          @_fg_prep
        end
      end
    end

    module FFIPointMethods # :nodoc:
      def x
        @fg_geom.coord_seq.get_x(0)
      end

      def y
        @fg_geom.coord_seq.get_y(0)
      end

      def z
        @fg_geom.coord_seq.get_z(0) if @factory.property(:has_z_coordinate)
      end

      def m
        @fg_geom.coord_seq.get_z(0) if @factory.property(:has_m_coordinate)
      end

      def geometry_type
        Feature::Point
      end

      def rep_equals?(rhs_)
        rhs_.class == self.class && rhs_.factory.eql?(@factory) &&
          Utils.ffi_coord_seqs_equal?(rhs_.fg_geom.coord_seq, @fg_geom.coord_seq, @factory._has_3d)
      end

      def hash
        @hash ||= Utils.ffi_coord_seq_hash(@fg_geom.coord_seq, [@factory, geometry_type].hash)
      end

      def coordinates
        [x, y].tap do |coords|
          coords << z if @factory.property(:has_z_coordinate)
          coords << m if @factory.property(:has_m_coordinate)
        end
      end
    end

    module FFILineStringMethods  # :nodoc:
      def geometry_type
        Feature::LineString
      end

      def length
        @fg_geom.length
      end

      def num_points
        @fg_geom.num_points
      end

      def point_n(n_)
        if n_ >= 0 && n_ < @fg_geom.num_points
          coord_seq_ = @fg_geom.coord_seq
          x_ = coord_seq_.get_x(n_)
          y_ = coord_seq_.get_y(n_)
          extra_ = @factory._has_3d ? [coord_seq_.get_z(n_)] : []
          @factory.point(x_, y_, *extra_)
        end
      end

      def start_point
        point_n(0)
      end

      def end_point
        point_n(@fg_geom.num_points - 1)
      end

      def points
        coord_seq_ = @fg_geom.coord_seq
        has_3d_ = @factory._has_3d
        ::Array.new(@fg_geom.num_points) do |n_|
          x_ = coord_seq_.get_x(n_)
          y_ = coord_seq_.get_y(n_)
          extra_ = has_3d_ ? [coord_seq_.get_z(n_)] : []
          @factory.point(x_, y_, *extra_)
        end
      end

      def is_closed?
        @fg_geom.closed?
      end

      def is_ring?
        @fg_geom.ring?
      end

      def rep_equals?(rhs_)
        rhs_.class == self.class && rhs_.factory.eql?(@factory) &&
          Utils.ffi_coord_seqs_equal?(rhs_.fg_geom.coord_seq, @fg_geom.coord_seq, @factory._has_3d)
      end

      def hash
        @hash ||= Utils.ffi_coord_seq_hash(@fg_geom.coord_seq, [@factory, geometry_type].hash)
      end

      def coordinates
        points.map(&:coordinates)
      end
    end

    module FFILinearRingMethods  # :nodoc:
      def geometry_type
        Feature::LinearRing
      end
    end

    module FFILineMethods # :nodoc:
      def geometry_type
        Feature::Line
      end
    end

    module FFIPolygonMethods # :nodoc:
      def geometry_type
        Feature::Polygon
      end

      def area
        @fg_geom.area
      end

      def centroid
        @factory._wrap_fg_geom(@fg_geom.centroid, FFIPointImpl)
      end

      def point_on_surface
        @factory._wrap_fg_geom(@fg_geom.point_on_surface, FFIPointImpl)
      end

      def exterior_ring
        @factory._wrap_fg_geom(@fg_geom.exterior_ring, FFILinearRingImpl)
      end

      def num_interior_rings
        @fg_geom.num_interior_rings
      end

      def interior_ring_n(n_)
        if n_ >= 0 && n_ < @fg_geom.num_interior_rings
          @factory._wrap_fg_geom(@fg_geom.interior_ring_n(n_), FFILinearRingImpl)
        end
      end

      def interior_rings
        ::Array.new(@fg_geom.num_interior_rings) do |n_|
          @factory._wrap_fg_geom(@fg_geom.interior_ring_n(n_), FFILinearRingImpl)
        end
      end

      def rep_equals?(rhs_)
        if rhs_.class == self.class && rhs_.factory.eql?(@factory) &&
          rhs_.exterior_ring.rep_equals?(exterior_ring)
          sn_ = @fg_geom.num_interior_rings
          rn_ = rhs_.num_interior_rings
          if sn_ == rn_
            sn_.times do |i_|
              return false unless interior_ring_n(i_).rep_equals?(rhs_.interior_ring_n(i_))
            end
            return true
          end
        end
        false
      end

      def hash
        @hash ||= begin
          hash_ = Utils.ffi_coord_seq_hash(@fg_geom.exterior_ring.coord_seq,
            [@factory, geometry_type].hash)
          @fg_geom.interior_rings.inject(hash_) do |h_, r_|
            Utils.ffi_coord_seq_hash(r_.coord_seq, h_)
          end
        end
      end

      def coordinates
        ([exterior_ring] + interior_rings).map(&:coordinates)
      end
    end

    module FFIGeometryCollectionMethods # :nodoc:
      def geometry_type
        Feature::GeometryCollection
      end

      def rep_equals?(rhs_)
        if rhs_.class == self.class && rhs_.factory.eql?(@factory)
          size_ = @fg_geom.num_geometries
          if size_ == rhs_.num_geometries
            size_.times do |n_|
              return false unless geometry_n(n_).rep_equals?(rhs_.geometry_n(n_))
            end
            return true
          end
        end
        false
      end

      def num_geometries
        @fg_geom.num_geometries
      end
      alias_method :size, :num_geometries

      def geometry_n(n_)
        if n_ >= 0 && n_ < @fg_geom.num_geometries
          @factory._wrap_fg_geom(@fg_geom.get_geometry_n(n_),
            @_klasses ? @_klasses[n_] : nil)
        end
      end

      def [](n_)
        n_ += @fg_geom.num_geometries if n_ < 0
        if n_ >= 0 && n_ < @fg_geom.num_geometries
          @factory._wrap_fg_geom(@fg_geom.get_geometry_n(n_),
            @_klasses ? @_klasses[n_] : nil)
        end
      end

      def hash
        @hash ||= begin
          hash_ = [@factory, geometry_type].hash
          (0...num_geometries).inject(hash_) do |h_, i_|
            (1_664_525 * h_ + geometry_n(i_).hash).hash
          end
        end
      end

      def each
        if block_given?
          @fg_geom.num_geometries.times do |n_|
            yield @factory._wrap_fg_geom(@fg_geom.get_geometry_n(n_),
              @_klasses ? @_klasses[n_] : nil)
          end
          self
        else
          enum_for
        end
      end

      include ::Enumerable
    end

    module FFIMultiPointMethods # :nodoc:
      def geometry_type
        Feature::MultiPoint
      end

      def coordinates
        each.map(&:coordinates)
      end
    end

    module FFIMultiLineStringMethods # :nodoc:
      def geometry_type
        Feature::MultiLineString
      end

      def length
        @fg_geom.length
      end

      def is_closed?
        size_ = num_geometries
        size_.times do |n_|
          return false unless @fg_geom.get_geometry_n(n_).closed?
        end
        true
      end

      def coordinates
        each.map(&:coordinates)
      end
    end

    module FFIMultiPolygonMethods # :nodoc:
      def geometry_type
        Feature::MultiPolygon
      end

      def area
        @fg_geom.area
      end

      def centroid
        @factory._wrap_fg_geom(@fg_geom.centroid, FFIPointImpl)
      end

      def point_on_surface
        @factory._wrap_fg_geom(@fg_geom.point_on_surface, FFIPointImpl)
      end

      def coordinates
        each.map(&:coordinates)
      end
    end
  end
end
