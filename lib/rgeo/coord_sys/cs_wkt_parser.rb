# -----------------------------------------------------------------------------
# 
# OGC CS wkt parser for RGeo
# 
# -----------------------------------------------------------------------------
# Copyright 2010 Daniel Azuma
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
        
        
        def parse(expect_required_=true, expect_type_=nil, context_data_=nil)
          type_ = cur_token
          if expect_required_
            expect_token_type(TypeString)
            if expect_type_ && !(expect_type_ === type_)
              raise Error::ParseError, "Unexpected type found: #{type_}"
            end
          else
            return nil unless TypeString === type_ && expect_type_ === type_
          end
          next_token
          consume_token_type(:begin)
          name_ = type_ == 'TOWGS84' ? 'TOWGS84' : consume_token_type(QuotedString)
          case type_
          when 'AUTHORITY'
            consume_token_type(:comma)
            code_ = consume_token_type(QuotedString)
            result_ = [name_, code_]
          when 'AXIS'
            consume_token_type(:comma)
            orientation_ = consume_token_type(TypeString)
            result_ = AxisInfo.new(name_, orientation_)
          when 'TOWGS84'
            dx_ = consume_token_type(::Numeric)
            consume_token_type(:comma)
            dy_ = consume_token_type(::Numeric)
            consume_token_type(:comma)
            dz_ = consume_token_type(::Numeric)
            consume_token_type(:comma)
            ex_ = consume_token_type(::Numeric)
            consume_token_type(:comma)
            ey_ = consume_token_type(::Numeric)
            consume_token_type(:comma)
            ez_ = consume_token_type(::Numeric)
            consume_token_type(:comma)
            ppm_ = consume_token_type(::Numeric)
            result_ = WGS84ConversionInfo.new(dx_, dy_, dz_, ex_, ey_, ez_, ppm_)
          when 'UNIT'
            consume_token_type(:comma)
            conversion_factor_ = consume_token_type(::Numeric)
            optional_ = maybe_consume_authority
            result_ = (context_data_ || Unit).new(name_, conversion_factor_, *optional_)
          when 'PARAMETER'
            consume_token_type(:comma)
            val_ = consume_token_type(::Numeric)
            result_ = ProjectionParameter.new(name_, val_)
          when 'PRIMEM'
            consume_token_type(:comma)
            longitude_ = consume_token_type(::Numeric)
            optional_ = maybe_consume_authority
            result_ = PrimeMeridian.new(name_, nil, longitude_, *optional_)
          when 'SPHEROID'
            consume_token_type(:comma)
            semi_major_axis_ = consume_token_type(::Numeric).to_f
            consume_token_type(:comma)
            inverse_flattening_ = consume_token_type(::Numeric).to_f
            optional_ = maybe_consume_authority
            result_ = Ellipsoid.create_flattened_sphere(name_, semi_major_axis_, inverse_flattening_, nil, *optional_)
          when 'PROJECTION'
            extras_ = maybe_consume_authority
            result_ = Projection.new(name_, name_, nil, *extras_)
          when 'DATUM'
            consume_token_type(:comma)
            ellipsoid_ = parse(true, 'SPHEROID')
            to_wgs84_ = nil
            optional_ = []
            if @cur_token == :comma
              next_token
              to_wgs84_ = parse(false, 'TOWGS84')
              if to_wgs84_
                optional_ = maybe_consume_authority
              else
                optional_ = parse(true, 'AUTHORITY')
              end
            end
            result_ = HorizontalDatum.new(name_, HD_GEOCENTRIC, ellipsoid_, to_wgs84_, *optional_)
          when 'VERT_DATUM'
            consume_token_type(:comma)
            datum_type_ = consume_token_type(::Numeric).to_i
            optional_ = maybe_consume_authority
            result_ = VerticalDatum.new(name_, datum_type_, *optional_)
          when 'LOCAL_DATUM'
            consume_token_type(:comma)
            datum_type_ = consume_token_type(::Numeric).to_i
            optional_ = maybe_consume_authority
            result_ = VerticalDatum.new(name_, datum_type_, *optional_)
          when 'COMPD_CS'
            consume_token_type(:comma)
            head_ = parse(true, /CS$/)
            consume_token_type(:comma)
            tail_ = parse(true, /CS$/)
            optional_ = maybe_consume_authority
            result_ = CompoundCoordinateSystem.new(name_, head_, tail_, *optional_)
          when 'LOCAL_CS'
            consume_token_type(:comma)
            local_datum_ = parse(true, 'LOCAL_DATUM')
            consume_token_type(:comma)
            unit_ = parse(true, 'UNIT')
            consume_token_type(:comma)
            axes_ = [parse(true, 'AXIS')]
            optional_ = []
            loop do
              break unless @cur_token == :comma
              next_token
              axis_ = parse(false, 'AXIS')
              if axis_
                axes_ << axis_
              else
                optional_ = parse(true, 'AUTHORITY')
                break
              end
            end
            result_ = LocalCoordinateSystem.new(name_, local_datum_, unit_, axes_, *optional_)
          when 'GEOCCS'
            consume_token_type(:comma)
            horizontal_datum_ = parse(true, 'DATUM')
            consume_token_type(:comma)
            prime_meridian_ = parse(true, 'PRIMEM')
            consume_token_type(:comma)
            linear_unit_ = parse(true, 'UNIT', LinearUnit)
            axis0_ = axis1_ = axis2_ = nil
            optional_ = []
            if @cur_token == :comma
              next_token
              axis0_ = parse(false, 'AXIS')
              if axis0_
                consume_token_type(:comma)
                axis1_ = parse(true, 'AXIS')
                consume_token_type(:comma)
                axis2_ = parse(true, 'AXIS')
                optional_ = maybe_consume_authority
              else
                optional_ = parse(true, 'AUTHORITY')
              end
            end
            result_ = GeocentricCoordinateSystem.new(name_, horizontal_datum_, prime_meridian_, linear_unit_, axis0_, axis1_, axis2_, *optional_)
          when 'VERT_CS'
            consume_token_type(:comma)
            vertical_datum_ = parse(true, 'VERT_DATUM')
            consume_token_type(:comma)
            linear_unit_ = parse(true, 'UNIT', LinearUnit)
            axis_ = nil
            optional_ = []
            if @cur_token == :comma
              next_token
              axis_ = parse(false, 'AXIS')
              if axis_
                optional_ = maybe_consume_authority
              else
                optional_ = parse(true, 'AUTHORITY')
              end
            end
            result_ = VerticalCoordinateSystem.new(name_, vertical_datum_, linear_unit_, axis_, *optional_)
          when 'GEOGCS'
            consume_token_type(:comma)
            horizontal_datum_ = parse(true, 'DATUM')
            consume_token_type(:comma)
            prime_meridian_ = parse(true, 'PRIMEM')
            consume_token_type(:comma)
            angular_unit_ = parse(true, 'UNIT', AngularUnit)
            axis0_ = axis1_ = nil
            optional_ = []
            if @cur_token == :comma
              next_token
              axis0_ = parse(false, 'AXIS')
              if axis0_
                consume_token_type(:comma)
                axis1_ = parse(true, 'AXIS')
                optional_ = maybe_consume_authority
              else
                optional_ = parse(true, 'AUTHORITY')
              end
            end
            result_ = GeographicCoordinateSystem.new(name_, angular_unit_, horizontal_datum_, prime_meridian_, axis0_, axis1_, *optional_)
          when 'PROJCS'
            consume_token_type(:comma)
            geographic_coordinate_system_ = parse(true, 'GEOGCS')
            consume_token_type(:comma)
            projection_ = parse(true, 'PROJECTION')
            loop do
              consume_token_type(:comma)
              parameter_ = parse(false, 'PARAMETER')
              if parameter_
                projection_.instance_variable_get(:@parameters) << parameter_
              else
                break
              end
            end
            linear_unit_ = parse(true, 'UNIT', LinearUnit)
            axis0_ = axis1_ = nil
            optional_ = []
            if @cur_token == :comma
              next_token
              axis0_ = parse(false, 'AXIS')
              if axis0_
                consume_token_type(:comma)
                axis1_ = parse(true, 'AXIS')
                optional_ = maybe_consume_authority
              else
                optional_ = parse(true, 'AUTHORITY')
              end
            end
            result_ = ProjectedCoordinateSystem.new(name_, geographic_coordinate_system_, projection_, linear_unit_, axis0_, axis1_, *optional_)
          else
            raise Error::ParseError, "Unknown type: #{type_.inspect}"
          end
          expect_token_type(:end)
          next_token
          result_
        end
        
        
        def maybe_consume_authority
          if @cur_token == :comma
            next_token
            parse(true, 'AUTHORITY')
          else
            []
          end
        end
        
        def consume_token_type(type_)
          expect_token_type(type_)
          tok_ = @cur_token
          next_token
          tok_
        end
        
        def expect_token_type(type_)
          unless type_ === @cur_token
            raise Error::ParseError, "#{type_.inspect} expected but #{@cur_token.inspect} found."
          end
        end
        
        def next_token
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
        
        def cur_token
          @cur_token
        end
        
        class QuotedString < ::String
        end
        
        class TypeString < ::String
        end
        
      end
      
      
    end
    
    
  end
  
end
