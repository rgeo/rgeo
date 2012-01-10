# -----------------------------------------------------------------------------
#
# OGC CS wkt parser for RGeo
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

  module CoordSys


    module CS


      class WKTParser  # :nodoc:

        def initialize(str_)
          @scanner = ::StringScanner.new(str_)
          next_token
        end


        def parse(containing_type_=nil)
          if @cur_token.kind_of?(QuotedString) ||
              @cur_token.kind_of?(::Numeric) ||
              (containing_type_ == 'AXIS' && @cur_token.kind_of?(TypeString))
            value_ = @cur_token
            next_token
            return value_
          end
          unless @cur_token.kind_of?(TypeString)
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
          when 'AUTHORITY'
            obj_ = AuthorityClause.new(args_.shift(QuotedString), args_.shift(QuotedString))
          when 'AXIS'
            obj_ = AxisInfo.create(args_.shift(QuotedString), args_.shift(TypeString))
          when 'TOWGS84'
            bursa_wolf_params_ = args_.find_all(::Numeric)
            unless bursa_wolf_params_.size == 7
              raise Error::ParseError("Expected 7 Bursa Wolf parameters but found #{bursa_wolf_params_.size}")
            end
            obj_ = WGS84ConversionInfo.create(*bursa_wolf_params_)
          when 'UNIT'
            case containing_type_
            when 'GEOCCS', 'VERT_CS', 'PROJCS', 'SPHEROID'
              klass_ = LinearUnit
            when 'GEOGCS'
              klass_ = AngularUnit
            else
              klass_ = Unit
            end
            obj_ = klass_.create(args_.shift(QuotedString), args_.shift(::Numeric), *args_.find_first(AuthorityClause).to_a)
          when 'PARAMETER'
            obj_ = ProjectionParameter.create(args_.shift(QuotedString), args_.shift(::Numeric))
          when 'PRIMEM'
            obj_ = PrimeMeridian.create(args_.shift(QuotedString), nil, args_.shift(::Numeric), *args_.find_first(AuthorityClause).to_a)
          when 'SPHEROID'
            obj_ = Ellipsoid.create_flattened_sphere(args_.shift(QuotedString), args_.shift(::Numeric), args_.shift(::Numeric), args_.find_first(LinearUnit), *args_.find_first(AuthorityClause).to_a)
          when 'PROJECTION'
            name_ = args_.shift(QuotedString)
            obj_ = Projection.create(name_, name_, args_.find_all(ProjectionParameter), *args_.find_first(AuthorityClause).to_a)
          when 'DATUM'
            name_ = args_.shift(QuotedString)
            ellipsoid_ = args_.find_first(Ellipsoid)
            to_wgs84_ = args_.find_first(WGS84ConversionInfo)
            obj_ = HorizontalDatum.create(name_, HD_GEOCENTRIC, ellipsoid_, to_wgs84_, *args_.find_first(AuthorityClause).to_a)
          when 'VERT_DATUM'
            obj_ = VerticalDatum.create(args_.shift(QuotedString), args_.shift(::Numeric), *args_.find_first(AuthorityClause).to_a)
          when 'LOCAL_DATUM'
            obj_ = LocalDatum.create(args_.shift(QuotedString), args_.shift(::Numeric), *args_.find_first(AuthorityClause).to_a)
          when 'COMPD_CS'
            obj_ = CompoundCoordinateSystem.create(args_.shift(QuotedString), args_.shift(CoordinateSystem), args_.shift(CoordinateSystem), *args_.find_first(AuthorityClause).to_a)
          when 'LOCAL_CS'
            name_ = args_.shift(QuotedString)
            local_datum_ = args_.find_first(LocalDatum)
            unit_ = args_.find_first(Unit)
            axes_ = args_.find_all(AxisInfo)
            unless axes_.size > 0
              raise Error::ParseError("Expected at least one AXIS in a LOCAL_CS")
            end
            obj_ = LocalCoordinateSystem.create(name_, local_datum_, unit_, axes_, *args_.find_first(AuthorityClause).to_a)
          when 'GEOCCS'
            name_ = args_.shift(QuotedString)
            horizontal_datum_ = args_.find_first(HorizontalDatum)
            prime_meridian_ = args_.find_first(PrimeMeridian)
            linear_unit_ = args_.find_first(LinearUnit)
            axes_ = args_.find_all(AxisInfo)
            unless axes_.size == 0 || axes_.size == 3
              raise Error::ParseError("GEOCCS must contain either 0 or 3 AXIS parameters")
            end
            obj_ = GeocentricCoordinateSystem.create(name_, horizontal_datum_, prime_meridian_, linear_unit_, axes_[0], axes_[1], axes_[2], *args_.find_first(AuthorityClause).to_a)
          when 'VERT_CS'
            name_ = args_.shift(QuotedString)
            vertical_datum_ = args_.find_first(VerticalDatum)
            linear_unit_ = args_.find_first(LinearUnit)
            axis_ = args_.find_first(AxisInfo)
            obj_ = VerticalCoordinateSystem.create(name_, vertical_datum_, linear_unit_, axis_, *args_.find_first(AuthorityClause).to_a)
          when 'GEOGCS'
            name_ = args_.shift(QuotedString)
            horizontal_datum_ = args_.find_first(HorizontalDatum)
            prime_meridian_ = args_.find_first(PrimeMeridian)
            angular_unit_ = args_.find_first(AngularUnit)
            axes_ = args_.find_all(AxisInfo)
            unless axes_.size == 0 || axes_.size == 2
              raise Error::ParseError("GEOGCS must contain either 0 or 2 AXIS parameters")
            end
            obj_ = GeographicCoordinateSystem.create(name_, angular_unit_, horizontal_datum_, prime_meridian_, axes_[0], axes_[1], *args_.find_first(AuthorityClause).to_a)
          when 'PROJCS'
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
            obj_ = ProjectedCoordinateSystem.create(name_, geographic_coordinate_system_, projection_, linear_unit_, axes_[0], axes_[1], *args_.find_first(AuthorityClause).to_a)
          else
            raise Error::ParseError, "Unrecognized type: #{type_}"
          end
          args_.assert_empty
          obj_
        end


        def consume_token_type(type_)  # :nodoc:
          expect_token_type(type_)
          tok_ = @cur_token
          next_token
          tok_
        end

        def expect_token_type(type_)  # :nodoc:
          unless type_ === @cur_token
            raise Error::ParseError, "#{type_.inspect} expected but #{@cur_token.inspect} found."
          end
        end

        def next_token  # :nodoc:
          @scanner.skip(/\s+/)
          case @scanner.peek(1)
          when '"'
            @scanner.getch
            @cur_token = QuotedString.new(@scanner.scan(/[^"]*/))
            @scanner.getch
          when ','
            @scanner.getch
            @cur_token = :comma
          when '(','['
            @scanner.getch
            @cur_token = :begin
          when ']',')'
            @scanner.getch
            @cur_token = :end
          when /[a-zA-Z]/
            @cur_token = TypeString.new(@scanner.scan(/[a-zA-Z]\w*/))
          when '', nil
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

        def cur_token  # :nodoc:
          @cur_token
        end


        class QuotedString < ::String  # :nodoc:
        end

        class TypeString < ::String  # :nodoc:
        end


        class AuthorityClause  # :nodoc:

          def initialize(name_, code_)
            @name = name_
            @code = code_
          end

          def to_a
            [@name, @code]
          end

        end


        class ArgumentList  # :nodoc:

          def initialize
            @values = []
          end

          def <<(value_)
            @values << value_
          end

          def assert_empty
            if @values.size > 0
              names_ = @values.map do |val_|
                val_.kind_of?(Base) ? val_._wkt_typename : val_.inspect
              end
              raise Error::ParseError, "#{@remaining} unexpected arguments: #{names_.join(', ')}"
            end
          end

          def find_first(klass_)
            @values.each_with_index do |val_, index_|
              if val_.kind_of?(klass_)
                @values.slice!(index_)
                return val_
              end
            end
            nil
          end

          def find_all(klass_)
            results_ = []
            nvalues_ = []
            @values.each do |val_|
              if val_.kind_of?(klass_)
                results_ << val_
              else
                nvalues_ << val_
              end
            end
            @values = nvalues_
            results_
          end

          def shift(klass_=nil)
            val_ = @values.shift
            unless val_
              raise Error::ParseError, "No arguments left... expected #{klass_}"
            end
            if klass_ && !val_.kind_of?(klass_)
              raise Error::ParseError, "Expected #{klass_} but got #{val_.class}"
            end
            val_
          end

        end


      end


    end


  end

end
