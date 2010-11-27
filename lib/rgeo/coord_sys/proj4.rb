# -----------------------------------------------------------------------------
# 
# Proj4 wrapper for RGeo
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
    
    
    class Proj4
      
      
      def inspect  # :nodoc:
        "#<#{self.class}:0x#{object_id.to_s(16)} #{_canonical_str.inspect}>"
      end
      
      
      def to_s  # :nodoc:
        _canonical_str
      end
      
      
      def hash  # :nodoc:
        _canonical_str.hash
      end
      
      
      def eql?(rhs_)
        rhs_.is_a?(Proj4) && rhs_._canonical_str == _canonical_str
      end
      
      
      def canonical_str
        _canonical_str
      end
      
      
      def original_str
        _original_str
      end
      
      
      def valid?
        _valid?
      end
      
      
      def geographic?
        _geographic?
      end
      
      
      def get_geographic
        _get_geographic
      end
      
      
      class << self
        
        
        def supported?
          respond_to?(:_create)
        end
        
        
        def create(str_)
          supported? ? _create(str_) : nil
        end
        alias_method :new, :create
        
        
        # Low-level geometry transform method.
        # Transforms the given geometry between the given two projections.
        # The resulting geometry is constructed using the to_factory.
        # Any projections associated with the factories themselves are
        # ignored.
        
        def transform(from_proj_, from_geometry_, to_proj_, to_factory_)
          case from_geometry_
          when Feature::Point
            _transform_point(from_proj_, from_geometry_, to_proj_, to_factory_)
          when Feature::Line
            to_factory_.line(from_geometry_.points.map{ |p_| transform(from_proj_, p_, to_proj_, to_factory_) })
          when Feature::LinearRing
            _transform_linear_ring(from_proj_, from_geometry_, to_proj_, to_factory_)
          when Feature::LineString
            to_factory_.line_string(from_geometry_.points.map{ |p_| transform(from_proj_, p_, to_proj_, to_factory_) })
          when Feature::Polygon
            _transform_polygon(from_proj_, from_geometry_, to_proj_, to_factory_)
          when Feature::MultiPoint
            to_factory_.multi_point(from_geometry_.map{ |p_| _transform_point(from_proj_, p_, to_proj_, to_factory_) })
          when Feature::MultiLineString
            to_factory_.multi_line_string(from_geometry_.map{ |g_| transform(from_proj_, g_, to_proj_, to_factory_) })
          when Feature::MultiPolygon
            to_factory_.multi_polygon(from_geometry_.map{ |p_| _transform_polygon(from_proj_, p_, to_proj_, to_factory_) })
          when Feature::GeometryCollection
            to_factory_.collection(from_geometry_.map{ |g_| transform(from_proj_, g_, to_proj_, to_factory_) })
          end
        end
        
        
        def _transform_point(from_proj_, from_point_, to_proj_, to_factory_)  # :nodoc:
          from_factory_ = from_point_.factory
          from_has_z_ = from_factory_.has_capability?(:z_coordinate)
          from_has_m_ = from_factory_.has_capability?(:m_coordinate)
          to_has_z_ = to_factory_.has_capability?(:z_coordinate)
          to_has_m_ = to_factory_.has_capability?(:m_coordinate)
          coords_ = transform_coords(from_proj_, to_proj_, from_point_.x, from_point_.y,
                                     from_has_z_ ? from_point_.z : nil)
          extras_ = []
          extras_ << coords_[2].to_f if to_has_z_
          extras_ << from_has_m_ ? from_point_.m : 0.0 if to_has_m_?
          to_factory_.point(coords_[0], coords_[1], extras_)
        end
        
        
        def _transform_linear_ring(from_proj_, from_ring_, to_proj_, to_factory_)  # :nodoc:
          to_factory_.linear_ring(from_ring_.points[0..-2].map{ |p_| transform(from_proj_, p_, to_proj_, to_factory_) })
        end
        
        
        def _transform_polygon(from_proj_, from_polygon_, to_proj_, to_factory_)  # :nodoc:
          ext_ = _transform_linear_ring(from_proj_, from_polygon_.exterior_ring, to_proj_, to_factory_)
          int_ = from_polygon_.interior_rings.map{ |r_| _transform_linear_ring(from_proj_, r_, to_proj_, to_factory_) }
          to_factory_.polygon(ext_, int_)
        end
        
        
      end
      
      
    end
    
    
  end
  
end
