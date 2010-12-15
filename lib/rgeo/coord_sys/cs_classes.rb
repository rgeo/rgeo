# -----------------------------------------------------------------------------
# 
# OGC CS objects for RGeo
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
      
      
      AO_OTHER = 0
      AO_NORTH = 1
      AO_SOUTH = 2
      AO_EAST = 3
      AO_WEST = 4
      AO_UP = 5
      AO_DOWN = 6
      
      HD_MIN = 1000
      HD_OTHER = 1000
      HD_CLASSIC = 1001
      HD_GEOCENTRIC = 1002
      HD_MAX = 1999
      VD_MIN = 2000
      VD_OTHER = 2000
      VD_ORTHOMETRIC = 2001
      VD_ELLIPSOIDAL = 2002
      VD_ALTITUDE_BAROMETRIC = 2003
      VD_NORMAL = 2004
      VD_GEOID_MODE_DERIVED = 2005
      VD_DEPTH = 2006
      VD_MAX = 2999
      LD_MIN = 10000
      LD_MAX = 32767
      
      
      class Base
        
        def initialize(name_)  # :nodoc:
          @name = name_.to_s
        end
        
        attr_reader :name
        
        def inspect
          "#<#{self.class}:0x#{object_id.to_s(16)} #{to_wkt}>"
        end
        
        def eql?(rhs_)
          rhs_.class == self.class && rhs_.to_wkt == self.to_wkt
        end
        alias_method :==, :eql?
        
        def to_s
          to_wkt
        end
        
        def to_wkt(opts_={})
          opts_[:standard_brackets] ? _to_wkt('(', ')') : _to_wkt('[', ']')
        end
        
        def _to_wkt(open_, close_)  # :nodoc:
          content_ = _wkt_content(open_, close_).map{ |obj_| ",#{obj_}" }.join
          if defined?(@authority) && @authority
            authority_ = ",AUTHORITY#{open_}#{@authority.inspect},#{@authority_code.inspect}#{close_}"
          else
            authority_ = ''
          end
          "#{_wkt_typename}#{open_}#{@name.inspect}#{content_}#{authority_}#{close_}"
        end
        
      end
      
      
      class AxisInfo < Base
        
        NAMES_BY_VALUE = ['OTHER', 'NORTH', 'SOUTH', 'EAST', 'WEST', 'UP', 'DOWN']
        
        def initialize(name_, orientation_)
          super(name_)
          if orientation_.kind_of?(::String)
            @orientation = NAMES_BY_VALUE.index(orientation_).to_i
          else
            @orientation = orientation_.to_i
          end
        end
        
        attr_reader :orientation
        
        def _wkt_typename  # :nodoc:
          "AXIS"
        end
        
        def _wkt_content(open_, close_)  # :nodoc:
          [NAMES_BY_VALUE[@orientation]]
        end
        
      end
      
      
      class ProjectionParameter < Base
        
        def initialize(name_, value_)
          super(name_)
          @value = value_.to_f
        end
        
        attr_reader :value
        
        def _wkt_typename  # :nodoc:
          "PARAMETER"
        end
        
        def _wkt_content(open_, close_)  # :nodoc:
          [@value]
        end
        
      end
      
      
      class WGS84ConversionInfo < Base
        
        def initialize(dx_, dy_, dz_, ex_, ey_, ez_, ppm_)
          super('TOWGS84')
          @dx = dx_.to_f
          @dy = dy_.to_f
          @dz = dz_.to_f
          @ex = ex_.to_f
          @ey = ey_.to_f
          @ez = ez_.to_f
          @ppm = ppm_.to_f
        end
        
        attr_reader :dx
        attr_reader :dy
        attr_reader :dz
        attr_reader :ex
        attr_reader :ey
        attr_reader :ez
        attr_reader :ppm
        
        def _to_wkt(open_, close_)  # :nodoc:
          "TOWGS84#{open_}#{@dx},#{@dy},#{@dz},#{@ex},#{@ey},#{@ez},#{@ppm}#{close_}"
        end
        
      end
      
      
      class Info < Base
        
        def initialize(name_, authority_=nil, authority_code_=nil, abbreviation_=nil, alias_=nil, remarks_=nil)  # :nodoc:
          super(name_)
          @authority = authority_ ? authority_.to_s : nil
          @authority_code = authority_code_ ? authority_code_.to_s : nil
          @abbreviation = abbreviation_ ? abbreviation_.to_s : nil
          @alias = alias_ ? alias_.to_s : nil
          @remarks = remarks_ ? remarks_.to_s : nil
        end
        
        attr_reader :authority
        attr_reader :authority_code
        attr_reader :abbreviation
        attr_reader :alias
        attr_reader :remarks
        
      end
      
      
      class Unit < Info
        
        def initialize(name_, conversion_factor_, *optional_)
          super(name_, *optional_)
          @conversion_factor = conversion_factor_.to_f
        end
        
        attr_reader :conversion_factor
        
        def _wkt_typename  # :nodoc:
          "UNIT"
        end
        
        def _wkt_content(open_, close_)  # :nodoc:
          [@conversion_factor]
        end
        
      end
      
      
      class LinearUnit < Unit
        
        alias_method :meters_per_unit, :conversion_factor
        
      end
      
      
      class AngularUnit < Unit
        
        alias_method :radians_per_unit, :conversion_factor
        
      end
      
      
      class PrimeMeridian < Info
        
        def initialize(name_, angular_unit_, longitude_, *optional_)
          super(name_, *optional_)
          @angular_unit = angular_unit_
          @longitude = longitude_.to_f
        end
        
        attr_reader :angular_unit
        attr_reader :longitude
        
        def _wkt_typename  # :nodoc:
          "PRIMEM"
        end
        
        def _wkt_content(open_, close_)  # :nodoc:
          [@longitude]
        end
        
      end
      
      
      class Ellipsoid < Info
        
        def initialize(name_, semi_major_axis_, semi_minor_axis_, inverse_flattening_, ivf_definitive_, linear_unit_, *optional_)
          super(name_, *optional_)
          @semi_major_axis = semi_major_axis_.to_f
          @semi_minor_axis = semi_minor_axis_.to_f
          @inverse_flattening = inverse_flattening_.to_f
          @ivf_definitive = ivf_definitive_ ? true : false
          @linear_unit = linear_unit_
        end
        
        attr_reader :semi_major_axis
        attr_reader :semi_minor_axis
        attr_reader :inverse_flattening
        attr_reader :ivf_definitive
        attr_reader :linear_unit
        
        def _wkt_typename  # :nodoc:
          "SPHEROID"
        end
        
        def _wkt_content(open_, close_)  # :nodoc:
          [@semi_major_axis, @inverse_flattening]
        end
        
        def self.create_ellipsoid(name_, semi_major_axis_, semi_minor_axis_, linear_unit_, *optional_)
          semi_major_axis_ = semi_major_axis_.to_f
          semi_minor_axis_ = semi_minor_axis_.to_f
          inverse_flattening_ = semi_major_axis_ / (semi_major_axis_ - semi_minor_axis_)
          inverse_flattening_ = 0.0 if inverse_flattening_.infinite?
          new(name_, semi_major_axis_, semi_minor_axis_, inverse_flattening_, false, linear_unit_, *optional_)
        end
        
        def self.create_flattened_sphere(name_, semi_major_axis_, inverse_flattening_, linear_unit_, *optional_)
          semi_major_axis_ = semi_major_axis_.to_f
          inverse_flattening_ = inverse_flattening_.to_f
          semi_minor_axis_ = semi_major_axis_ - semi_major_axis_ / inverse_flattening_
          semi_minor_axis_ = semi_major_axis_ if semi_minor_axis_.infinite?
          new(name_, semi_major_axis_, semi_minor_axis_, inverse_flattening_, true, linear_unit_, *optional_)
        end
        
      end
      
      
      class Datum < Info
        
        def initialize(name_, datum_type_, *optional_)  # :nodoc:
          super(name_, *optional_)
          @datum_type = datum_type_.to_i
        end
        
        attr_reader :datum_type
        
        def _wkt_content(open_, close_)  # :nodoc:
          []
        end
        
      end
      
      
      class VerticalDatum < Datum
        
        def _wkt_typename  # :nodoc:
          "VERT_DATUM"
        end
        
        def _wkt_content(open_, close_)  # :nodoc:
          [@datum_type]
        end
        
      end
      
      
      class LocalDatum < Datum
        
        def _wkt_typename  # :nodoc:
          "LOCAL_DATUM"
        end
        
        def _wkt_content(open_, close_)  # :nodoc:
          [@datum_type]
        end
        
      end
      
      
      class HorizontalDatum < Datum
        
        def initialize(name_, datum_type_, ellipsoid_, wgs84_parameters_, *optional_)
          super(name_, datum_type_, *optional_)
          @ellipsoid = ellipsoid_
          @wgs84_parameters = wgs84_parameters_
        end
        
        attr_reader :ellipsoid
        attr_reader :wgs84_parameters
        
        def _wkt_typename  # :nodoc:
          "DATUM"
        end
        
        def _wkt_content(open_, close_)  # :nodoc:
          array_ = [@ellipsoid._to_wkt(open_, close_)]
          array_ << @wgs84_parameters._to_wkt(open_, close_) if @wgs84_parameters
          array_
        end
        
      end
      
      
      class Projection < Info
        
        def initialize(name_, class_name_, parameters_, *optional_)
          super(name_, *optional_)
          @class_name = class_name_.to_s
          @parameters = parameters_ ? parameters_.dup : []
        end
        
        attr_reader :class_name
        
        def num_parameters
          @parameters.size
        end
        
        def get_parameter(index_)
          @parameters[index_]
        end
        
        def each_parameter(&block_)
          @parameters.each(&block_)
        end
        
        def _wkt_typename  # :nodoc:
          "PROJECTION"
        end
        
        def _wkt_content(open_, close_)  # :nodoc:
          []
        end
        
      end
      
      
      class CoordinateSystem < Info
        
        def initialize(name_, dimension_, *optional_)  # :nodoc:
          super(name_, *optional_)
          @dimension = dimension_.to_i
        end
        
        attr_reader :dimension
        
      end
      
      
      class CompoundCoordinateSystem < CoordinateSystem
        
        def initialize(name_, head_, tail_, *optional_)
          super(name_, head_.dimension + tail_.dimension, *optional_)
          @head = head_
          @tail = tail_
        end
        
        attr_reader :head
        attr_reader :tail
        
        def get_axis(index_)
          hd_ = @head.dimension
          index_ < hd_ ? @head.get_axis(index_) : @tail.get_axis(index_ - hd_)
        end
        
        def get_units(index_)
          hd_ = @head.dimension
          index_ < hd_ ? @head.get_units(index_) : @tail.get_units(index_ - hd_)
        end
        
        def _wkt_typename  # :nodoc:
          "COMPD_CS"
        end
        
        def _wkt_content(open_, close_)  # :nodoc:
          [@head._to_wkt(open_, close_), @tail._to_wkt(open_, close_)]
        end
        
      end
      
      
      class LocalCoordinateSystem < CoordinateSystem
        
        def initialize(name_, local_datum_, unit_, axes_, *optional_)
          super(name_, axes_.size, *optional_)
          @local_datum = local_datum_
          @unit = unit_
          @axes = axes_.dup
        end
        
        attr_reader :local_datum
        
        def get_axis(index_)
          @axes[index_]
        end
        
        def get_units(index_)
          @unit
        end
        
        def _wkt_typename  # :nodoc:
          "LOCAL_CS"
        end
        
        def _wkt_content(open_, close_)  # :nodoc:
          [@local_datum._to_wkt(open_, close_), @unit._to_wkt(open_, close_)] + @axes.map{ |ax_| ax_._to_wkt(open_, close_) }
        end
        
      end
      
      
      class GeocentricCoordinateSystem < CoordinateSystem
        
        def initialize(name_, horizontal_datum_, prime_meridian_, linear_unit_, axis0_, axis1_, axis2_, *optional_)
          super(name_, 3, *optional_)
          @horizontal_datum = horizontal_datum_
          @prime_meridian = prime_meridian_
          @linear_unit = linear_unit_
          @axis0 = axis0_
          @axis1 = axis1_
          @axis2 = axis2_
        end
        
        attr_reader :horizontal_datum
        attr_reader :prime_meridian
        attr_reader :linear_unit
        
        def get_units(index_)
          @linear_unit
        end
        
        def get_axis(index_)
          [@axis0, @axis1, @axis2][index_]
        end
        
        def _wkt_typename  # :nodoc:
          "GEOCCS"
        end
        
        def _wkt_content(open_, close_)  # :nodoc:
          arr_ = [@horizontal_datum._to_wkt(open_, close_), @prime_meridian._to_wkt(open_, close_), @linear_unit._to_wkt(open_, close_)]
          arr_ << @axis0._to_wkt(open_, close_) if @axis0
          arr_ << @axis1._to_wkt(open_, close_) if @axis1
          arr_ << @axis2._to_wkt(open_, close_) if @axis2
          arr_
        end
        
      end
      
      
      class VerticalCoordinateSystem < CoordinateSystem
        
        def initialize(name_, vertical_datum_, vertical_unit_, axis_, *optional_)
          super(name_, 1, *optional_)
          @vertical_datum = vertical_datum_
          @vertical_unit = vertical_unit_
          @axis = axis_
        end
        
        attr_reader :vertical_datum
        attr_reader :vertical_unit
        
        def get_units(index_)
          @vertical_unit
        end
        
        def get_axis(index_)
          @axis
        end
        
        def _wkt_typename  # :nodoc:
          "VERT_CS"
        end
        
        def _wkt_content(open_, close_)  # :nodoc:
          arr_ = [@vertical_datum._to_wkt(open_, close_), @vertical_unit._to_wkt(open_, close_)]
          arr_ << @axis._to_wkt(open_, close_) if @axis
          arr_
        end
        
      end
      
      
      class HorizontalCoordinateSystem < CoordinateSystem  # :nodoc:
        
        def initialize(name_, horizontal_datum_, *optional_)
          super(name_, 2, *optional_)
          @horizontal_datum = horizontal_datum_
        end
        
        attr_reader :horizontal_datum
        
      end
      
      
      class GeographicCoordinateSystem < HorizontalCoordinateSystem
        
        def initialize(name_, angular_unit_, horizontal_datum_, prime_meridian_, axis0_, axis1_, *optional_)
          super(name_, horizontal_datum_, *optional_)
          @prime_meridian = prime_meridian_
          @angular_unit = angular_unit_
          @axis0 = axis0_
          @axis1 = axis1_
        end
        
        attr_reader :prime_meridian
        attr_reader :angular_unit
        
        def get_units(index_)
          @angular_unit
        end
        
        def get_axis(index_)
          index_ == 1 ? @axis1 : @axis0
        end
        
        def num_conversion_to_wgs84
          @horizontal_datum.wgs84_parameters ? 1 : 0
        end
        
        def get_wgs84_conversion_info(index_)
          @horizontal_datum.wgs84_parameters
        end
        
        def _wkt_typename  # :nodoc:
          "GEOGCS"
        end
        
        def _wkt_content(open_, close_)  # :nodoc:
          arr_ = [@horizontal_datum._to_wkt(open_, close_), @prime_meridian._to_wkt(open_, close_), @angular_unit._to_wkt(open_, close_)]
          arr_ << @axis0._to_wkt(open_, close_) if @axis0
          arr_ << @axis1._to_wkt(open_, close_) if @axis1
          arr_
        end
        
      end
      
      
      class ProjectedCoordinateSystem < HorizontalCoordinateSystem
        
        def initialize(name_, geographic_coordinate_system_, projection_, linear_unit_, axis0_, axis1_, *optional_)
          super(name_, geographic_coordinate_system_.horizontal_datum, *optional_)
          @geographic_coordinate_system = geographic_coordinate_system_
          @projection = projection_
          @linear_unit = linear_unit_
          @axis0 = axis0_
          @axis1 = axis1_
        end
        
        attr_reader :geographic_coordinate_system
        attr_reader :projection
        attr_reader :linear_unit
        
        def get_units(index_)
          @linear_unit
        end
        
        def get_axis(index_)
          index_ == 1 ? @axis1 : @axis0
        end
        
        def _wkt_typename  # :nodoc:
          "PROJCS"
        end
        
        def _wkt_content(open_, close_)  # :nodoc:
          arr_ = [@geographic_coordinate_system._to_wkt(open_, close_), @projection._to_wkt(open_, close_)]
          @projection.each_parameter{ |param_| arr_ << param_._to_wkt(open_, close_) }
          arr_ << @linear_unit._to_wkt(open_, close_)
          arr_ << @axis0._to_wkt(open_, close_) if @axis0
          arr_ << @axis1._to_wkt(open_, close_) if @axis1
          arr_
        end
        
      end
      
      
    end
    
    
  end
  
end
