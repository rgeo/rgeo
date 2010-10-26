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
        
        
        include Features::Point
        include ImplHelpers::BasicGeometryMethods
        include SimpleMercator::GeometryMethods
        include ImplHelpers::BasicPointMethods
        
        
        def _validate_geometry
          @y = 85.0511287 if @y > 85.0511287
          @y = -85.0511287 if @y < -85.0511287
          super
        end
        
        
        def _make_projection(projection_factory_)  # :nodoc:
          rpd_ = Helper::RADIANS_PER_DEGREE
          mpr_ = EQUATORIAL_RADIUS
          projection_factory_.point(@x * rpd_ * mpr_,
            ::Math.log(::Math.tan(::Math::PI / 4.0 + @y * rpd_ / 2.0)) * mpr_)
        end
        
        
        def scaling_factor
          1.0 / ::Math.cos(Helper::RADIANS_PER_DEGREE * @y)
        end
        
        
        def canonical_point
          if @x >= -180.0 && @x < 180.0
            self
          else
            x_ = @x % 360.0
            x_ -= 360.0 if x_ >= 180.0
            PointImpl.new(@factory, x_, @y)
          end
        end
        
        
      end
      
      
      class LineStringImpl  # :nodoc:
        
        
        include Features::LineString
        include ImplHelpers::BasicGeometryMethods
        include SimpleMercator::GeometryMethods
        include SimpleMercator::NCurveMethods
        include SimpleMercator::CurveMethods
        include ImplHelpers::BasicLineStringMethods
        include SimpleMercator::LineStringMethods
        
        
        def _make_projection(projection_factory_)  # :nodoc:
          projection_factory_.line_string(@points.map{ |p_| p_.projection })
        end
        
        
      end
      
      
      class LinearRingImpl  # :nodoc:
        
        
        include Features::Line
        include ImplHelpers::BasicGeometryMethods
        include SimpleMercator::GeometryMethods
        include SimpleMercator::NCurveMethods
        include SimpleMercator::CurveMethods
        include ImplHelpers::BasicLineStringMethods
        include SimpleMercator::LineStringMethods
        include ImplHelpers::BasicLinearRingMethods
        
        
        def _make_projection(projection_factory_)  # :nodoc:
          projection_factory_.linear_ring(@points.map{ |p_| p_.projection })
        end
        
        
      end
      
      
      class LineImpl  # :nodoc:
        
        
        include Features::Line
        include ImplHelpers::BasicGeometryMethods
        include SimpleMercator::GeometryMethods
        include SimpleMercator::NCurveMethods
        include SimpleMercator::CurveMethods
        include ImplHelpers::BasicLineStringMethods
        include SimpleMercator::LineStringMethods
        include ImplHelpers::BasicLineMethods
        
        
        def _make_projection(projection_factory_)  # :nodoc:
          projection_factory_.line(start_point.projection, end_point.projection)
        end
        
        
      end
      
      
      class PolygonImpl  # :nodoc:
        
        
        include Features::Polygon
        include ImplHelpers::BasicGeometryMethods
        include SimpleMercator::GeometryMethods
        include SimpleMercator::NSurfaceMethods
        include SimpleMercator::SurfaceMethods
        include ImplHelpers::BasicPolygonMethods
        
        
        def _validate_geometry
          super
          unless projection
            raise Errors::InvalidGeometry, 'Polygon failed assertions'
          end
        end
        
        
        def _make_projection(projection_factory_)  # :nodoc:
          projection_factory_.polygon(@exterior_ring.projection,
                                      @interior_rings.map{ |p_| p_.projection })
        end
        
        
      end
      
      
      class GeometryCollectionImpl  # :nodoc:
        
        
        include Features::GeometryCollection
        include ImplHelpers::BasicGeometryMethods
        include SimpleMercator::GeometryMethods
        include ImplHelpers::BasicGeometryCollectionMethods
        include SimpleMercator::GeometryCollectionMethods
        
        
        def _make_projection(projection_factory_)  # :nodoc:
          projection_factory_.collection(@elements.map{ |p_| p_.projection })
        end
        
        
      end
      
      
      class MultiPointImpl  # :nodoc:
        
        
        include Features::GeometryCollection
        include ImplHelpers::BasicGeometryMethods
        include SimpleMercator::GeometryMethods
        include ImplHelpers::BasicGeometryCollectionMethods
        include SimpleMercator::GeometryCollectionMethods
        include ImplHelpers::BasicMultiPointMethods
        
        
        def _make_projection(projection_factory_)  # :nodoc:
          projection_factory_.multi_point(@elements.map{ |p_| p_.projection })
        end
        
        
      end
      
      
      class MultiLineStringImpl  # :nodoc:
        
        
        include Features::GeometryCollection
        include ImplHelpers::BasicGeometryMethods
        include SimpleMercator::GeometryMethods
        include SimpleMercator::NCurveMethods
        include ImplHelpers::BasicGeometryCollectionMethods
        include SimpleMercator::GeometryCollectionMethods
        include ImplHelpers::BasicMultiLineStringMethods
        
        
        def _make_projection(projection_factory_)  # :nodoc:
          projection_factory_.multi_line_string(@elements.map{ |p_| p_.projection })
        end
        
        
      end
      
      
      class MultiPolygonImpl  # :nodoc:
        
        
        include Features::GeometryCollection
        include ImplHelpers::BasicGeometryMethods
        include SimpleMercator::GeometryMethods
        include SimpleMercator::NSurfaceMethods
        include ImplHelpers::BasicGeometryCollectionMethods
        include SimpleMercator::GeometryCollectionMethods
        include ImplHelpers::BasicMultiPolygonMethods
        
        
        def _validate_geometry
          super
          unless projection
            raise Errors::InvalidGeometry, 'MultiPolygon failed assertions'
          end
        end
        
        
        def _make_projection(projection_factory_)  # :nodoc:
          projection_factory_.multi_polygon(@elements.map{ |p_| p_.projection })
        end
        
        
      end
      
      
    end
    
  end
  
end
