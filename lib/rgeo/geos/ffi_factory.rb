# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# FFI-GEOS factory implementation
#
# -----------------------------------------------------------------------------

module RGeo
  module Geos
    # This the FFI-GEOS implementation of RGeo::Feature::Factory.

    class FFIFactory
      include Feature::Factory::Instance
      include ImplHelper::Utils

      # Create a new factory. Returns nil if the FFI-GEOS implementation
      # is not supported.
      #
      # See RGeo::Geos.factory for a list of supported options.

      def initialize(opts = {})
        # Main flags
        @uses_lenient_multi_polygon_assertions = opts[:uses_lenient_assertions] ||
          opts[:lenient_multi_polygon_assertions] || opts[:uses_lenient_multi_polygon_assertions]
        @has_z = opts[:has_z_coordinate] ? true : false
        @has_m = opts[:has_m_coordinate] ? true : false
        if @has_z && @has_m
          raise Error::UnsupportedOperation, "GEOS cannot support both Z and M coordinates at the same time."
        end
        @_has_3d = @has_z || @has_m
        @buffer_resolution = opts[:buffer_resolution].to_i
        @buffer_resolution = 1 if @buffer_resolution < 1
        @_auto_prepare = opts[:auto_prepare] == :disabled ? false : true

        # Interpret the generator options
        wkt_generator_ = opts[:wkt_generator]
        case wkt_generator_
        when :geos
          @wkt_writer = ::Geos::WktWriter.new
          @wkt_generator = nil
        when Hash
          @wkt_generator = WKRep::WKTGenerator.new(wkt_generator_)
          @wkt_writer = nil
        else
          @wkt_generator = WKRep::WKTGenerator.new(convert_case: :upper)
          @wkt_writer = nil
        end
        wkb_generator_ = opts[:wkb_generator]
        case wkb_generator_
        when :geos
          @wkb_writer = ::Geos::WkbWriter.new
          @wkb_generator = nil
        when Hash
          @wkb_generator = WKRep::WKBGenerator.new(wkb_generator_)
          @wkb_writer = nil
        else
          @wkb_generator = WKRep::WKBGenerator.new
          @wkb_writer = nil
        end

        # Coordinate system (srid, proj4, and coord_sys)
        @srid = opts[:srid]
        @proj4 = opts[:proj4]
        if @proj4 && CoordSys.check!(:proj4)
          if @proj4.is_a?(String) || @proj4.is_a?(Hash)
            @proj4 = CoordSys::Proj4.create(@proj4)
          end
        else
          @proj4 = nil
        end
        @coord_sys = opts[:coord_sys]
        if @coord_sys.is_a?(String)
          @coord_sys = CoordSys::CS.create_from_wkt(@coord_sys)
        end
        if (!@proj4 || !@coord_sys) && @srid && (db = opts[:srs_database])
          entry = db.get(@srid.to_i)
          if entry
            @proj4 ||= entry.proj4
            @coord_sys ||= entry.coord_sys
          end
        end
        @srid ||= @coord_sys.authority_code if @coord_sys
        @srid = @srid.to_i

        # Interpret parser options
        wkt_parser = opts[:wkt_parser]
        case wkt_parser
        when :geos
          @wkt_reader = ::Geos::WktReader.new
          @wkt_parser = nil
        when Hash
          @wkt_parser = WKRep::WKTParser.new(self, wkt_parser)
          @wkt_reader = nil
        else
          @wkt_parser = WKRep::WKTParser.new(self)
          @wkt_reader = nil
        end
        wkb_parser = opts[:wkb_parser]
        case wkb_parser
        when :geos
          @wkb_reader = ::Geos::WkbReader.new
          @wkb_parser = nil
        when Hash
          @wkb_parser = WKRep::WKBParser.new(self, wkb_parser)
          @wkb_reader = nil
        else
          @wkb_parser = WKRep::WKBParser.new(self)
          @wkb_reader = nil
        end
      end

      # Standard object inspection output

      def inspect
        "#<#{self.class}:0x#{object_id.to_s(16)} srid=#{srid}>"
      end

      # Factory equivalence test.

      def eql?(rhs)
        rhs.is_a?(self.class) && @srid == rhs.srid &&
          @has_z == rhs.property(:has_z_coordinate) &&
          @has_m == rhs.property(:has_m_coordinate) &&
          @buffer_resolution == rhs.property(:buffer_resolution) &&
          @proj4.eql?(rhs.proj4)
      end
      alias == eql?

      # Standard hash code

      def hash
        @hash ||= [@srid, @has_z, @has_m, @buffer_resolution, @proj4].hash
      end

      # Marshal support

      def marshal_dump # :nodoc:
        hash = {
          "hasz" => @has_z,
          "hasm" => @has_m,
          "srid" => @srid,
          "bufr" => @buffer_resolution,
          "wktg" => @wkt_generator.properties,
          "wkbg" => @wkb_generator.properties,
          "wktp" => @wkt_parser.properties,
          "wkbp" => @wkb_parser.properties,
          "lmpa" => @uses_lenient_multi_polygon_assertions,
          "apre" => @_auto_prepare
        }
        hash["proj4"] = @proj4.marshal_dump if @proj4
        hash["cs"] = @coord_sys.to_wkt if @coord_sys
        hash
      end

      def marshal_load(data) # :nodoc:
        if (proj4_data = data["proj4"]) && CoordSys.check!(:proj4)
          proj4 = CoordSys::Proj4.allocate
          proj4.marshal_load(proj4_data)
        else
          proj4 = nil
        end
        if (coord_sys_data = data["cs"])
          coord_sys = CoordSys::CS.create_from_wkt(coord_sys_data)
        else
          coord_sys = nil
        end
        initialize(
          has_z_coordinate: data["hasz"],
          has_m_coordinate: data["hasm"],
          srid: data["srid"],
          buffer_resolution: data["bufr"],
          wkt_generator: symbolize_hash(data["wktg"]),
          wkb_generator: symbolize_hash(data["wkbg"]),
          wkt_parser: symbolize_hash(data["wktp"]),
          wkb_parser: symbolize_hash(data["wkbp"]),
          uses_lenient_multi_polygon_assertions: data["lmpa"],
          auto_prepare: (data["apre"] ? :simple : :disabled),
          proj4: proj4,
          coord_sys: coord_sys
        )
      end

      # Psych support

      def encode_with(coder) # :nodoc:
        coder["has_z_coordinate"] = @has_z
        coder["has_m_coordinate"] = @has_m
        coder["srid"] = @srid
        coder["buffer_resolution"] = @buffer_resolution
        coder["lenient_multi_polygon_assertions"] = @uses_lenient_multi_polygon_assertions
        coder["wkt_generator"] = @wkt_generator.properties
        coder["wkb_generator"] = @wkb_generator.properties
        coder["wkt_parser"] = @wkt_parser.properties
        coder["wkb_parser"] = @wkb_parser.properties
        coder["auto_prepare"] = @_auto_prepare ? "simple" : "disabled"
        if @proj4
          str = @proj4.original_str || @proj4.canonical_str
          coder["proj4"] = @proj4.radians? ? { "proj4" => str, "radians" => true } : str
        end
        coder["coord_sys"] = @coord_sys.to_wkt if @coord_sys
      end

      def init_with(coder) # :nodoc:
        if (proj4_data = coder["proj4"])
          CoordSys.check!(:proj4)
          if proj4_data.is_a?(Hash)
            proj4 = CoordSys::Proj4.create(proj4_data["proj4"], radians: proj4_data["radians"])
          else
            proj4 = CoordSys::Proj4.create(proj4_data.to_s)
          end
        else
          proj4 = nil
        end
        if (coord_sys_data = coder["cs"])
          coord_sys = CoordSys::CS.create_from_wkt(coord_sys_data.to_s)
        else
          coord_sys = nil
        end
        initialize(
          has_z_coordinate: coder["has_z_coordinate"],
          has_m_coordinate: coder["has_m_coordinate"],
          srid: coder["srid"],
          buffer_resolution: coder["buffer_resolution"],
          wkt_generator: symbolize_hash(coder["wkt_generator"]),
          wkb_generator: symbolize_hash(coder["wkb_generator"]),
          wkt_parser: symbolize_hash(coder["wkt_parser"]),
          wkb_parser: symbolize_hash(coder["wkb_parser"]),
          auto_prepare: coder["auto_prepare"] == "disabled" ? :disabled : :simple,
          uses_lenient_multi_polygon_assertions: coder["lenient_multi_polygon_assertions"],
          proj4: proj4,
          coord_sys: coord_sys
        )
      end

      # Returns the SRID of geometries created by this factory.

      attr_reader :srid

      # Returns the resolution used by buffer calculations on geometries
      # created by this factory

      attr_reader :buffer_resolution

      # Returns true if this factory is lenient with MultiPolygon assertions

      def lenient_multi_polygon_assertions?
        @uses_lenient_multi_polygon_assertions
      end

      # See RGeo::Feature::Factory#property

      def property(name_)
        case name_
        when :has_z_coordinate
          @has_z
        when :has_m_coordinate
          @has_m
        when :is_cartesian
          true
        when :buffer_resolution
          @buffer_resolution
        when :uses_lenient_multi_polygon_assertions
          @uses_lenient_multi_polygon_assertions
        when :auto_prepare
          @_auto_prepare ? :simple : :disabled
        end
      end

      # See RGeo::Feature::Factory#parse_wkt

      def parse_wkt(str)
        if @wkt_reader
          wrap_fg_geom(@wkt_reader.read(str), nil)
        else
          @wkt_parser.parse(str)
        end
      end

      # See RGeo::Feature::Factory#parse_wkb

      def parse_wkb(str)
        if @wkb_reader
          wrap_fg_geom(@wkb_reader.read(str), nil)
        else
          @wkb_parser.parse(str)
        end
      end

      # See RGeo::Feature::Factory#point

      def point(x, y, z = 0)
        cs = ::Geos::CoordinateSequence.new(1, 3)
        cs.set_x(0, x)
        cs.set_y(0, y)
        cs.set_z(0, z)
        FFIPointImpl.new(self, ::Geos::Utils.create_point(cs), nil)
      end

      # See RGeo::Feature::Factory#line_string

      def line_string(points)
        points = points.to_a unless points.is_a?(Array)
        size = points.size
        raise(Error::InvalidGeometry, "Must have more than one point") if size == 1
        cs = ::Geos::CoordinateSequence.new(size, 3)
        points.each_with_index do |p, i|
          raise(Error::InvalidGeometry, "Invalid point: #{p}") unless RGeo::Feature::Point.check_type(p)
          cs.set_x(i, p.x)
          cs.set_y(i, p.y)
          if @has_z
            cs.set_z(i, p.z)
          elsif @has_m
            cs.set_z(i, p.m)
          end
        end
        FFILineStringImpl.new(self, ::Geos::Utils.create_line_string(cs), nil)
      end

      # See RGeo::Feature::Factory#line

      def line(start, stop)
        return unless RGeo::Feature::Point.check_type(start) &&
          RGeo::Feature::Point.check_type(stop)
        cs = ::Geos::CoordinateSequence.new(2, 3)
        cs.set_x(0, start.x)
        cs.set_x(1, stop.x)
        cs.set_y(0, start.y)
        cs.set_y(1, stop.y)
        if @has_z
          cs.set_z(0, start.z)
          cs.set_z(1, stop.z)
        elsif @has_m
          cs.set_z(0, start.m)
          cs.set_z(1, stop.m)
        end
        FFILineImpl.new(self, ::Geos::Utils.create_line_string(cs), nil)
      end

      # See RGeo::Feature::Factory#linear_ring

      def linear_ring(points)
        points = points.to_a unless points.is_a?(Array)
        fg_geom = create_fg_linear_ring(points)
        FFILinearRingImpl.new(self, fg_geom, nil)
      end

      # See RGeo::Feature::Factory#polygon

      def polygon(outer_ring, inner_rings = nil)
        inner_rings = inner_rings.to_a unless inner_rings.is_a?(Array)
        return unless RGeo::Feature::LineString.check_type(outer_ring)
        outer_ring = create_fg_linear_ring(outer_ring.points)
        inner_rings = inner_rings.map do |r|
          return unless RGeo::Feature::LineString.check_type(r)
          create_fg_linear_ring(r.points)
        end
        inner_rings.compact!
        fg_geom = ::Geos::Utils.create_polygon(outer_ring, *inner_rings)
        FFIPolygonImpl.new(self, fg_geom, nil)
      end

      # See RGeo::Feature::Factory#collection

      def collection(elems)
        elems = elems.to_a unless elems.is_a?(Array)
        klasses = []
        my_fg_geoms = []
        elems.each do |elem|
          k = elem._klasses if elem.factory.is_a?(FFIFactory)
          elem = RGeo::Feature.cast(elem, self, :force_new, :keep_subtype)
          if elem
            klasses << (k || elem.class)
            my_fg_geoms << elem.detach_fg_geom
          end
        end
        fg_geom = ::Geos::Utils.create_collection(::Geos::GeomTypes::GEOS_GEOMETRYCOLLECTION, my_fg_geoms)
        FFIGeometryCollectionImpl.new(self, fg_geom, klasses)
      end

      # See RGeo::Feature::Factory#multi_point

      def multi_point(elems)
        elems = elems.to_a unless elems.is_a?(Array)
        elems = elems.map do |elem|
          elem = RGeo::Feature.cast(elem, self, RGeo::Feature::Point,
            :force_new, :keep_subtype)
          return unless elem
          elem.detach_fg_geom
        end
        klasses = Array.new(elems.size, FFIPointImpl)
        fg_geom = ::Geos::Utils.create_collection(::Geos::GeomTypes::GEOS_MULTIPOINT, elems)
        FFIMultiPointImpl.new(self, fg_geom, klasses)
      end

      # See RGeo::Feature::Factory#multi_line_string

      def multi_line_string(elems)
        elems = elems.to_a unless elems.is_a?(Array)
        klasses = []
        elems = elems.map do |elem|
          elem = RGeo::Feature.cast(elem, self, RGeo::Feature::LineString, :force_new, :keep_subtype)
          raise(RGeo::Error::InvalidGeometry, "Parse error") unless elem
          klasses << elem.class
          elem.detach_fg_geom
        end
        fg_geom = ::Geos::Utils.create_collection(::Geos::GeomTypes::GEOS_MULTILINESTRING, elems)
        FFIMultiLineStringImpl.new(self, fg_geom, klasses)
      end

      # See RGeo::Feature::Factory#multi_polygon

      def multi_polygon(elems)
        elems = elems.to_a unless elems.is_a?(Array)
        elems = elems.map do |elem|
          elem = RGeo::Feature.cast(elem, self, RGeo::Feature::Polygon, :force_new, :keep_subtype)
          raise(RGeo::Error::InvalidGeometry, "Could not cast to polygon: #{elem}") unless elem
          elem.detach_fg_geom
        end
        unless @uses_lenient_multi_polygon_assertions
          (1...elems.size).each do |i|
            (0...i).each do |j|
              igeom = elems[i]
              jgeom = elems[j]
              if igeom.relate_pattern(jgeom, "2********") || igeom.relate_pattern(jgeom, "****1****")
                raise(RGeo::Error::InvalidGeometry, "Invalid relate pattern: #{jgeom}")
              end
            end
          end
        end
        klasses = Array.new(elems.size, FFIPolygonImpl)
        fg_geom = ::Geos::Utils.create_collection(::Geos::GeomTypes::GEOS_MULTIPOLYGON, elems)
        FFIMultiPolygonImpl.new(self, fg_geom, klasses)
      end

      # See RGeo::Feature::Factory#proj4

      attr_reader :proj4

      # See RGeo::Feature::Factory#coord_sys

      attr_reader :coord_sys

      # See RGeo::Feature::Factory#override_cast

      def override_cast(original, ntype, flags)
        false
        # TODO
      end

      # Create a feature that wraps the given ffi-geos geometry object
      def wrap_fg_geom(fg_geom, klass = nil)
        klasses = nil

        # We don't allow "empty" points, so replace such objects with
        # an empty collection.
        if fg_geom.type_id == ::Geos::GeomTypes::GEOS_POINT && fg_geom.empty?
          fg_geom = ::Geos::Utils.create_geometry_collection
          klass = FFIGeometryCollectionImpl
        end

        unless klass.is_a?(::Class)
          is_collection = false
          case fg_geom.type_id
          when ::Geos::GeomTypes::GEOS_POINT
            inferred_klass = FFIPointImpl
          when ::Geos::GeomTypes::GEOS_MULTIPOINT
            inferred_klass = FFIMultiPointImpl
            is_collection = true
          when ::Geos::GeomTypes::GEOS_LINESTRING
            inferred_klass = FFILineStringImpl
          when ::Geos::GeomTypes::GEOS_LINEARRING
            inferred_klass = FFILinearRingImpl
          when ::Geos::GeomTypes::GEOS_MULTILINESTRING
            inferred_klass = FFIMultiLineStringImpl
            is_collection = true
          when ::Geos::GeomTypes::GEOS_POLYGON
            inferred_klass = FFIPolygonImpl
          when ::Geos::GeomTypes::GEOS_MULTIPOLYGON
            inferred_klass = FFIMultiPolygonImpl
            is_collection = true
          when ::Geos::GeomTypes::GEOS_GEOMETRYCOLLECTION
            inferred_klass = FFIGeometryCollectionImpl
            is_collection = true
          else
            inferred_klass = FFIGeometryImpl
          end
          klasses = klass if is_collection && klass.is_a?(Array)
          klass = inferred_klass
        end
        klass.new(self, fg_geom, klasses)
      end

      attr_reader :_has_3d # :nodoc:
      attr_reader :_auto_prepare # :nodoc:

      def convert_to_fg_geometry(obj, type = nil)
        if type && obj.factory != self
          obj = Feature.cast(obj, self, type)
        end
        obj&.fg_geom
      end

      def generate_wkt(geom)
        if @wkt_writer
          @wkt_writer.write(geom.fg_geom)
        else
          @wkt_generator.generate(geom)
        end
      end

      def generate_wkb(geom)
        if @wkb_writer
          @wkb_writer.write(geom.fg_geom)
        else
          @wkb_generator.generate(geom)
        end
      end

      def write_for_marshal(geom)
        if Utils.ffi_supports_set_output_dimension || !@_has_3d
          wkb_writer = ::Geos::WkbWriter.new
          wkb_writer.output_dimensions = 3 if @_has_3d
          wkb_writer.write(geom.fg_geom)
        else
          Utils.marshal_wkb_generator.generate(geom)
        end
      end

      def read_for_marshal(str)
        ::Geos::WkbReader.new.read(str)
      end

      def write_for_psych(geom)
        if Utils.ffi_supports_set_output_dimension || !@_has_3d
          wkt_writer = ::Geos::WktWriter.new
          wkt_writer.output_dimensions = 3 if @_has_3d
          wkt_writer.write(geom.fg_geom)
        else
          Utils.psych_wkt_generator.generate(geom)
        end
      end

      def read_for_psych(str)
        ::Geos::WktReader.new.read(str)
      end

      private

      def create_fg_linear_ring(points)
        size = points.size
        return if size == 1 || size == 2
        if size > 0 && points.first != points.last
          points += [points.first]
          size += 1
        end
        cs = ::Geos::CoordinateSequence.new(size, 3)
        points.each_with_index do |p, i|
          return unless RGeo::Feature::Point.check_type(p)
          cs.set_x(i, p.x)
          cs.set_y(i, p.y)
          if @has_z
            cs.set_z(i, p.z)
          elsif @has_m
            cs.set_z(i, p.m)
          end
        end
        ::Geos::Utils.create_linear_ring(cs)
      end
    end
  end
end
