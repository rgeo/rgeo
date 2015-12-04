# -----------------------------------------------------------------------------
#
# OGC CS wkt parser for RGeo
#
# -----------------------------------------------------------------------------

module RGeo
  module CoordSys
    module CS
      class WKTParser # :nodoc:
        def initialize(str_)
          @scanner = ::StringScanner.new(str_)
          next_token
        end

        def parse(containing_type_ = nil) # :nodoc:
          if @cur_token.is_a?(QuotedString) ||
            @cur_token.is_a?(::Numeric) ||
            (containing_type_ == "AXIS" && @cur_token.is_a?(TypeString))
            value_ = @cur_token
            next_token
            return value_
          end
          unless @cur_token.is_a?(TypeString)
            raise Error::ParseError("Found token #{@cur_token} when we expected a value")
          end
          type_ = @cur_token
          next_token
          consume_token_type(:begin)
          args_ = ArgumentList.new
          args_ << parse(type_)
          loop do
            break unless @cur_token == :comma
            next_token
            args_ << parse(type_)
          end
          consume_token_type(:end)
          obj_ = nil
          case type_
          when "AUTHORITY"
            obj_ = AuthorityClause.new(args_.shift(QuotedString), args_.shift(QuotedString))
          when "EXTENSION"
            obj_ = ExtensionClause.new(args_.shift(QuotedString), args_.shift(QuotedString))
          when "AXIS"
            obj_ = AxisInfo.create(args_.shift(QuotedString), args_.shift(TypeString))
          when "TOWGS84"
            bursa_wolf_params_ = args_.find_all(::Numeric)
            unless bursa_wolf_params_.size == 7
              raise Error::ParseError("Expected 7 Bursa Wolf parameters but found #{bursa_wolf_params_.size}")
            end
            obj_ = WGS84ConversionInfo.create(*bursa_wolf_params_)
          when "UNIT"
            case containing_type_
            when "GEOCCS", "VERT_CS", "PROJCS", "SPHEROID"
              klass_ = LinearUnit
            when "GEOGCS"
              klass_ = AngularUnit
            else
              klass_ = Unit
            end
            obj_ = klass_.create(args_.shift(QuotedString), args_.shift(::Numeric), *args_.create_optionals)
          when "PARAMETER"
            obj_ = ProjectionParameter.create(args_.shift(QuotedString), args_.shift(::Numeric))
          when "PRIMEM"
            obj_ = PrimeMeridian.create(args_.shift(QuotedString), nil, args_.shift(::Numeric), *args_.create_optionals)
          when "SPHEROID"
            obj_ = Ellipsoid.create_flattened_sphere(args_.shift(QuotedString), args_.shift(::Numeric), args_.shift(::Numeric), args_.find_first(LinearUnit), *args_.create_optionals)
          when "PROJECTION"
            name_ = args_.shift(QuotedString)
            obj_ = Projection.create(name_, name_, args_.find_all(ProjectionParameter), *args_.create_optionals)
          when "DATUM"
            name_ = args_.shift(QuotedString)
            ellipsoid_ = args_.find_first(Ellipsoid)
            to_wgs84_ = args_.find_first(WGS84ConversionInfo)
            obj_ = HorizontalDatum.create(name_, HD_GEOCENTRIC, ellipsoid_, to_wgs84_, *args_.create_optionals)
          when "VERT_DATUM"
            obj_ = VerticalDatum.create(args_.shift(QuotedString), args_.shift(::Numeric), *args_.create_optionals)
          when "LOCAL_DATUM"
            obj_ = LocalDatum.create(args_.shift(QuotedString), args_.shift(::Numeric), *args_.create_optionals)
          when "COMPD_CS"
            obj_ = CompoundCoordinateSystem.create(args_.shift(QuotedString), args_.shift(CoordinateSystem), args_.shift(CoordinateSystem), *args_.create_optionals)
          when "LOCAL_CS"
            name_ = args_.shift(QuotedString)
            local_datum_ = args_.find_first(LocalDatum)
            unit_ = args_.find_first(Unit)
            axes_ = args_.find_all(AxisInfo)
            unless axes_.size > 0
              raise Error::ParseError("Expected at least one AXIS in a LOCAL_CS")
            end
            obj_ = LocalCoordinateSystem.create(name_, local_datum_, unit_, axes_, *args_.create_optionals)
          when "GEOCCS"
            name_ = args_.shift(QuotedString)
            horizontal_datum_ = args_.find_first(HorizontalDatum)
            prime_meridian_ = args_.find_first(PrimeMeridian)
            linear_unit_ = args_.find_first(LinearUnit)
            axes_ = args_.find_all(AxisInfo)
            unless axes_.size == 0 || axes_.size == 3
              raise Error::ParseError("GEOCCS must contain either 0 or 3 AXIS parameters")
            end
            obj_ = GeocentricCoordinateSystem.create(name_, horizontal_datum_, prime_meridian_, linear_unit_, axes_[0], axes_[1], axes_[2], *args_.create_optionals)
          when "VERT_CS"
            name_ = args_.shift(QuotedString)
            vertical_datum_ = args_.find_first(VerticalDatum)
            linear_unit_ = args_.find_first(LinearUnit)
            axis_ = args_.find_first(AxisInfo)
            obj_ = VerticalCoordinateSystem.create(name_, vertical_datum_, linear_unit_, axis_, *args_.create_optionals)
          when "GEOGCS"
            name_ = args_.shift(QuotedString)
            horizontal_datum_ = args_.find_first(HorizontalDatum)
            prime_meridian_ = args_.find_first(PrimeMeridian)
            angular_unit_ = args_.find_first(AngularUnit)
            axes_ = args_.find_all(AxisInfo)
            unless axes_.size == 0 || axes_.size == 2
              raise Error::ParseError("GEOGCS must contain either 0 or 2 AXIS parameters")
            end
            obj_ = GeographicCoordinateSystem.create(name_, angular_unit_, horizontal_datum_, prime_meridian_, axes_[0], axes_[1], *args_.create_optionals)
          when "PROJCS"
            name_ = args_.shift(QuotedString)
            geographic_coordinate_system_ = args_.find_first(GeographicCoordinateSystem)
            projection_ = args_.find_first(Projection)
            parameters_ = args_.find_all(ProjectionParameter)
            projection_.instance_variable_get(:@parameters).concat(parameters_)
            linear_unit_ = args_.find_first(LinearUnit)
            axes_ = args_.find_all(AxisInfo)
            unless axes_.size == 0 || axes_.size == 2
              raise Error::ParseError("PROJCS must contain either 0 or 2 AXIS parameters")
            end
            obj_ = ProjectedCoordinateSystem.create(name_, geographic_coordinate_system_, projection_, linear_unit_, axes_[0], axes_[1], *args_.create_optionals)
          else
            raise Error::ParseError, "Unrecognized type: #{type_}"
          end
          args_.assert_empty
          obj_
        end

        def consume_token_type(type_) # :nodoc:
          expect_token_type(type_)
          tok_ = @cur_token
          next_token
          tok_
        end

        def expect_token_type(type_) # :nodoc:
          unless type_ === @cur_token
            raise Error::ParseError, "#{type_.inspect} expected but #{@cur_token.inspect} found."
          end
        end

        def next_token # :nodoc:
          @scanner.skip(/\s+/)
          case @scanner.peek(1)
          when '"'
            @scanner.getch
            @cur_token = QuotedString.new(@scanner.scan(/[^"]*/))
            @scanner.getch
          when ","
            @scanner.getch
            @cur_token = :comma
          when "(", "["
            @scanner.getch
            @cur_token = :begin
          when "]", ")"
            @scanner.getch
            @cur_token = :end
          when /[a-zA-Z]/
            @cur_token = TypeString.new(@scanner.scan(/[a-zA-Z]\w*/))
          when "", nil
            @cur_token = nil
          else
            @scanner.scan_until(/[^\s\(\)\[\],"]+/)
            token_ = @scanner.matched
            if token_ =~ /^[-+]?(\d+(\.\d*)?|\.\d+)(e[-+]?\d+)?$/
              @cur_token = token_.to_f
            else
              raise Error::ParseError, "Bad token: #{token_.inspect}"
            end
          end
          @cur_token
        end

        attr_reader :cur_token

        class QuotedString < ::String # :nodoc:
        end

        class TypeString < ::String # :nodoc:
        end

        class AuthorityClause # :nodoc:
          def initialize(name_, code_) # :nodoc:
            @name = name_
            @code = code_
          end

          def to_a # :nodoc:
            [@name, @code]
          end
        end

        class ExtensionClause # :nodoc:
          def initialize(key_, value_) # :nodoc:
            @key = key_
            @value = value_
          end

          attr_reader :key # :nodoc:
          attr_reader :value # :nodoc:
        end

        class ArgumentList # :nodoc:
          def initialize  # :nodoc:
            @values = []
          end

          def <<(value_)  # :nodoc:
            @values << value_
          end

          def assert_empty # :nodoc:
            if @values.size > 0
              names_ = @values.map do |val_|
                val_.is_a?(Base) ? val_._wkt_typename : val_.inspect
              end
              raise Error::ParseError, "#{@values.size} unexpected arguments: #{names_.join(', ')}"
            end
          end

          def find_first(klass_) # :nodoc:
            @values.each_with_index do |val_, index_|
              if val_.is_a?(klass_)
                @values.slice!(index_)
                return val_
              end
            end
            nil
          end

          def find_all(klass_)  # :nodoc:
            results_ = []
            nvalues_ = []
            @values.each do |val_|
              if val_.is_a?(klass_)
                results_ << val_
              else
                nvalues_ << val_
              end
            end
            @values = nvalues_
            results_
          end

          def create_optionals  # :nodoc:
            hash_ = {}
            find_all(ExtensionClause).each { |ec_| hash_[ec_.key] = ec_.value }
            (find_first(AuthorityClause) || [nil, nil]).to_a + [nil, nil, nil, hash_]
          end

          def shift(klass_ = nil) # :nodoc:
            val_ = @values.shift
            unless val_
              raise Error::ParseError, "No arguments left... expected #{klass_}"
            end
            if klass_ && !val_.is_a?(klass_)
              raise Error::ParseError, "Expected #{klass_} but got #{val_.class}"
            end
            val_
          end
        end
      end
    end
  end
end
