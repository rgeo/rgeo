# -----------------------------------------------------------------------------
# 
# Well-known text generator for RGeo
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
    
    
    class WKTGenerator
      
      
      def initialize(opts_={})
        @tag_format = opts_[:tag_format]
        @emit_ewkt_srid = opts_[:emit_ewkt_srid] if @tag_format == :ewkt
        @begin_bracket = opts_[:square_brackets] ? '[' : '('
        @end_bracket = opts_[:square_brackets] ? ']' : ')'
        @case = opts_[:case]
      end
      
      
      def generate(obj_)
        factory_ = obj_.factory
        if @tag_format == :wkt11_strict
          @cur_support_z = nil
          @cur_support_m = nil
        else
          @cur_support_z = factory_.has_capability?(:z_coordinate)
          @cur_support_m = factory_.has_capability?(:m_coordinate)
        end
        str_ = _generate_feature(obj_, true)
        if @case == :upper
          str_.upcase
        elsif @case == :lower
          str_.downcase
        else
          str_
        end
      end
      
      
      def _generate_feature(obj_, toplevel_=false)  # :nodoc:
        type_ = obj_.geometry_type
        tag_ = type_.type_name
        if @tag_format == :ewkt
          if @cur_support_m && !@cur_support_z
            tag_ << 'M'
          end
        elsif @tag_format == :wkt12
          if @cur_support_z
            if @cur_support_m
              tag_ << ' ZM'
            else
              tag_ << ' Z'
            end
          elsif @cur_support_m
            tag_ << ' M'
          end
        end
        if toplevel_ && @emit_ewkt_srid
          tag_ = "SRID=#{obj_.srid};#{tag_}"
        end
        if type_ == Features::Point
          tag_ + _generate_point(obj_)
        elsif type_.subtype_of?(Features::LineString)
          tag_ + _generate_line_string(obj_)
        elsif type_ == Features::Polygon
          tag_ + _generate_polygon(obj_)
        elsif type_ == Features::GeometryCollection
          tag_ + _generate_geometry_collection(obj_)
        elsif type_ == Features::MultiPoint
          tag_ + _generate_multi_point(obj_)
        elsif type_ == Features::MultiLineString
          tag_ + _generate_multi_line_string(obj_)
        elsif type_ == Features::MultiPolygon
          tag_ + _generate_multi_polygon(obj_)
        else
          raise Errors::ParseError, "Unrecognized geometry type: #{type_}"
        end
      end
      
      
      def _generate_coords(obj_)  # :nodoc:
        str_ = "#{obj_.x.to_s} #{obj_.y.to_s}"
        str_ << " #{obj_.z.to_s}" if @cur_support_z
        str_ << " #{obj_.m.to_s}" if @cur_support_m
        str_
      end
      
      
      def _generate_point(obj_)  # :nodoc:
        "#{@begin_bracket}#{_generate_coords(obj_)}#{@end_bracket}"
      end
      
      
      def _generate_line_string(obj_)  # :nodoc:
        if obj_.is_empty?
          " EMPTY"
        else
          "#{@begin_bracket}#{obj_.points.map{ |p_| _generate_coords(p_) }.join(',')}#{@end_bracket}"
        end
      end
      
      
      def _generate_polygon(obj_)  # :nodoc:
        if obj_.is_empty?
          " EMPTY"
        else
          "#{@begin_bracket}#{([_generate_line_string(obj_.exterior_ring)] + obj_.interior_rings.map{ |r_| _generate_line_string(r_) }).join(',')}#{@end_bracket}"
        end
      end
      
      
      def _generate_geometry_collection(obj_)  # :nodoc:
        if obj_.is_empty?
          " EMPTY"
        else
          "#{@begin_bracket}#{obj_.map{ |f_| _generate_feature(f_) }.join(',')}#{@end_bracket}"
        end
      end
      
      
      def _generate_multi_point(obj_)  # :nodoc:
        if obj_.is_empty?
          " EMPTY"
        else
          "#{@begin_bracket}#{obj_.map{ |f_| _generate_point(f_) }.join(',')}#{@end_bracket}"
        end
      end
      
      
      def _generate_multi_line_string(obj_)  # :nodoc:
        if obj_.is_empty?
          " EMPTY"
        else
          "#{@begin_bracket}#{obj_.map{ |f_| _generate_line_string(f_) }.join(',')}#{@end_bracket}"
        end
      end
      
      
      def _generate_multi_polygon(obj_)  # :nodoc:
        if obj_.is_empty?
          " EMPTY"
        else
          "#{@begin_bracket}#{obj_.map{ |f_| _generate_polygon(f_) }.join(',')}#{@end_bracket}"
        end
      end
      
      
    end
    
    
  end
  
end
