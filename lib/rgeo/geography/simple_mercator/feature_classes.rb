# -----------------------------------------------------------------------------
# 
# Mercator geography feature classes
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
  
  module Geography
    
    module SimpleMercator  # :nodoc:
      
      
      class PointImpl  # :nodoc:
        
        
        include ::RGeo::Feature::Point
        include ::RGeo::ImplHelper::BasicGeometryMethods
        include ::RGeo::ImplHelper::BasicPointMethods
        include ::RGeo::Geography::SimpleMercator::GeometryMethods
        
        
        def _validate_geometry
          @y = 85.0511287 if @y > 85.0511287
          @y = -85.0511287 if @y < -85.0511287
          super
        end
        
        
        def _make_projection(projection_factory_)  # :nodoc:
          rpd_ = ::RGeo::ImplHelper::Math::RADIANS_PER_DEGREE
          mpr_ = EQUATORIAL_RADIUS
          projection_factory_.point(@x * rpd_ * mpr_,
            ::Math.log(::Math.tan(::Math::PI / 4.0 + @y * rpd_ / 2.0)) * mpr_)
        end
        
        
        def scaling_factor
          1.0 / ::Math.cos(::RGeo::ImplHelper::Math::RADIANS_PER_DEGREE * @y)
        end
        
        
        def canonical_x
          x_ = @x % 360.0
          x_ -= 360.0 if x_ >= 180.0
          x_
        end
        alias_method :canonical_longitude, :canonical_x
        alias_method :canonical_lon, :canonical_x
        
        
        def canonical_point
          if @x >= -180.0 && @x < 180.0
            self
          else
            PointImpl.new(@factory, canonical_x, @y)
          end
        end
        
        
        alias_method :longitude, :x
        alias_method :lon, :x
        alias_method :latitude, :y
        alias_method :lat, :y
        
        
      end
      
      
      class LineStringImpl  # :nodoc:
        
        
        include ::RGeo::Feature::LineString
        include ::RGeo::ImplHelper::BasicGeometryMethods
        include ::RGeo::ImplHelper::BasicLineStringMethods
        include ::RGeo::Geography::SimpleMercator::GeometryMethods
        include ::RGeo::Geography::SimpleMercator::NCurveMethods
        include ::RGeo::Geography::SimpleMercator::CurveMethods
        include ::RGeo::Geography::SimpleMercator::LineStringMethods
        
        
        def _make_projection(projection_factory_)  # :nodoc:
          projection_factory_.line_string(@points.map{ |p_| p_.projection })
        end
        
        
      end
      
      
      class LinearRingImpl  # :nodoc:
        
        
        include ::RGeo::Feature::Line
        include ::RGeo::ImplHelper::BasicGeometryMethods
        include ::RGeo::ImplHelper::BasicLineStringMethods
        include ::RGeo::ImplHelper::BasicLinearRingMethods
        include ::RGeo::Geography::SimpleMercator::GeometryMethods
        include ::RGeo::Geography::SimpleMercator::NCurveMethods
        include ::RGeo::Geography::SimpleMercator::CurveMethods
        include ::RGeo::Geography::SimpleMercator::LineStringMethods
        
        
        def _make_projection(projection_factory_)  # :nodoc:
          projection_factory_.linear_ring(@points.map{ |p_| p_.projection })
        end
        
        
      end
      
      
      class LineImpl  # :nodoc:
        
        
        include ::RGeo::Feature::Line
        include ::RGeo::ImplHelper::BasicGeometryMethods
        include ::RGeo::ImplHelper::BasicLineStringMethods
        include ::RGeo::ImplHelper::BasicLineMethods
        include ::RGeo::Geography::SimpleMercator::GeometryMethods
        include ::RGeo::Geography::SimpleMercator::NCurveMethods
        include ::RGeo::Geography::SimpleMercator::CurveMethods
        include ::RGeo::Geography::SimpleMercator::LineStringMethods
        
        
        def _make_projection(projection_factory_)  # :nodoc:
          projection_factory_.line(start_point.projection, end_point.projection)
        end
        
        
      end
      
      
      class PolygonImpl  # :nodoc:
        
        
        include ::RGeo::Feature::Polygon
        include ::RGeo::ImplHelper::BasicGeometryMethods
        include ::RGeo::ImplHelper::BasicPolygonMethods
        include ::RGeo::Geography::SimpleMercator::GeometryMethods
        include ::RGeo::Geography::SimpleMercator::NSurfaceMethods
        include ::RGeo::Geography::SimpleMercator::SurfaceMethods
        
        
        def _validate_geometry
          super
          unless projection
            raise ::RGeo::Error::InvalidGeometry, 'Polygon failed assertions'
          end
        end
        
        
        def _make_projection(projection_factory_)  # :nodoc:
          projection_factory_.polygon(@exterior_ring.projection,
                                      @interior_rings.map{ |p_| p_.projection })
        end
        
        
      end
      
      
      class GeometryCollectionImpl  # :nodoc:
        
        
        include ::RGeo::Feature::GeometryCollection
        include ::RGeo::ImplHelper::BasicGeometryMethods
        include ::RGeo::ImplHelper::BasicGeometryCollectionMethods
        include ::RGeo::Geography::SimpleMercator::GeometryMethods
        include ::RGeo::Geography::SimpleMercator::GeometryCollectionMethods
        
        
        def _make_projection(projection_factory_)  # :nodoc:
          projection_factory_.collection(@elements.map{ |p_| p_.projection })
        end
        
        
      end
      
      
      class MultiPointImpl  # :nodoc:
        
        
        include ::RGeo::Feature::GeometryCollection
        include ::RGeo::ImplHelper::BasicGeometryMethods
        include ::RGeo::ImplHelper::BasicGeometryCollectionMethods
        include ::RGeo::ImplHelper::BasicMultiPointMethods
        include ::RGeo::Geography::SimpleMercator::GeometryMethods
        include ::RGeo::Geography::SimpleMercator::GeometryCollectionMethods
        
        
        def _make_projection(projection_factory_)  # :nodoc:
          projection_factory_.multi_point(@elements.map{ |p_| p_.projection })
        end
        
        
      end
      
      
      class MultiLineStringImpl  # :nodoc:
        
        
        include ::RGeo::Feature::GeometryCollection
        include ::RGeo::ImplHelper::BasicGeometryMethods
        include ::RGeo::ImplHelper::BasicGeometryCollectionMethods
        include ::RGeo::ImplHelper::BasicMultiLineStringMethods
        include ::RGeo::Geography::SimpleMercator::GeometryMethods
        include ::RGeo::Geography::SimpleMercator::NCurveMethods
        include ::RGeo::Geography::SimpleMercator::GeometryCollectionMethods
        
        
        def _make_projection(projection_factory_)  # :nodoc:
          projection_factory_.multi_line_string(@elements.map{ |p_| p_.projection })
        end
        
        
      end
      
      
      class MultiPolygonImpl  # :nodoc:
        
        
        include ::RGeo::Feature::GeometryCollection
        include ::RGeo::ImplHelper::BasicGeometryMethods
        include ::RGeo::ImplHelper::BasicGeometryCollectionMethods
        include ::RGeo::ImplHelper::BasicMultiPolygonMethods
        include ::RGeo::Geography::SimpleMercator::GeometryMethods
        include ::RGeo::Geography::SimpleMercator::NSurfaceMethods
        include ::RGeo::Geography::SimpleMercator::GeometryCollectionMethods
        
        
        def _validate_geometry
          super
          unless projection
            raise ::RGeo::Error::InvalidGeometry, 'MultiPolygon failed assertions'
          end
        end
        
        
        def _make_projection(projection_factory_)  # :nodoc:
          projection_factory_.multi_polygon(@elements.map{ |p_| p_.projection })
        end
        
        
      end
      
      
    end
    
  end
  
end
