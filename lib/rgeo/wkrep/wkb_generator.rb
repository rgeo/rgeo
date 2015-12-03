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

      def initialize(opts_ = {})
        @type_format = opts_[:type_format] || :wkb11
        @emit_ewkb_srid = @type_format == :ewkb ?
          (opts_[:emit_ewkb_srid] ? true : false) : nil
        @hex_format = opts_[:hex_format] ? true : false
        @little_endian = opts_[:little_endian] ? true : false
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

      def generate(obj_)
        factory_ = obj_.factory
        if @type_format == :ewkb || @type_format == :wkb12
          @cur_has_z = factory_.property(:has_z_coordinate)
          @cur_has_m = factory_.property(:has_m_coordinate)
        else
          @cur_has_z = nil
          @cur_has_m = nil
        end
        @cur_dims = 2 + (@cur_has_z ? 1 : 0) + (@cur_has_m ? 1 : 0)
        _start_emitter
        _generate_feature(obj_, true)
        _finish_emitter
      end

      def _generate_feature(obj_, toplevel_ = false) # :nodoc:
        _emit_byte(@little_endian ? 1 : 0)
        type_ = obj_.geometry_type
        type_code_ = TYPE_CODES[type_]
        unless type_code_
          raise Error::ParseError, "Unrecognized Geometry Type: #{type_}"
        end
        emit_srid_ = false
        if @type_format == :ewkb
          type_code_ |= 0x80000000 if @cur_has_z
          type_code_ |= 0x40000000 if @cur_has_m
          if @emit_ewkb_srid && toplevel_
            type_code_ |= 0x20000000
            emit_srid_ = true
          end
        elsif @type_format == :wkb12
          type_code_ += 1000 if @cur_has_z
          type_code_ += 2000 if @cur_has_m
        end
        _emit_integer(type_code_)
        _emit_integer(obj_.srid) if emit_srid_
        if type_ == Feature::Point
          _emit_doubles(_point_coords(obj_))
        elsif type_.subtype_of?(Feature::LineString)
          _emit_line_string_coords(obj_)
        elsif type_ == Feature::Polygon
          exterior_ring_ = obj_.exterior_ring
          if exterior_ring_.is_empty?
            _emit_integer(0)
          else
            _emit_integer(1 + obj_.num_interior_rings)
            _emit_line_string_coords(exterior_ring_)
            obj_.interior_rings.each { |r_| _emit_line_string_coords(r_) }
          end
        elsif type_ == Feature::GeometryCollection
          _emit_integer(obj_.num_geometries)
          obj_.each { |g_| _generate_feature(g_) }
        elsif type_ == Feature::MultiPoint
          _emit_integer(obj_.num_geometries)
          obj_.each { |g_| _generate_feature(g_) }
        elsif type_ == Feature::MultiLineString
          _emit_integer(obj_.num_geometries)
          obj_.each { |g_| _generate_feature(g_) }
        elsif type_ == Feature::MultiPolygon
          _emit_integer(obj_.num_geometries)
          obj_.each { |g_| _generate_feature(g_) }
        end
      end

      def _point_coords(obj_, array_ = []) # :nodoc:
        array_ << obj_.x
        array_ << obj_.y
        array_ << obj_.z if @cur_has_z
        array_ << obj_.m if @cur_has_m
        array_
      end

      def _emit_line_string_coords(obj_) # :nodoc:
        array_ = []
        obj_.points.each { |p_| _point_coords(p_, array_) }
        _emit_integer(obj_.num_points)
        _emit_doubles(array_)
      end

      def _start_emitter # :nodoc:
        @cur_array = []
      end

      def _emit_byte(value_) # :nodoc:
        @cur_array << [value_].pack("C")
      end

      def _emit_integer(value_)  # :nodoc:
        @cur_array << [value_].pack(@little_endian ? "V" : "N")
      end

      def _emit_doubles(array_)  # :nodoc:
        @cur_array << array_.pack(@little_endian ? "E*" : "G*")
      end

      def _finish_emitter # :nodoc:
        str_ = @cur_array.join
        @cur_array = nil
        @hex_format ? str_.unpack("H*")[0] : str_
      end
    end
  end
end
