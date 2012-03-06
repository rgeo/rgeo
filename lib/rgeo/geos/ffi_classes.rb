# -----------------------------------------------------------------------------
#
# FFI-GEOS geometry implementation
#
# -----------------------------------------------------------------------------
# Copyright 2010-2012 Daniel Azuma
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the copyright holder, nor the names of any other
#   contributors to this software, may be used to endorse or promote products
#   derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# -----------------------------------------------------------------------------
;


module RGeo

  module Geos


    module FFIUtils  # :nodoc:

      class << self


        def coord_seqs_equal?(cs1_, cs2_, check_z_)
          len1_ = cs1_.length
          len2_ = cs2_.length
          if len1_ == len2_
            (0...len1_).each do |i_|
              return false unless cs1_.get_x(i_) == cs2_.get_x(i_) &&
                cs1_.get_y(i_) == cs2_.get_y(i_) &&
                (!check_z_ || cs1_.get_z(i_) == cs2_.get_z(i_))
            end
            true
          else
            false
          end
        end


        def compute_dimension(geom_)
          result_ = -1
          case geom_.type_id
          when ::Geos::GeomTypes::GEOS_POINT
            result_ = 0
          when ::Geos::GeomTypes::GEOS_MULTIPOINT
            result_ = 0 unless geom_.empty?
          when ::Geos::GeomTypes::GEOS_LINESTRING, ::Geos::GeomTypes::GEOS_LINEARRING
            result_ = 1
          when ::Geos::GeomTypes::GEOS_MULTILINESTRING
            result_ = 1 unless geom_.empty?
          when ::Geos::GeomTypes::GEOS_POLYGON
            result_ = 2
          when ::Geos::GeomTypes::GEOS_MULTIPOLYGON
            result_ = 2 unless geom_.empty?
          when ::Geos::GeomTypes::GEOS_GEOMETRYCOLLECTION
            geom_.each do |g_|
              dim_ = compute_dimension(g_)
              result_ = dim_ if result_ < dim_
            end
          end
          result_
        end


        def _init
          @supports_prepared_level_1 = ::Geos::FFIGeos.respond_to?(:GEOSPreparedContains_r)
          @supports_prepared_level_2 = ::Geos::FFIGeos.respond_to?(:GEOSPreparedDisjoint_r)
        end

        attr_reader :supports_prepared_level_1
        attr_reader :supports_prepared_level_2


      end

    end


    class FFIGeometryImpl  # :nodoc:

      include Feature::Instance

      Feature::MixinCollection::GLOBAL.for_type(Feature::Geometry).include_in_class(self)


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
        FFIUtils.compute_dimension(@fg_geom)
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
        fg_geom_ = @fg_geom.envelope
        # GEOS returns an "empty" point for an empty collection's envelope.
        # We don't allow that type, so we replace it with an empty collection.
        if fg_geom_.type_id == ::Geos::GeomTypes::GEOS_POINT && fg_geom_.empty?
          fg_geom_ = ::Geos::Utils.create_geometry_collection
        end
        @factory.wrap_fg_geom(fg_geom_)
      end


      def boundary
        if self.class == FFIGeometryCollectionImpl
          nil
        else
          @factory.wrap_fg_geom(@fg_geom.boundary)
        end
      end


      def as_text
        @factory._generate_wkt(self)
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
        return false unless rhs_.kind_of?(::RGeo::Feature::Instance)
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
          prep_ = _request_prepared if FFIUtils.supports_prepared_level_2
          prep_ ? prep_.disjoint?(fg_) : @fg_geom.disjoint?(fg_)
        else
          false
        end
      end


      def intersects?(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        if fg_
          prep_ = _request_prepared if FFIUtils.supports_prepared_level_1
          prep_ ? prep_.intersects?(fg_) : @fg_geom.intersects?(fg_)
        else
          false
        end
      end


      def touches?(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        if fg_
          prep_ = _request_prepared if FFIUtils.supports_prepared_level_2
          prep_ ? prep_.touches?(fg_) : @fg_geom.touches?(fg_)
        else
          false
        end
      end


      def crosses?(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        if fg_
          prep_ = _request_prepared if FFIUtils.supports_prepared_level_2
          prep_ ? prep_.crosses?(fg_) : @fg_geom.crosses?(fg_)
        else
          false
        end
      end


      def within?(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        if fg_
          prep_ = _request_prepared if FFIUtils.supports_prepared_level_2
          prep_ ? prep_.within?(fg_) : @fg_geom.within?(fg_)
        else
          false
        end
      end


      def contains?(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        if fg_
          prep_ = _request_prepared if FFIUtils.supports_prepared_level_1
          prep_ ? prep_.contains?(fg_) : @fg_geom.contains?(fg_)
        else
          false
        end
      end


      def overlaps?(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        if fg_
          prep_ = _request_prepared if FFIUtils.supports_prepared_level_2
          prep_ ? prep_.overlaps?(fg_) : @fg_geom.overlaps?(fg_)
        else
          false
        end
      end


      def relate?(rhs_, pattern_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        fg_ ? @fg_geom.relate_pattern(fg_, pattern_) : nil
      end
      alias_method :relate, :relate?  # DEPRECATED


      def distance(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        fg_ ? @fg_geom.distance(fg_) : nil
      end


      def buffer(distance_)
        @factory.wrap_fg_geom(@fg_geom.buffer(distance_, @factory.buffer_resolution))
      end


      def convex_hull
        @factory.wrap_fg_geom(@fg_geom.convex_hull)
      end


      def intersection(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        fg_ ? @factory.wrap_fg_geom(@fg_geom.intersection(fg_)) : nil
      end


      def union(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        fg_ ? @factory.wrap_fg_geom(@fg_geom.union(fg_)) : nil
      end


      def difference(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        fg_ ? @factory.wrap_fg_geom(@fg_geom.difference(fg_)) : nil
      end


      def sym_difference(rhs_)
        fg_ = factory._convert_to_fg_geometry(rhs_)
        fg_ ? @factory.wrap_fg_geom(@fg_geom.sym_difference(fg_)) : nil
      end


      def eql?(rhs_)
        rep_equals?(rhs_)
      end


      def _detach_fg_geom  # :nodoc:
        fg_ = @fg_geom
        @fg_geom = nil
        fg_
      end


      def _request_prepared  # :nodoc:
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


    class FFIPointImpl < FFIGeometryImpl  # :nodoc:

      Feature::MixinCollection::GLOBAL.for_type(Feature::Point).include_in_class(self)


      def x
        @fg_geom.coord_seq.get_x(0)
      end


      def y
        @fg_geom.coord_seq.get_y(0)
      end


      def z
        if @factory.property(:has_z_coordinate)
          @fg_geom.coord_seq.get_z(0)
        else
          nil
        end
      end


      def m
        if @factory.property(:has_m_coordinate)
          @fg_geom.coord_seq.get_z(0)
        else
          nil
        end
      end


      def geometry_type
        Feature::Point
      end


      def rep_equals?(rhs_)
        rhs_.class == self.class && rhs_.factory.eql?(@factory) &&
          FFIUtils.coord_seqs_equal?(rhs_.fg_geom.coord_seq, @fg_geom.coord_seq, @factory._has_3d)
      end


    end


    class FFILineStringImpl < FFIGeometryImpl  # :nodoc:


      Feature::MixinCollection::GLOBAL.for_type(Feature::Curve).include_in_class(self)
      Feature::MixinCollection::GLOBAL.for_type(Feature::LineString).include_in_class(self)


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
        else
          nil
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
          FFIUtils.coord_seqs_equal?(rhs_.fg_geom.coord_seq, @fg_geom.coord_seq, @factory._has_3d)
      end


    end


    class FFILinearRingImpl < FFILineStringImpl  # :nodoc:


      Feature::MixinCollection::GLOBAL.for_type(Feature::LinearRing).include_in_class(self)


      def geometry_type
        Feature::LinearRing
      end


    end


    class FFILineImpl < FFILineStringImpl  # :nodoc:


      Feature::MixinCollection::GLOBAL.for_type(Feature::Line).include_in_class(self)


      def geometry_type
        Feature::Line
      end


    end


    class FFIPolygonImpl < FFIGeometryImpl  # :nodoc:


      Feature::MixinCollection::GLOBAL.for_type(Feature::Surface).include_in_class(self)
      Feature::MixinCollection::GLOBAL.for_type(Feature::Polygon).include_in_class(self)


      def geometry_type
        Feature::Polygon
      end


      def area
        @fg_geom.area
      end


      def centroid
        @factory.wrap_fg_geom(@fg_geom.centroid, FFIPointImpl)
      end


      def point_on_surface
        @factory.wrap_fg_geom(@fg_geom.point_on_surface, FFIPointImpl)
      end


      def exterior_ring
        @factory.wrap_fg_geom(@fg_geom.exterior_ring, FFILinearRingImpl)
      end


      def num_interior_rings
        @fg_geom.num_interior_rings
      end


      def interior_ring_n(n_)
        if n_ >= 0 && n_ < @fg_geom.num_interior_rings
          @factory.wrap_fg_geom(@fg_geom.interior_ring_n(n_), FFILinearRingImpl)
        else
          nil
        end
      end


      def interior_rings
        ::Array.new(@fg_geom.num_interior_rings) do |n_|
          @factory.wrap_fg_geom(@fg_geom.interior_ring_n(n_), FFILinearRingImpl)
        end
      end


      def rep_equals?(rhs_)
        if rhs_.class == self.class && rhs_.factory.eql?(@factory) &&
          rhs_.exterior_ring.rep_equals?(self.exterior_ring)
        then
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


    end


    class FFIGeometryCollectionImpl < FFIGeometryImpl  # :nodoc:


      Feature::MixinCollection::GLOBAL.for_type(Feature::GeometryCollection).include_in_class(self)


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
          @factory.wrap_fg_geom(@fg_geom.get_geometry_n(n_),
            @_klasses ? @_klasses[n_] : nil)
        else
          nil
        end
      end


      def [](n_)
        n_ += @fg_geom.num_geometries if n_ < 0
        if n_ >= 0 && n_ < @fg_geom.num_geometries
          @factory.wrap_fg_geom(@fg_geom.get_geometry_n(n_),
            @_klasses ? @_klasses[n_] : nil)
        else
          nil
        end
      end


      def each
        if block_given?
          @fg_geom.num_geometries.times do |n_|
            yield @factory.wrap_fg_geom(@fg_geom.get_geometry_n(n_),
              @_klasses ? @_klasses[n_] : nil)
          end
          self
        else
          enum_for
        end
      end

      include ::Enumerable


    end


    class FFIMultiPointImpl < FFIGeometryCollectionImpl  # :nodoc:


      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPoint).include_in_class(self)


      def geometry_type
        Feature::MultiPoint
      end


    end


    class FFIMultiLineStringImpl < FFIGeometryCollectionImpl  # :nodoc:


      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiCurve).include_in_class(self)
      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiLineString).include_in_class(self)


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


    end


    class FFIMultiPolygonImpl < FFIGeometryCollectionImpl  # :nodoc:


      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiSurface).include_in_class(self)
      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPolygon).include_in_class(self)


      def geometry_type
        Feature::MultiPolygon
      end


      def area
        @fg_geom.area
      end


      def centroid
        @factory.wrap_fg_geom(@fg_geom.centroid, FFIPointImpl)
      end


      def point_on_surface
        @factory.wrap_fg_geom(@fg_geom.point_on_surface, FFIPointImpl)
      end


    end


  end

end
