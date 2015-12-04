# -----------------------------------------------------------------------------
#
# Well-known text parser for RGeo
#
# -----------------------------------------------------------------------------

require "strscan"

module RGeo
  module WKRep
    # This class provides the functionality of parsing a geometry from
    # WKT (well-known text) format. You may also customize the parser
    # to recognize PostGIS EWKT extensions to the input, or Simple
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
    # [<tt>:support_ewkt</tt>]
    #   Activate support for PostGIS EWKT type tags, which appends an "M"
    #   to tags to indicate the presence of M but not Z, and also
    #   recognizes the SRID prefix. Default is false.
    # [<tt>:support_wkt12</tt>]
    #   Activate support for SFS 1.2 extensions to the type codes, which
    #   use a "M", "Z", or "ZM" token to signal the presence of Z and M
    #   values in the data. SFS 1.2 types such as triangle, tin, and
    #   polyhedralsurface are NOT yet supported. Default is false.
    # [<tt>:strict_wkt11</tt>]
    #   If true, parsing will proceed in SFS 1.1 strict mode, which
    #   disallows any values other than X or Y. This has no effect if
    #   support_ewkt or support_wkt12 are active. Default is false.
    # [<tt>:ignore_extra_tokens</tt>]
    #   If true, extra tokens at the end of the data are ignored. If
    #   false (the default), extra tokens will trigger a parse error.
    # [<tt>:default_srid</tt>]
    #   A SRID to pass to the factory generator if no SRID is present in
    #   the input. Defaults to nil (i.e. don't specify a SRID).

    class WKTParser
      # Create and configure a WKT parser. See the WKTParser
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
        @support_ewkt = opts_[:support_ewkt] ? true : false
        @support_wkt12 = opts_[:support_wkt12] ? true : false
        @strict_wkt11 = @support_ewkt || @support_wkt12 ? false : opts_[:strict_wkt11] ? true : false
        @ignore_extra_tokens = opts_[:ignore_extra_tokens] ? true : false
        @default_srid = opts_[:default_srid]
      end

      # Returns the factory generator. See WKTParser for details.
      attr_reader :factory_generator

      # If this parser was given an exact factory, returns it; otherwise
      # returns nil.
      attr_reader :exact_factory

      # Returns true if this parser supports EWKT.
      # See WKTParser for details.
      def support_ewkt?
        @support_ewkt
      end

      # Returns true if this parser supports SFS 1.2 extensions.
      # See WKTParser for details.
      def support_wkt12?
        @support_wkt12
      end

      # Returns true if this parser strictly adheres to WKT 1.1.
      # See WKTParser for details.
      def strict_wkt11?
        @strict_wkt11
      end

      # Returns true if this parser ignores extra tokens.
      # See WKTParser for details.
      def ignore_extra_tokens?
        @ignore_extra_tokens
      end

      def _properties # :nodoc:
        {
          "support_ewkt" => @support_ewkt,
          "support_wkt12" => @support_wkt12,
          "strict_wkt11" => @strict_wkt11,
          "ignore_extra_tokens" => @ignore_extra_tokens,
          "default_srid" => @default_srid
        }
      end

      # Parse the given string, and return a geometry object.

      def parse(str_)
        str_ = str_.downcase
        @cur_factory = @exact_factory
        if @cur_factory
          @cur_factory_support_z = @cur_factory.property(:has_z_coordinate) ? true : false
          @cur_factory_support_m = @cur_factory.property(:has_m_coordinate) ? true : false
        end
        @cur_expect_z = nil
        @cur_expect_m = nil
        @cur_srid = @default_srid
        if @support_ewkt && str_ =~ /^srid=(\d+);/i
          str_ = $'
          @cur_srid = Regexp.last_match(1).to_i
        end
        begin
          _start_scanner(str_)
          obj_ = _parse_type_tag(false)
          if @cur_token && !@ignore_extra_tokens
            raise Error::ParseError, "Extra tokens beginning with #{@cur_token.inspect}."
          end
        ensure
          _clean_scanner
        end
        obj_
      end

      def _check_factory_support # :nodoc:
        if @cur_expect_z && !@cur_factory_support_z
          raise Error::ParseError, "Geometry calls for Z coordinate but factory doesn't support it."
        end
        if @cur_expect_m && !@cur_factory_support_m
          raise Error::ParseError, "Geometry calls for M coordinate but factory doesn't support it."
        end
      end

      def _ensure_factory # :nodoc:
        unless @cur_factory
          @cur_factory = @factory_generator.call(srid: @cur_srid, has_z_coordinate: @cur_expect_z, has_m_coordinate: @cur_expect_m)
          @cur_factory_support_z = @cur_factory.property(:has_z_coordinate) ? true : false
          @cur_factory_support_m = @cur_factory.property(:has_m_coordinate) ? true : false
          _check_factory_support unless @cur_expect_z.nil?
        end
        @cur_factory
      end

      def _parse_type_tag(_contained_) # :nodoc:
        _expect_token_type(::String)
        if @support_ewkt && @cur_token =~ /^(.+)(m)$/
          type_ = Regexp.last_match(1)
          zm_ = Regexp.last_match(2)
        else
          type_ = @cur_token
          zm_ = ""
        end
        _next_token
        if zm_.length == 0 && @support_wkt12 && @cur_token.is_a?(::String) && @cur_token =~ /^z?m?$/
          zm_ = @cur_token
          _next_token
        end
        if zm_.length > 0 || @strict_wkt11
          creating_expectation_ = @cur_expect_z.nil?
          expect_z_ = zm_[0, 1] == "z" ? true : false
          if @cur_expect_z.nil?
            @cur_expect_z = expect_z_
          elsif expect_z_ != @cur_expect_z
            raise Error::ParseError, "Surrounding collection has Z but contained geometry doesn't."
          end
          expect_m_ = zm_[-1, 1] == "m" ? true : false
          if @cur_expect_m.nil?
            @cur_expect_m = expect_m_
          elsif expect_m_ != @cur_expect_m
            raise Error::ParseError, "Surrounding collection has M but contained geometry doesn't."
          end
          if creating_expectation_
            if @cur_factory
              _check_factory_support
            else
              _ensure_factory
            end
          end
        end
        case type_
        when "point"
          _parse_point(true)
        when "linestring"
          _parse_line_string
        when "polygon"
          _parse_polygon
        when "geometrycollection"
          _parse_geometry_collection
        when "multipoint"
          _parse_multi_point
        when "multilinestring"
          _parse_multi_line_string
        when "multipolygon"
          _parse_multi_polygon
        else
          raise Error::ParseError, "Unknown type tag: #{type_.inspect}."
        end
      end

      def _parse_coords # :nodoc:
        _expect_token_type(::Numeric)
        x_ = @cur_token
        _next_token
        _expect_token_type(::Numeric)
        y_ = @cur_token
        _next_token
        extra_ = []
        if @cur_expect_z.nil?
          while ::Numeric === @cur_token
            extra_ << @cur_token
            _next_token
          end
          num_extras_ = extra_.size
          @cur_expect_z = num_extras_ > 0 && (!@cur_factory || @cur_factory_support_z) ? true : false
          num_extras_ -= 1 if @cur_expect_z
          @cur_expect_m = num_extras_ > 0 && (!@cur_factory || @cur_factory_support_m) ? true : false
          num_extras_ -= 1 if @cur_expect_m
          if num_extras_ > 0
            raise Error::ParseError, "Found #{extra_.size + 2} coordinates, which is too many for this factory."
          end
          _ensure_factory
        else
          val_ = 0
          if @cur_expect_z
            _expect_token_type(::Numeric)
            val_ = @cur_token
            _next_token
          end
          extra_ << val_ if @cur_factory_support_z
          val_ = 0
          if @cur_expect_m
            _expect_token_type(::Numeric)
            val_ = @cur_token
            _next_token
          end
          extra_ << val_ if @cur_factory_support_m
        end
        @cur_factory.point(x_, y_, *extra_)
      end

      def _parse_point(convert_empty_ = false) # :nodoc:
        if convert_empty_ && @cur_token == "empty"
          point_ = _ensure_factory.multi_point([])
        else
          _expect_token_type(:begin)
          _next_token
          point_ = _parse_coords
          _expect_token_type(:end)
        end
        _next_token
        point_
      end

      def _parse_line_string # :nodoc:
        points_ = []
        if @cur_token != "empty"
          _expect_token_type(:begin)
          _next_token
          loop do
            points_ << _parse_coords
            break if @cur_token == :end
            _expect_token_type(:comma)
            _next_token
          end
        end
        _next_token
        _ensure_factory.line_string(points_)
      end

      def _parse_polygon # :nodoc:
        inner_rings_ = []
        if @cur_token == "empty"
          outer_ring_ = _ensure_factory.linear_ring([])
        else
          _expect_token_type(:begin)
          _next_token
          outer_ring_ = _parse_line_string
          loop do
            break if @cur_token == :end
            _expect_token_type(:comma)
            _next_token
            inner_rings_ << _parse_line_string
          end
        end
        _next_token
        _ensure_factory.polygon(outer_ring_, inner_rings_)
      end

      def _parse_geometry_collection # :nodoc:
        geometries_ = []
        if @cur_token != "empty"
          _expect_token_type(:begin)
          _next_token
          loop do
            geometries_ << _parse_type_tag(true)
            break if @cur_token == :end
            _expect_token_type(:comma)
            _next_token
          end
        end
        _next_token
        _ensure_factory.collection(geometries_)
      end

      def _parse_multi_point # :nodoc:
        points_ = []
        if @cur_token != "empty"
          _expect_token_type(:begin)
          _next_token
          loop do
            uses_paren_ = @cur_token == :begin
            _next_token if uses_paren_
            points_ << _parse_coords
            if uses_paren_
              _expect_token_type(:end)
              _next_token
            end
            break if @cur_token == :end
            _expect_token_type(:comma)
            _next_token
          end
        end
        _next_token
        _ensure_factory.multi_point(points_)
      end

      def _parse_multi_line_string # :nodoc:
        line_strings_ = []
        if @cur_token != "empty"
          _expect_token_type(:begin)
          _next_token
          loop do
            line_strings_ << _parse_line_string
            break if @cur_token == :end
            _expect_token_type(:comma)
            _next_token
          end
        end
        _next_token
        _ensure_factory.multi_line_string(line_strings_)
      end

      def _parse_multi_polygon  # :nodoc:
        polygons_ = []
        if @cur_token != "empty"
          _expect_token_type(:begin)
          _next_token
          loop do
            polygons_ << _parse_polygon
            break if @cur_token == :end
            _expect_token_type(:comma)
            _next_token
          end
        end
        _next_token
        _ensure_factory.multi_polygon(polygons_)
      end

      def _start_scanner(str_)  # :nodoc:
        @_scanner = ::StringScanner.new(str_)
        _next_token
      end

      def _clean_scanner # :nodoc:
        @_scanner = nil
        @cur_token = nil
      end

      def _expect_token_type(type_) # :nodoc:
        unless type_ === @cur_token
          raise Error::ParseError, "#{type_.inspect} expected but #{@cur_token.inspect} found."
        end
      end

      def _next_token # :nodoc:
        if @_scanner.scan_until(/\(|\)|\[|\]|,|[^\s\(\)\[\],]+/)
          token_ = @_scanner.matched
          case token_
          when /^[-+]?(\d+(\.\d*)?|\.\d+)(e[-+]?\d+)?$/
            @cur_token = token_.to_f
          when /^[a-z]+$/
            @cur_token = token_
          when ","
            @cur_token = :comma
          when "(", "["
            @cur_token = :begin
          when "]", ")"
            @cur_token = :end
          else
            raise Error::ParseError, "Bad token: #{token_.inspect}"
          end
        else
          @cur_token = nil
        end
        @cur_token
      end
    end
  end
end
