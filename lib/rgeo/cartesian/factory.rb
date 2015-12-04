# -----------------------------------------------------------------------------
#
# Geographic data factory implementation
#
# -----------------------------------------------------------------------------

module RGeo
  module Cartesian
    # This class implements the factory for the simple cartesian
    # implementation.

    class Factory
      include Feature::Factory::Instance

      # Create a new simple cartesian factory.
      #
      # See ::RGeo::Cartesian.simple_factory for a list of supported options.

      def initialize(opts_ = {})
        @has_z = opts_[:has_z_coordinate] ? true : false
        @has_m = opts_[:has_m_coordinate] ? true : false
        @proj4 = opts_[:proj4]
        if CoordSys::Proj4.supported?
          if @proj4.is_a?(::String) || @proj4.is_a?(::Hash)
            @proj4 = CoordSys::Proj4.create(@proj4)
          end
        else
          @proj4 = nil
        end
        srid_ = opts_[:srid]
        @coord_sys = opts_[:coord_sys]
        if @coord_sys.is_a?(::String)
          @coord_sys = begin
                         CoordSys::CS.create_from_wkt(@coord_sys)
                       rescue
                         nil
                       end
        end
        if (!@proj4 || !@coord_sys) && srid_ && (db_ = opts_[:srs_database])
          entry_ = db_.get(srid_.to_i)
          if entry_
            @proj4 ||= entry_.proj4
            @coord_sys ||= entry_.coord_sys
          end
        end
        srid_ ||= @coord_sys.authority_code if @coord_sys
        @srid = srid_.to_i
        @lenient_assertions = opts_[:uses_lenient_assertions] ? true : false
        @buffer_resolution = opts_[:buffer_resolution].to_i
        @buffer_resolution = 1 if @buffer_resolution < 1

        wkt_generator_ = opts_[:wkt_generator]
        case wkt_generator_
        when ::Hash
          @wkt_generator = WKRep::WKTGenerator.new(wkt_generator_)
        else
          @wkt_generator = WKRep::WKTGenerator.new(convert_case: :upper)
        end
        wkb_generator_ = opts_[:wkb_generator]
        case wkb_generator_
        when ::Hash
          @wkb_generator = WKRep::WKBGenerator.new(wkb_generator_)
        else
          @wkb_generator = WKRep::WKBGenerator.new
        end
        wkt_parser_ = opts_[:wkt_parser]
        case wkt_parser_
        when ::Hash
          @wkt_parser = WKRep::WKTParser.new(self, wkt_parser_)
        else
          @wkt_parser = WKRep::WKTParser.new(self)
        end
        wkb_parser_ = opts_[:wkb_parser]
        case wkb_parser_
        when ::Hash
          @wkb_parser = WKRep::WKBParser.new(self, wkb_parser_)
        else
          @wkb_parser = WKRep::WKBParser.new(self)
        end
      end

      # Equivalence test.

      def eql?(rhs_)
        rhs_.is_a?(self.class) && @srid == rhs_.srid &&
          @has_z == rhs_.property(:has_z_coordinate) &&
          @has_m == rhs_.property(:has_m_coordinate) &&
          @proj4.eql?(rhs_.proj4)
      end
      alias_method :==, :eql?

      # Standard hash code

      def hash
        @hash ||= [@srid, @has_z, @has_m, @proj4].hash
      end

      # Marshal support

      def marshal_dump # :nodoc:
        hash_ = {
          "hasz" => @has_z,
          "hasm" => @has_m,
          "srid" => @srid,
          "wktg" => @wkt_generator._properties,
          "wkbg" => @wkb_generator._properties,
          "wktp" => @wkt_parser._properties,
          "wkbp" => @wkb_parser._properties,
          "lena" => @lenient_assertions,
          "bufr" => @buffer_resolution
        }
        hash_["proj4"] = @proj4.marshal_dump if @proj4
        hash_["cs"] = @coord_sys.to_wkt if @coord_sys
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
        initialize(
          has_z_coordinate: data_["hasz"],
          has_m_coordinate: data_["hasm"],
          srid: data_["srid"],
          wkt_generator: ImplHelper::Utils.symbolize_hash(data_["wktg"]),
          wkb_generator: ImplHelper::Utils.symbolize_hash(data_["wkbg"]),
          wkt_parser: ImplHelper::Utils.symbolize_hash(data_["wktp"]),
          wkb_parser: ImplHelper::Utils.symbolize_hash(data_["wkbp"]),
          uses_lenient_assertions: data_["lena"],
          buffer_resolution: data_["bufr"],
          proj4: proj4_,
          coord_sys: coord_sys_
        )
      end

      # Psych support

      def encode_with(coder_) # :nodoc:
        coder_["has_z_coordinate"] = @has_z
        coder_["has_m_coordinate"] = @has_m
        coder_["srid"] = @srid
        coder_["lenient_assertions"] = @lenient_assertions
        coder_["buffer_resolution"] = @buffer_resolution
        coder_["wkt_generator"] = @wkt_generator._properties
        coder_["wkb_generator"] = @wkb_generator._properties
        coder_["wkt_parser"] = @wkt_parser._properties
        coder_["wkb_parser"] = @wkb_parser._properties
        if @proj4
          str_ = @proj4.original_str || @proj4.canonical_str
          coder_["proj4"] = @proj4.radians? ? { "proj4" => str_, "radians" => true } : str_
        end
        coder_["coord_sys"] = @coord_sys.to_wkt if @coord_sys
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
        initialize(
          has_z_coordinate: coder_["has_z_coordinate"],
          has_m_coordinate: coder_["has_m_coordinate"],
          srid: coder_["srid"],
          wkt_generator: ImplHelper::Utils.symbolize_hash(coder_["wkt_generator"]),
          wkb_generator: ImplHelper::Utils.symbolize_hash(coder_["wkb_generator"]),
          wkt_parser: ImplHelper::Utils.symbolize_hash(coder_["wkt_parser"]),
          wkb_parser: ImplHelper::Utils.symbolize_hash(coder_["wkb_parser"]),
          uses_lenient_assertions: coder_["lenient_assertions"],
          buffer_resolution: coder_["buffer_resolution"],
          proj4: proj4_,
          coord_sys: coord_sys_
        )
      end

      # Returns the SRID.

      attr_reader :srid

      # See ::RGeo::Feature::Factory#property

      def property(name_)
        case name_
        when :has_z_coordinate
          @has_z
        when :has_m_coordinate
          @has_m
        when :uses_lenient_assertions
          @lenient_assertions
        when :buffer_resolution
          @buffer_resolution
        when :is_cartesian
          true
        end
      end

      # See ::RGeo::Feature::Factory#parse_wkt

      def parse_wkt(str_)
        @wkt_parser.parse(str_)
      end

      # See ::RGeo::Feature::Factory#parse_wkb

      def parse_wkb(str_)
        @wkb_parser.parse(str_)
      end

      # See ::RGeo::Feature::Factory#point

      def point(x_, y_, *extra_)
        PointImpl.new(self, x_, y_, *extra_)
      rescue
        nil
      end

      # See ::RGeo::Feature::Factory#line_string

      def line_string(points_)
        LineStringImpl.new(self, points_)
      rescue
        nil
      end

      # See ::RGeo::Feature::Factory#line

      def line(start_, end_)
        LineImpl.new(self, start_, end_)
      rescue
        nil
      end

      # See ::RGeo::Feature::Factory#linear_ring

      def linear_ring(points_)
        LinearRingImpl.new(self, points_)
      rescue
        nil
      end

      # See ::RGeo::Feature::Factory#polygon

      def polygon(outer_ring_, inner_rings_ = nil)
        PolygonImpl.new(self, outer_ring_, inner_rings_)
      rescue
        nil
      end

      # See ::RGeo::Feature::Factory#collection

      def collection(elems_)
        GeometryCollectionImpl.new(self, elems_)
      rescue
        nil
      end

      # See ::RGeo::Feature::Factory#multi_point

      def multi_point(elems_)
        MultiPointImpl.new(self, elems_)
      rescue
        nil
      end

      # See ::RGeo::Feature::Factory#multi_line_string

      def multi_line_string(elems_)
        MultiLineStringImpl.new(self, elems_)
      rescue
        nil
      end

      # See ::RGeo::Feature::Factory#multi_polygon

      def multi_polygon(elems_)
        MultiPolygonImpl.new(self, elems_)
      rescue
        nil
      end

      # See ::RGeo::Feature::Factory#proj4

      attr_reader :proj4

      # See ::RGeo::Feature::Factory#coord_sys

      attr_reader :coord_sys

      def _generate_wkt(obj_)  # :nodoc:
        @wkt_generator.generate(obj_)
      end

      def _generate_wkb(obj_)  # :nodoc:
        @wkb_generator.generate(obj_)
      end

      def _marshal_wkb_generator # :nodoc:
        unless defined?(@marshal_wkb_generator)
          @marshal_wkb_generator = ::RGeo::WKRep::WKBGenerator.new(
            type_format: :wkb12)
        end
        @marshal_wkb_generator
      end

      def _marshal_wkb_parser # :nodoc:
        unless defined?(@marshal_wkb_parser)
          @marshal_wkb_parser = ::RGeo::WKRep::WKBParser.new(self,
            support_wkb12: true)
        end
        @marshal_wkb_parser
      end

      def _psych_wkt_generator # :nodoc:
        unless defined?(@psych_wkt_generator)
          @psych_wkt_generator = ::RGeo::WKRep::WKTGenerator.new(
            tag_format: :wkt12)
        end
        @psych_wkt_generator
      end

      def _psych_wkt_parser # :nodoc:
        unless defined?(@psych_wkt_parser)
          @psych_wkt_parser = ::RGeo::WKRep::WKTParser.new(self,
            support_wkt12: true, support_ewkt: true)
        end
        @psych_wkt_parser
      end
    end
  end
end
