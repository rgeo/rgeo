# -----------------------------------------------------------------------------
#
# Well-known binary generator for RGeo
#
# -----------------------------------------------------------------------------

module RGeo
  module WKRep
    # This class provides the functionality of serializing a geometry as
    # WKB (well-known binary) format. You may also customize the
    # serializer to generate PostGIS EWKB extensions to the output, or to
    # follow the Simple Features Specification 1.2 extensions for Z and M
    # coordinates.
    #
    # To use this class, create an instance with the desired settings and
    # customizations, and call the generate method.
    #
    # === Configuration options
    #
    # The following options are recognized. These can be passed to the
    # constructor, or set on the object afterwards.
    #
    # [<tt>:type_format</tt>]
    #   The format for type codes. Possible values are <tt>:wkb11</tt>,
    #   indicating SFS 1.1 WKB (i.e. no Z or M values); <tt>:ewkb</tt>,
    #   indicating the PostGIS EWKB extensions (i.e. Z and M presence
    #   flagged by the two high bits of the type code, and support for
    #   embedded SRID); or <tt>:wkb12</tt> (indicating SFS 1.2 WKB
    #   (i.e. Z and M presence flagged by adding 1000 and/or 2000 to
    #   the type code.) Default is <tt>:wkb11</tt>.
    # [<tt>:emit_ewkb_srid</tt>]
    #   If true, embed the SRID in the toplevel geometry. Available only
    #   if <tt>:type_format</tt> is <tt>:ewkb</tt>. Default is false.
    # [<tt>:hex_format</tt>]
    #   If true, output a hex string instead of a byte string.
    #   Default is false.
    # [<tt>:little_endian</tt>]
    #   If true, output little endian (NDR) byte order. If false, output
    #   big endian (XDR), or network byte order. Default is false.

    class WKBGenerator
      # :stopdoc:
      TYPE_CODES = {
        Feature::Point => 1,
        Feature::LineString => 2,
        Feature::LinearRing => 2,
        Feature::Line => 2,
        Feature::Polygon => 3,
        Feature::MultiPoint => 4,
        Feature::MultiLineString => 5,
        Feature::MultiPolygon => 6,
        Feature::GeometryCollection => 7
      }.freeze
      # :startdoc:

      # Create and configure a WKB generator. See the WKBGenerator
      # documentation for the options that can be passed.

      def initialize(opts = {})
        @type_format = opts[:type_format] || :wkb11
        @emit_ewkb_srid = @type_format == :ewkb ?
          (opts[:emit_ewkb_srid] ? true : false) : nil
        @hex_format = opts[:hex_format] ? true : false
        @little_endian = opts[:little_endian] ? true : false
      end

      # Returns the format for type codes. See WKBGenerator for details.
      attr_reader :type_format

      # Returns whether SRID is embedded. See WKBGenerator for details.
      def emit_ewkb_srid?
        @emit_ewkb_srid
      end

      # Returns whether output is converted to hex.
      # See WKBGenerator for details.
      def hex_format?
        @hex_format
      end

      # Returns whether output is little-endian (NDR).
      # See WKBGenerator for details.
      def little_endian?
        @little_endian
      end

      def _properties # :nodoc:
        {
          "type_format" => @type_format.to_s,
          "emit_ewkb_srid" => @emit_ewkb_srid,
          "hex_format" => @hex_format,
          "little_endian" => @little_endian
        }
      end

      # Generate and return the WKB format for the given geometry object,
      # according to the current settings.

      def generate(obj)
        factory = obj.factory
        if @type_format == :ewkb || @type_format == :wkb12
          @cur_has_z = factory.property(:has_z_coordinate)
          @cur_has_m = factory.property(:has_m_coordinate)
        else
          @cur_has_z = nil
          @cur_has_m = nil
        end
        @cur_dims = 2 + (@cur_has_z ? 1 : 0) + (@cur_has_m ? 1 : 0)
        _start_emitter
        _generate_feature(obj, true)
        _finish_emitter
      end

      def _generate_feature(obj, toplevel = false) # :nodoc:
        _emit_byte(@little_endian ? 1 : 0)
        type = obj.geometry_type
        type_code = TYPE_CODES[type]
        unless type_code
          raise Error::ParseError, "Unrecognized Geometry Type: #{type}"
        end
        emit_srid = false
        if @type_format == :ewkb
          type_code |= 0x80000000 if @cur_has_z
          type_code |= 0x40000000 if @cur_has_m
          if @emit_ewkb_srid && toplevel
            type_code |= 0x20000000
            emit_srid = true
          end
        elsif @type_format == :wkb12
          type_code += 1000 if @cur_has_z
          type_code += 2000 if @cur_has_m
        end
        _emit_integer(type_code)
        _emit_integer(obj.srid) if emit_srid
        if type == Feature::Point
          _emit_doubles(_point_coords(obj))
        elsif type.subtype_of?(Feature::LineString)
          _emit_line_string_coords(obj)
        elsif type == Feature::Polygon
          exterior_ring = obj.exterior_ring
          if exterior_ring.is_empty?
            _emit_integer(0)
          else
            _emit_integer(1 + obj.num_interior_rings)
            _emit_line_string_coords(exterior_ring)
            obj.interior_rings.each { |r| _emit_line_string_coords(r) }
          end
        elsif type == Feature::GeometryCollection
          _emit_integer(obj.num_geometries)
          obj.each { |g| _generate_feature(g) }
        elsif type == Feature::MultiPoint
          _emit_integer(obj.num_geometries)
          obj.each { |g| _generate_feature(g) }
        elsif type == Feature::MultiLineString
          _emit_integer(obj.num_geometries)
          obj.each { |g| _generate_feature(g) }
        elsif type == Feature::MultiPolygon
          _emit_integer(obj.num_geometries)
          obj.each { |g| _generate_feature(g) }
        end
      end

      def _point_coords(obj, array = []) # :nodoc:
        array << obj.x
        array << obj.y
        array << obj.z if @cur_has_z
        array << obj.m if @cur_has_m
        array
      end

      def _emit_line_string_coords(obj) # :nodoc:
        array = []
        obj.points.each { |p| _point_coords(p, array) }
        _emit_integer(obj.num_points)
        _emit_doubles(array)
      end

      def _start_emitter # :nodoc:
        @cur_array = []
      end

      def _emit_byte(value) # :nodoc:
        @cur_array << [value].pack("C")
      end

      def _emit_integer(value)  # :nodoc:
        @cur_array << [value].pack(@little_endian ? "V" : "N")
      end

      def _emit_doubles(array)  # :nodoc:
        @cur_array << array.pack(@little_endian ? "E*" : "G*")
      end

      def _finish_emitter # :nodoc:
        str = @cur_array.join
        @cur_array = nil
        @hex_format ? str.unpack("H*")[0] : str
      end
    end
  end
end
