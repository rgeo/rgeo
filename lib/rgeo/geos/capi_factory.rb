# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# GEOS factory implementation
#
# -----------------------------------------------------------------------------

module RGeo
  module Geos
    # This the GEOS CAPI implementation of RGeo::Feature::Factory.

    class CAPIFactory
      include Feature::Factory::Instance
      include ImplHelper::Utils

      class << self
        # Create a new factory. Returns nil if the GEOS CAPI implementation
        # is not supported.
        #
        # See RGeo::Geos.factory for a list of supported options.

        def create(opts_ = {})
          # Make sure GEOS is available
          return unless respond_to?(:_create)

          # Get flags to pass to the C extension
          flags = 0
          flags |= 1 if opts_[:uses_lenient_assertions] || opts_[:lenient_multi_polygon_assertions] || opts_[:uses_lenient_multi_polygon_assertions]
          flags |= 2 if opts_[:has_z_coordinate]
          flags |= 4 if opts_[:has_m_coordinate]
          if flags & 6 == 6
            raise Error::UnsupportedOperation, "GEOS cannot support both Z and M coordinates at the same time."
          end
          flags |= 8 unless opts_[:auto_prepare] == :disabled

          # Buffer resolution
          buffer_resolution_ = opts_[:buffer_resolution].to_i
          buffer_resolution_ = 1 if buffer_resolution_ < 1

          # Interpret the generator options
          wkt_generator_ = opts_[:wkt_generator]
          case wkt_generator_
          when :geos
            wkt_generator_ = nil
          when Hash
            wkt_generator_ = WKRep::WKTGenerator.new(wkt_generator_)
          else
            wkt_generator_ = WKRep::WKTGenerator.new(convert_case: :upper)
          end
          wkb_generator_ = opts_[:wkb_generator]
          case wkb_generator_
          when :geos
            wkb_generator_ = nil
          when Hash
            wkb_generator_ = WKRep::WKBGenerator.new(wkb_generator_)
          else
            wkb_generator_ = WKRep::WKBGenerator.new
          end

          # Coordinate system (srid, proj4, and coord_sys)
          srid_ = opts_[:srid]
          proj4_ = opts_[:proj4]
          if proj4_ && CoordSys.check!(:proj4)
            if proj4_.is_a?(String) || proj4_.is_a?(Hash)
              proj4_ = CoordSys::Proj4.create(proj4_)
            end
          else
            proj4_ = nil
          end
          coord_sys_ = opts_[:coord_sys]
          if coord_sys_.is_a?(String)
            coord_sys_ = CoordSys::CS.create_from_wkt(coord_sys_)
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
          result = _create(flags, srid_.to_i, buffer_resolution_,
            wkt_generator_, wkb_generator_, proj4_, coord_sys_)

          # Interpret parser options
          wkt_parser_ = opts_[:wkt_parser]
          case wkt_parser_
          when :geos
            wkt_parser_ = nil
          when Hash
            wkt_parser_ = WKRep::WKTParser.new(result, wkt_parser_)
          else
            wkt_parser_ = WKRep::WKTParser.new(result)
          end
          wkb_parser_ = opts_[:wkb_parser]
          case wkb_parser_
          when :geos
            wkb_parser_ = nil
          when Hash
            wkb_parser_ = WKRep::WKBParser.new(result, wkb_parser_)
          else
            wkb_parser_ = WKRep::WKBParser.new(result)
          end
          result._set_wkrep_parsers(wkt_parser_, wkb_parser_)

          # Return the result
          result
        end
        alias new create
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
      alias == eql?

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
          "wktg" => _wkt_generator ? _wkt_generator.properties : {},
          "wkbg" => _wkb_generator ? _wkb_generator.properties : {},
          "wktp" => _wkt_parser ? _wkt_parser.properties : {},
          "wkbp" => _wkb_parser ? _wkb_parser.properties : {},
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
        if (proj4_data_ = data_["proj4"]) && CoordSys.check!(:proj4)
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
        initialize_copy(
          CAPIFactory.create(
            has_z_coordinate: data_["hasz"],
            has_m_coordinate: data_["hasm"],
            srid: data_["srid"],
            buffer_resolution: data_["bufr"],
            wkt_generator: symbolize_hash(data_["wktg"]),
            wkb_generator: symbolize_hash(data_["wkbg"]),
            wkt_parser: symbolize_hash(data_["wktp"]),
            wkb_parser: symbolize_hash(data_["wkbp"]),
            uses_lenient_multi_polygon_assertions: data_["lmpa"],
            auto_prepare: (data_["apre"] == 0 ? :disabled : :simple),
            proj4: proj4_,
            coord_sys: coord_sys_
          )
        )
      end

      # Psych support

      def encode_with(coder_) # :nodoc:
        coder_["has_z_coordinate"] = (_flags & 0x2 != 0)
        coder_["has_m_coordinate"] = (_flags & 0x4 != 0)
        coder_["srid"] = _srid
        coder_["buffer_resolution"] = _buffer_resolution
        coder_["lenient_multi_polygon_assertions"] = (_flags & 0x1 != 0)
        coder_["wkt_generator"] = _wkt_generator ? _wkt_generator.properties : {}
        coder_["wkb_generator"] = _wkb_generator ? _wkb_generator.properties : {}
        coder_["wkt_parser"] = _wkt_parser ? _wkt_parser.properties : {}
        coder_["wkb_parser"] = _wkb_parser ? _wkb_parser.properties : {}
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
          CoordSys.check!(:proj4)
          if proj4_data_.is_a?(Hash)
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
        initialize_copy(
          CAPIFactory.create(
            has_z_coordinate: coder_["has_z_coordinate"],
            has_m_coordinate: coder_["has_m_coordinate"],
            srid: coder_["srid"],
            buffer_resolution: coder_["buffer_resolution"],
            wkt_generator: symbolize_hash(coder_["wkt_generator"]),
            wkb_generator: symbolize_hash(coder_["wkb_generator"]),
            wkt_parser: symbolize_hash(coder_["wkt_parser"]),
            wkb_parser: symbolize_hash(coder_["wkb_parser"]),
            auto_prepare: coder_["auto_prepare"] == "disabled" ? :disabled : :simple,
            uses_lenient_multi_polygon_assertions: coder_["lenient_multi_polygon_assertions"],
            proj4: proj4_,
            coord_sys: coord_sys_
          )
        )
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

      # See RGeo::Feature::Factory#property

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

      # See RGeo::Feature::Factory#parse_wkt

      def parse_wkt(str_)
        if (wkt_parser_ = _wkt_parser)
          wkt_parser_.parse(str_)
        else
          _parse_wkt_impl(str_)
        end
      end

      # See RGeo::Feature::Factory#parse_wkb

      def parse_wkb(str_)
        if (wkb_parser_ = _wkb_parser)
          wkb_parser_.parse(str_)
        else
          if str_[0] =~ /[0-oa-fA-F]/
            _parse_wkb_impl([str_].pack('H*'))
          else
            _parse_wkb_impl(str_)
          end
        end
      end

      # See RGeo::Feature::Factory#point

      def point(x_, y_, *extra_)
        if extra_.length > (_flags & 6 == 0 ? 0 : 1)
          raise(RGeo::Error::InvalidGeometry, "Parse error")
        else
          CAPIPointImpl.create(self, x_, y_, extra_[0].to_f)
        end
      end

      # See RGeo::Feature::Factory#line_string

      def line_string(points_)
        points_ = points_.to_a unless points_.is_a?(Array)
        CAPILineStringImpl.create(self, points_) ||
          raise(RGeo::Error::InvalidGeometry, "Parse error")
      end

      # See RGeo::Feature::Factory#line

      def line(start_, end_)
        CAPILineImpl.create(self, start_, end_)
      end

      # See RGeo::Feature::Factory#linear_ring

      def linear_ring(points_)
        points_ = points_.to_a unless points_.is_a?(Array)
        CAPILinearRingImpl.create(self, points_)
      end

      # See RGeo::Feature::Factory#polygon

      def polygon(outer_ring_, inner_rings_ = nil)
        inner_rings_ = inner_rings_.to_a unless inner_rings_.is_a?(Array)
        CAPIPolygonImpl.create(self, outer_ring_, inner_rings_)
      end

      # See RGeo::Feature::Factory#collection

      def collection(elems_)
        elems_ = elems_.to_a unless elems_.is_a?(Array)
        CAPIGeometryCollectionImpl.create(self, elems_)
      end

      # See RGeo::Feature::Factory#multi_point

      def multi_point(elems_)
        elems_ = elems_.to_a unless elems_.is_a?(Array)
        CAPIMultiPointImpl.create(self, elems_)
      end

      # See RGeo::Feature::Factory#multi_line_string

      def multi_line_string(elems_)
        elems_ = elems_.to_a unless elems_.is_a?(Array)
        CAPIMultiLineStringImpl.create(self, elems_)
      end

      # See RGeo::Feature::Factory#multi_polygon

      def multi_polygon(elems_)
        elems_ = elems_.to_a unless elems_.is_a?(Array)
        CAPIMultiPolygonImpl.create(self, elems_) ||
          raise(RGeo::Error::InvalidGeometry, "Parse error")
      end

      # See RGeo::Feature::Factory#proj4

      def proj4
        _proj4
      end

      # See RGeo::Feature::Factory#coord_sys

      def coord_sys
        _coord_sys
      end

      # See RGeo::Feature::Factory#override_cast

      def override_cast(original, ntype, flags)
        return unless Geos.supported?
        keep_subtype = flags[:keep_subtype]
        # force_new_ = flags[:force_new]
        project = flags[:project]
        type = original.geometry_type
        ntype = type if keep_subtype && type.include?(ntype)
        case original
        when CAPIGeometryMethods
          # Optimization if we're just changing factories, but the
          # factories are zm-compatible and proj4-compatible.
          if original.factory != self && ntype == type &&
              original.factory._flags & 0x6 == _flags & 0x6 &&
              (!project || original.factory.proj4 == _proj4)
            result = original.dup
            result.factory = self
            return result
          end
          # LineString conversion optimization.
          if (original.factory != self || ntype != type) &&
              original.factory._flags & 0x6 == _flags & 0x6 &&
              (!project || original.factory.proj4 == _proj4) &&
              type.subtype_of?(Feature::LineString) && ntype.subtype_of?(Feature::LineString)
            return IMPL_CLASSES[ntype]._copy_from(self, original)
          end
        when ZMGeometryMethods
          # Optimization for just removing a coordinate from an otherwise
          # compatible factory
          if _flags & 0x6 == 0x2 && self == original.factory.z_factory
            return Feature.cast(original.z_geometry, ntype, flags)
          elsif _flags & 0x6 == 0x4 && self == original.factory.m_factory
            return Feature.cast(original.m_geometry, ntype, flags)
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
