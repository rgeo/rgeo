# -----------------------------------------------------------------------------
#
# Well-known binary parser for RGeo
#
# -----------------------------------------------------------------------------

module RGeo
  module WKRep
    # This class provides the functionality of parsing a geometry from
    # WKB (well-known binary) format. You may also customize the parser
    # to recognize PostGIS EWKB extensions to the input, or Simple
    # Features Specification 1.2 extensions for Z and M coordinates.
    #
    # To use this class, create an instance with the desired settings and
    # customizations, and call the parse method.
    #
    # === Configuration options
    #
    # You must provide each parser with an RGeo::Feature::FactoryGenerator.
    # It should understand the configuration options <tt>:srid</tt>,
    # <tt>:has_z_coordinate</tt>, and <tt>:has_m_coordinate</tt>.
    # You may also pass a specific RGeo::Feature::Factory, or nil to
    # specify the default Cartesian FactoryGenerator.
    #
    # The following additional options are recognized. These can be passed
    # to the constructor, or set on the object afterwards.
    #
    # [<tt>:support_ewkb</tt>]
    #   Activate support for PostGIS EWKB type codes, which use high
    #   order bits in the type code to signal the presence of Z, M, and
    #   SRID values in the data. Default is false.
    # [<tt>:support_wkb12</tt>]
    #   Activate support for SFS 1.2 extensions to the type codes, which
    #   use values greater than 1000 to signal the presence of Z and M
    #   values in the data. SFS 1.2 types such as triangle, tin, and
    #   polyhedralsurface are NOT yet supported. Default is false.
    # [<tt>:ignore_extra_bytes</tt>]
    #   If true, extra bytes at the end of the data are ignored. If
    #   false (the default), extra bytes will trigger a parse error.
    # [<tt>:default_srid</tt>]
    #   A SRID to pass to the factory generator if no SRID is present in
    #   the input. Defaults to nil (i.e. don't specify a SRID).

    class WKBParser
      # Create and configure a WKB parser. See the WKBParser
      # documentation for the options that can be passed.

      def initialize(factory_generator_ = nil, opts_ = {})
        if factory_generator_.is_a?(Feature::Factory::Instance)
          @factory_generator = Feature::FactoryGenerator.single(factory_generator_)
          @exact_factory = factory_generator_
        elsif factory_generator_.respond_to?(:call)
          @factory_generator = factory_generator_
          @exact_factory = nil
        else
          @factory_generator = Cartesian.method(:preferred_factory)
          @exact_factory = nil
        end
        @support_ewkb = opts_[:support_ewkb] ? true : false
        @support_wkb12 = opts_[:support_wkb12] ? true : false
        @ignore_extra_bytes = opts_[:ignore_extra_bytes] ? true : false
        @default_srid = opts_[:default_srid]
      end

      # Returns the factory generator. See WKBParser for details.
      attr_reader :factory_generator

      # If this parser was given an exact factory, returns it; otherwise
      # returns nil.
      attr_reader :exact_factory

      # Returns true if this parser supports EWKB.
      # See WKBParser for details.
      def support_ewkb?
        @support_ewkb
      end

      # Returns true if this parser supports SFS 1.2 extensions.
      # See WKBParser for details.
      def support_wkb12?
        @support_wkb12
      end

      # Returns true if this parser ignores extra bytes.
      # See WKBParser for details.
      def ignore_extra_bytes?
        @ignore_extra_bytes
      end

      def _properties # :nodoc:
        {
          "support_ewkb" => @support_ewkb,
          "support_wkb12" => @support_wkb12,
          "ignore_extra_bytes" => @ignore_extra_bytes,
          "default_srid" => @default_srid
        }
      end

      # Parse the given binary data or hexadecimal string, and return a
      # geometry object.
      #
      # The #parse_hex method is a synonym, present for historical
      # reasons but deprecated. Use #parse instead.

      def parse(data_)
        data_ = [data_].pack("H*") if data_[0, 1] =~ /[0-9a-fA-F]/
        @cur_has_z = nil
        @cur_has_m = nil
        @cur_srid = nil
        @cur_dims = 2
        @cur_factory = nil
        begin
          _start_scanner(data_)
          obj_ = _parse_object(false)
          unless @ignore_extra_bytes
            bytes_ = _bytes_remaining
            if bytes_ > 0
              raise Error::ParseError, "Found #{bytes_} extra bytes at the end of the stream."
            end
          end
        ensure
          _clean_scanner
        end
        obj_
      end
      alias_method :parse_hex, :parse

      def _parse_object(contained_) # :nodoc:
        endian_value_ = _get_byte
        case endian_value_
        when 0
          little_endian_ = false
        when 1
          little_endian_ = true
        else
          raise Error::ParseError, "Bad endian byte value: #{endian_value_}"
        end
        type_code_ = _get_integer(little_endian_)
        has_z_ = false
        has_m_ = false
        srid_ = contained_ ? nil : @default_srid
        if @support_ewkb
          has_z_ ||= type_code_ & 0x80000000 != 0
          has_m_ ||= type_code_ & 0x40000000 != 0
          srid_ = _get_integer(little_endian_) if type_code_ & 0x20000000 != 0
          type_code_ &= 0x0fffffff
        end
        if @support_wkb12
          has_z_ ||= (type_code_ / 1000) & 1 != 0
          has_m_ ||= (type_code_ / 1000) & 2 != 0
          type_code_ %= 1000
        end
        if contained_
          if contained_ != true && contained_ != type_code_
            raise Error::ParseError, "Enclosed type=#{type_code_} is different from container constraint #{contained_}"
          end
          if has_z_ != @cur_has_z
            raise Error::ParseError, "Enclosed hasZ=#{has_z_} is different from toplevel hasZ=#{@cur_has_z}"
          end
          if has_m_ != @cur_has_m
            raise Error::ParseError, "Enclosed hasM=#{has_m_} is different from toplevel hasM=#{@cur_has_m}"
          end
          if srid_ && srid_ != @cur_srid
            raise Error::ParseError, "Enclosed SRID #{srid_} is different from toplevel srid #{@cur_srid || '(unspecified)'}"
          end
        else
          @cur_has_z = has_z_
          @cur_has_m = has_m_
          @cur_dims = 2 + (@cur_has_z ? 1 : 0) + (@cur_has_m ? 1 : 0)
          @cur_srid = srid_
          @cur_factory = @factory_generator.call(srid: @cur_srid, has_z_coordinate: has_z_, has_m_coordinate: has_m_)
          if @cur_has_z && !@cur_factory.property(:has_z_coordinate)
            raise Error::ParseError, "Data has Z coordinates but the factory doesn't have Z coordinates"
          end
          if @cur_has_m && !@cur_factory.property(:has_m_coordinate)
            raise Error::ParseError, "Data has M coordinates but the factory doesn't have M coordinates"
          end
        end
        case type_code_
        when 1
          coords_ = _get_doubles(little_endian_, @cur_dims)
          @cur_factory.point(*coords_)
        when 2
          _parse_line_string(little_endian_)
        when 3
          interior_rings_ = (1.._get_integer(little_endian_)).map { _parse_line_string(little_endian_) }
          exterior_ring_ = interior_rings_.shift || @cur_factory.linear_ring([])
          @cur_factory.polygon(exterior_ring_, interior_rings_)
        when 4
          @cur_factory.multi_point((1.._get_integer(little_endian_)).map { _parse_object(1) })
        when 5
          @cur_factory.multi_line_string((1.._get_integer(little_endian_)).map { _parse_object(2) })
        when 6
          @cur_factory.multi_polygon((1.._get_integer(little_endian_)).map { _parse_object(3) })
        when 7
          @cur_factory.collection((1.._get_integer(little_endian_)).map { _parse_object(true) })
        else
          raise Error::ParseError, "Unknown type value: #{type_code_}."
        end
      end

      def _parse_line_string(little_endian_) # :nodoc:
        count_ = _get_integer(little_endian_)
        coords_ = _get_doubles(little_endian_, @cur_dims * count_)
        @cur_factory.line_string((0...count_).map { |i_| @cur_factory.point(*coords_[@cur_dims * i_, @cur_dims]) })
      end

      def _start_scanner(data_) # :nodoc:
        @_data = data_
        @_len = data_.length
        @_pos = 0
      end

      def _clean_scanner # :nodoc:
        @_data = nil
      end

      def _bytes_remaining # :nodoc:
        @_len - @_pos
      end

      def _get_byte # :nodoc:
        if @_pos + 1 > @_len
          raise Error::ParseError, "Not enough bytes left to fulfill 1 byte"
        end
        str_ = @_data[@_pos, 1]
        @_pos += 1
        str_.unpack("C").first
      end

      def _get_integer(little_endian_) # :nodoc:
        if @_pos + 4 > @_len
          raise Error::ParseError, "Not enough bytes left to fulfill 1 integer"
        end
        str_ = @_data[@_pos, 4]
        @_pos += 4
        str_.unpack("#{little_endian_ ? 'V' : 'N'}").first
      end

      def _get_doubles(little_endian_, count_) # :nodoc:
        len_ = 8 * count_
        if @_pos + len_ > @_len
          raise Error::ParseError, "Not enough bytes left to fulfill #{count_} doubles"
        end
        str_ = @_data[@_pos, len_]
        @_pos += len_
        str_.unpack("#{little_endian_ ? 'E' : 'G'}*")
      end
    end
  end
end
