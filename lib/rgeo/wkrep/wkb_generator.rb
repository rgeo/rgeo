# -----------------------------------------------------------------------------
# 
# Well-known binary generator for RGeo
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
  
  module WKRep
    
    
    class WKBGenerator
      
      
      TYPE_CODES = {
        Features::Point => 1,
        Features::LineString => 2,
        Features::LinearRing => 2,
        Features::Line => 2,
        Features::Polygon => 3,
        Features::MultiPoint => 4,
        Features::MultiLineString => 5,
        Features::MultiPolygon => 6,
        Features::GeometryCollection => 7,
      }
      
      
      def initialize(opts_={})
        @type_format = opts_[:type_format]
        @emit_ewkb_srid = opts_[:emit_ewkb_srid] if @type_format == :ewkb
        @hex_format = opts_[:hex_format]
        @little_endian = opts_[:little_endian]
      end
      
      
      def generate(obj_)
        factory_ = obj_.factory
        if @type_format == :ewkb || @type_format == :wkb12
          @cur_has_z = factory_.has_capability?(:z_coordinate)
          @cur_has_m = factory_.has_capability?(:m_coordinate)
        else
          @cur_has_z = nil
          @cur_has_m = nil
        end
        @cur_dims = 2 + (@cur_has_z ? 1 : 0) + (@cur_has_m ? 1 : 0)
        _start_emitter
        _generate_feature(obj_, true)
        _finish_emitter
      end
      
      
      def _generate_feature(obj_, toplevel_=false)  # :nodoc:
        _emit_byte(@little_endian ? 1 : 0)
        type_ = obj_.geometry_type
        type_code_ = TYPE_CODES[type_]
        unless type_code_
          raise Errors::ParseError, "Unrecognized Geometry Type: #{type_}"
        end
        emit_srid_ = false
        if @emit_ewkb_srid && toplevel_
          type_code |= 0x20000000
          emit_srid_ = true
        end
        if @type_format == :ewkb
          type_code_ |= 0x80000000 if @cur_has_z
          type_code_ |= 0x40000000 if @cur_has_m
        elsif @type_format == :wkb12
          type_code_ += 1000 if @cur_has_z
          type_code_ += 2000 if @cur_has_m
        end
        _emit_integer(type_code_)
        _emit_integer(obj_.srid) if emit_srid_
        if type_ == Features::Point
          _emit_doubles(_point_coords(obj_))
        elsif type_.subtype_of?(Features::LineString)
          _emit_line_string_coords(obj_)
        elsif type_ == Features::Polygon
          exterior_ring_ = obj_.exterior_ring
          if exterior_ring_.is_empty?
            _emit_integer(0)
          else
            _emit_integer(1 + obj_.num_interior_rings)
            _emit_line_string_coords(exterior_ring_)
            obj_.interior_rings.each{ |r_| _emit_line_string_coords(r_) }
          end
        elsif type_ == Features::GeometryCollection
          _emit_integer(obj_.num_geometries)
          obj_.each{ |g_| _generate_feature(g_) }
        elsif type_ == Features::MultiPoint
          _emit_integer(obj_.num_geometries)
          obj_.each{ |g_| _generate_feature(g_) }
        elsif type_ == Features::MultiLineString
          _emit_integer(obj_.num_geometries)
          obj_.each{ |g_| _generate_feature(g_) }
        elsif type_ == Features::MultiPolygon
          _emit_integer(obj_.num_geometries)
          obj_.each{ |g_| _generate_feature(g_) }
        end
      end
      
      
      def _point_coords(obj_, array_=[])  # :nodoc:
        array_ << obj_.x
        array_ << obj_.y
        array_ << obj_.z if @cur_has_z
        array_ << obj_.m if @cur_has_m
        array_
      end
      
      
      def _emit_line_string_coords(obj_)  # :nodoc:
        array_ = []
        obj_.points.each{ |p_| _point_coords(p_, array_) }
        _emit_integer(obj_.num_points)
        _emit_doubles(array_)
      end
      
      
      def _start_emitter  # :nodoc:
        @cur_array = []
      end
      
      
      def _emit_byte(value_)  # :nodoc:
        @cur_array << [value_].pack("C")
      end
      
      
      def _emit_integer(value_)  # :nodoc:
        @cur_array << [value_].pack(@little_endian ? 'V' : 'N')
      end
      
      
      def _emit_doubles(array_)  # :nodoc:
        @cur_array << array_.pack(@little_endian ? 'E*' : 'G*')
      end
      
      
      def _finish_emitter  # :nodoc:
        str_ = @cur_array.join
        @cur_array = nil
        str_
      end
      
      
    end
    
    
  end
  
end
