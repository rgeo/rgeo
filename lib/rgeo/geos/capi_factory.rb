# -----------------------------------------------------------------------------
#
# GEOS factory implementation
#
# -----------------------------------------------------------------------------

module RGeo
  module Geos
    # This the GEOS CAPI implementation of ::RGeo::Feature::Factory.

    class CAPIFactory
      include Feature::Factory::Instance

      class << self
        # Create a new factory. Returns nil if the GEOS CAPI implementation
        # is not supported.
        #
        # See ::RGeo::Geos.factory for a list of supported options.

        def create(opts_ = {})
          # Make sure GEOS is available
          return nil unless respond_to?(:_create)

          # Get flags to pass to the C extension
          flags_ = 0
          flags_ |= 1 if opts_[:uses_lenient_assertions] || opts_[:lenient_multi_polygon_assertions] || opts_[:uses_lenient_multi_polygon_assertions]
          flags_ |= 2 if opts_[:has_z_coordinate]
          flags_ |= 4 if opts_[:has_m_coordinate]
          if flags_ & 6 == 6
            raise Error::UnsupportedOperation, "GEOS cannot support both Z and M coordinates at the same time."
          end
          flags_ |= 8 unless opts_[:auto_prepare] == :disabled

          # Buffer resolution
          buffer_resolution_ = opts_[:buffer_resolution].to_i
          buffer_resolution_ = 1 if buffer_resolution_ < 1

          # Interpret the generator options
          wkt_generator_ = opts_[:wkt_generator]
          case wkt_generator_
          when :geos
            wkt_generator_ = nil
          when ::Hash
            wkt_generator_ = WKRep::WKTGenerator.new(wkt_generator_)
          else
            wkt_generator_ = WKRep::WKTGenerator.new(convert_case: :upper)
          end
          wkb_generator_ = opts_[:wkb_generator]
          case wkb_generator_
          when :geos
            wkb_generator_ = nil
          when ::Hash
            wkb_generator_ = WKRep::WKBGenerator.new(wkb_generator_)
          else
            wkb_generator_ = WKRep::WKBGenerator.new
          end

          # Coordinate system (srid, proj4, and coord_sys)
          srid_ = opts_[:srid]
          proj4_ = opts_[:proj4]
          if CoordSys::Proj4.supported?
            if proj4_.is_a?(::String) || proj4_.is_a?(::Hash)
              proj4_ = CoordSys::Proj4.create(proj4_)
            end
          else
            proj4_ = nil
          end
          coord_sys_ = opts_[:coord_sys]
          if coord_sys_.is_a?(::String)
            coord_sys_ = begin
                           CoordSys::CS.create_from_wkt(coord_sys_)
                         rescue
                           nil
                         end
          end
          if (!proj4_ || !coord_sys_) && srid_ && (db_ = opts_[:srs_database])
            entry_ = db_.get(srid_.to_i)
            if entry_
              proj4_ ||= entry_.proj4
              coord_sys_ ||= entry_.coord_sys
            end
          end
          srid_ ||= coord_sys_.authority_code if coord_sys_

          # Create the factory and set instance variables
          result_ = _create(flags_, srid_.to_i, buffer_resolution_,
            wkt_generator_, wkb_generator_, proj4_, coord_sys_)

          # Interpret parser options
          wkt_parser_ = opts_[:wkt_parser]
          case wkt_parser_
          when :geos
            wkt_parser_ = nil
          when ::Hash
            wkt_parser_ = WKRep::WKTParser.new(result_, wkt_parser_)
          else
            wkt_parser_ = WKRep::WKTParser.new(result_)
          end
          wkb_parser_ = opts_[:wkb_parser]
          case wkb_parser_
          when :geos
            wkb_parser_ = nil
          when ::Hash
            wkb_parser_ = WKRep::WKBParser.new(result_, wkb_parser_)
          else
            wkb_parser_ = WKRep::WKBParser.new(result_)
          end
          result_._set_wkrep_parsers(wkt_parser_, wkb_parser_)

          # Return the result
          result_
        end
        alias_method :new, :create
      end

      # Standard object inspection output

      def inspect
        "#<#{self.class}:0x#{object_id.to_s(16)} srid=#{_srid} bufres=#{_buffer_resolution} flags=#{_flags}>"
      end

      # Factory equivalence test.

      def eql?(rhs_)
        rhs_.is_a?(CAPIFactory) && rhs_.srid == _srid &&
          rhs_._buffer_resolution == _buffer_resolution && rhs_._flags == _flags &&
          rhs_.proj4 == _proj4
      end
      alias_method :==, :eql?

      # Standard hash code

      def hash
        @hash ||= [_srid, _buffer_resolution, _flags, _proj4].hash
      end

      # Marshal support

      def marshal_dump # :nodoc:
        hash_ = {
          "hasz" => (_flags & 0x2 != 0),
          "hasm" => (_flags & 0x4 != 0),
          "srid" => _srid,
          "bufr" => _buffer_resolution,
          "wktg" => _wkt_generator ? _wkt_generator._properties : {},
          "wkbg" => _wkb_generator ? _wkb_generator._properties : {},
          "wktp" => _wkt_parser ? _wkt_parser._properties : {},
          "wkbp" => _wkb_parser ? _wkb_parser._properties : {},
          "lmpa" => (_flags & 0x1 != 0),
          "apre" => ((_flags & 0x8) >> 3)
        }
        if (proj4_ = _proj4)
          hash_["proj4"] = proj4_.marshal_dump
        end
        if (coord_sys_ = _coord_sys)
          hash_["cs"] = coord_sys_.to_wkt
        end
        hash_
      end

      def marshal_load(data_) # :nodoc:
        if CoordSys::Proj4.supported? && (proj4_data_ = data_["proj4"])
          proj4_ = CoordSys::Proj4.allocate
          proj4_.marshal_load(proj4_data_)
        else
          proj4_ = nil
        end
        if (coord_sys_data_ = data_["cs"])
          coord_sys_ = CoordSys::CS.create_from_wkt(coord_sys_data_)
        else
          coord_sys_ = nil
        end
        initialize_copy(CAPIFactory.create(
                          has_z_coordinate: data_["hasz"],
                          has_m_coordinate: data_["hasm"],
                          srid: data_["srid"],
                          buffer_resolution: data_["bufr"],
                          wkt_generator: ImplHelper::Utils.symbolize_hash(data_["wktg"]),
                          wkb_generator: ImplHelper::Utils.symbolize_hash(data_["wkbg"]),
                          wkt_parser: ImplHelper::Utils.symbolize_hash(data_["wktp"]),
                          wkb_parser: ImplHelper::Utils.symbolize_hash(data_["wkbp"]),
                          uses_lenient_multi_polygon_assertions: data_["lmpa"],
                          auto_prepare: (data_["apre"] == 0 ? :disabled : :simple),
                          proj4: proj4_,
                          coord_sys: coord_sys_
        ))
      end

      # Psych support

      def encode_with(coder_) # :nodoc:
        coder_["has_z_coordinate"] = (_flags & 0x2 != 0)
        coder_["has_m_coordinate"] = (_flags & 0x4 != 0)
        coder_["srid"] = _srid
        coder_["buffer_resolution"] = _buffer_resolution
        coder_["lenient_multi_polygon_assertions"] = (_flags & 0x1 != 0)
        coder_["wkt_generator"] = _wkt_generator ? _wkt_generator._properties : {}
        coder_["wkb_generator"] = _wkb_generator ? _wkb_generator._properties : {}
        coder_["wkt_parser"] = _wkt_parser ? _wkt_parser._properties : {}
        coder_["wkb_parser"] = _wkb_parser ? _wkb_parser._properties : {}
        coder_["auto_prepare"] = ((_flags & 0x8) == 0 ? "disabled" : "simple")
        if (proj4_ = _proj4)
          str_ = proj4_.original_str || proj4_.canonical_str
          coder_["proj4"] = proj4_.radians? ? { "proj4" => str_, "radians" => true } : str_
        end
        if (coord_sys_ = _coord_sys)
          coder_["coord_sys"] = coord_sys_.to_wkt
        end
      end

      def init_with(coder_) # :nodoc:
        if (proj4_data_ = coder_["proj4"])
          if proj4_data_.is_a?(::Hash)
            proj4_ = CoordSys::Proj4.create(proj4_data_["proj4"], radians: proj4_data_["radians"])
          else
            proj4_ = CoordSys::Proj4.create(proj4_data_.to_s)
          end
        else
          proj4_ = nil
        end
        if (coord_sys_data_ = coder_["cs"])
          coord_sys_ = CoordSys::CS.create_from_wkt(coord_sys_data_.to_s)
        else
          coord_sys_ = nil
        end
        initialize_copy(CAPIFactory.create(
                          has_z_coordinate: coder_["has_z_coordinate"],
                          has_m_coordinate: coder_["has_m_coordinate"],
                          srid: coder_["srid"],
                          buffer_resolution: coder_["buffer_resolution"],
                          wkt_generator: ImplHelper::Utils.symbolize_hash(coder_["wkt_generator"]),
                          wkb_generator: ImplHelper::Utils.symbolize_hash(coder_["wkb_generator"]),
                          wkt_parser: ImplHelper::Utils.symbolize_hash(coder_["wkt_parser"]),
                          wkb_parser: ImplHelper::Utils.symbolize_hash(coder_["wkb_parser"]),
                          auto_prepare: coder_["auto_prepare"] == "disabled" ? :disabled : :simple,
                          uses_lenient_multi_polygon_assertions: coder_["lenient_multi_polygon_assertions"],
                          proj4: proj4_,
                          coord_sys: coord_sys_
        ))
      end

      # Returns the SRID of geometries created by this factory.

      def srid
        _srid
      end

      # Returns the resolution used by buffer calculations on geometries
      # created by this factory

      def buffer_resolution
        _buffer_resolution
      end

      # Returns true if this factory is lenient with MultiPolygon assertions

      def lenient_multi_polygon_assertions?
        _flags & 0x1 != 0
      end

      # See ::RGeo::Feature::Factory#property

      def property(name_)
        case name_
        when :has_z_coordinate
          _flags & 0x2 != 0
        when :has_m_coordinate
          _flags & 0x4 != 0
        when :is_cartesian
          true
        when :uses_lenient_multi_polygon_assertions
          _flags & 0x1 != 0
        when :buffer_resolution
          _buffer_resolution
        when :auto_prepare
          _flags & 0x8 != 0 ? :simple : :disabled
        end
      end

      # See ::RGeo::Feature::Factory#parse_wkt

      def parse_wkt(str_)
        if (wkt_parser_ = _wkt_parser)
          wkt_parser_.parse(str_)
        else
          _parse_wkt_impl(str_)
        end
      end

      # See ::RGeo::Feature::Factory#parse_wkb

      def parse_wkb(str_)
        if (wkb_parser_ = _wkb_parser)
          wkb_parser_.parse(str_)
        else
          _parse_wkb_impl(str_)
        end
      end

      # See ::RGeo::Feature::Factory#point

      def point(x_, y_, *extra_)
        if extra_.length > (_flags & 6 == 0 ? 0 : 1)
          nil
        else
          begin
            CAPIPointImpl.create(self, x_, y_, extra_[0].to_f)
          rescue
            nil
          end
        end
      end

      # See ::RGeo::Feature::Factory#line_string

      def line_string(points_)
        points_ = points_.to_a unless points_.is_a?(::Array)
        begin
          CAPILineStringImpl.create(self, points_)
        rescue
          nil
        end
      end

      # See ::RGeo::Feature::Factory#line

      def line(start_, end_)
        CAPILineImpl.create(self, start_, end_)
      rescue
        nil
      end

      # See ::RGeo::Feature::Factory#linear_ring

      def linear_ring(points_)
        points_ = points_.to_a unless points_.is_a?(::Array)
        begin
          CAPILinearRingImpl.create(self, points_)
        rescue
          nil
        end
      end

      # See ::RGeo::Feature::Factory#polygon

      def polygon(outer_ring_, inner_rings_ = nil)
        inner_rings_ = inner_rings_.to_a unless inner_rings_.is_a?(::Array)
        begin
          CAPIPolygonImpl.create(self, outer_ring_, inner_rings_)
        rescue
          nil
        end
      end

      # See ::RGeo::Feature::Factory#collection

      def collection(elems_)
        elems_ = elems_.to_a unless elems_.is_a?(::Array)
        begin
          CAPIGeometryCollectionImpl.create(self, elems_)
        rescue
          nil
        end
      end

      # See ::RGeo::Feature::Factory#multi_point

      def multi_point(elems_)
        elems_ = elems_.to_a unless elems_.is_a?(::Array)
        begin
          CAPIMultiPointImpl.create(self, elems_)
        rescue
          nil
        end
      end

      # See ::RGeo::Feature::Factory#multi_line_string

      def multi_line_string(elems_)
        elems_ = elems_.to_a unless elems_.is_a?(::Array)
        begin
          CAPIMultiLineStringImpl.create(self, elems_)
        rescue
          nil
        end
      end

      # See ::RGeo::Feature::Factory#multi_polygon

      def multi_polygon(elems_)
        elems_ = elems_.to_a unless elems_.is_a?(::Array)
        begin
          CAPIMultiPolygonImpl.create(self, elems_)
        rescue
          nil
        end
      end

      # See ::RGeo::Feature::Factory#proj4

      def proj4
        _proj4
      end

      # See ::RGeo::Feature::Factory#coord_sys

      def coord_sys
        _coord_sys
      end

      # See ::RGeo::Feature::Factory#override_cast

      def override_cast(original_, ntype_, flags_)
        return nil unless Geos.supported?
        keep_subtype_ = flags_[:keep_subtype]
        # force_new_ = flags_[:force_new]
        project_ = flags_[:project]
        type_ = original_.geometry_type
        ntype_ = type_ if keep_subtype_ && type_.include?(ntype_)
        case original_
        when CAPIGeometryMethods
          # Optimization if we're just changing factories, but the
          # factories are zm-compatible and proj4-compatible.
          if original_.factory != self && ntype_ == type_ &&
              original_.factory._flags & 0x6 == _flags & 0x6 &&
              (!project_ || original_.factory.proj4 == _proj4)
            result_ = original_.dup
            result_._set_factory(self)
            return result_
          end
          # LineString conversion optimization.
          if (original_.factory != self || ntype_ != type_) &&
              original_.factory._flags & 0x6 == _flags & 0x6 &&
              (!project_ || original_.factory.proj4 == _proj4) &&
              type_.subtype_of?(Feature::LineString) && ntype_.subtype_of?(Feature::LineString)
            return IMPL_CLASSES[ntype_]._copy_from(self, original_)
          end
        when ZMGeometryMethods
          # Optimization for just removing a coordinate from an otherwise
          # compatible factory
          if _flags & 0x6 == 0x2 && self == original_.factory.z_factory
            return Feature.cast(original_.z_geometry, ntype_, flags_)
          elsif _flags & 0x6 == 0x4 && self == original_.factory.m_factory
            return Feature.cast(original_.m_geometry, ntype_, flags_)
          end
        end
        false
      end

      # :stopdoc:

      IMPL_CLASSES = {
        Feature::Point => CAPIPointImpl,
        Feature::LineString => CAPILineStringImpl,
        Feature::LinearRing => CAPILinearRingImpl,
        Feature::Line => CAPILineImpl,
        Feature::GeometryCollection => CAPIGeometryCollectionImpl,
        Feature::MultiPoint => CAPIMultiPointImpl,
        Feature::MultiLineString => CAPIMultiLineStringImpl,
        Feature::MultiPolygon => CAPIMultiPolygonImpl
      }.freeze

      # :startdoc:
    end
  end
end
