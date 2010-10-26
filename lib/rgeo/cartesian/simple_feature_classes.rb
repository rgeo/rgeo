# -----------------------------------------------------------------------------
# 
# Spherical geography feature classes
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
  
  module Cartesian
    
    
    class SimplePointImpl
      
      
      include Features::Point
      include ImplHelpers::BasicGeometryMethods
      include Cartesian::SimpleGeometryMethods
      include ImplHelpers::BasicPointMethods
      
      
      def _validate_geometry
        @x = @x % 360.0
        @x -= 360.0 if @x >= 180.0
        @y = 90.0 if @y > 90.0
        @y = -90.0 if @y < -90.0
        super
      end
      
      
      def _xyz
        @xyz ||= PointXYZ.from_latlon(@y, @x)
      end
      
      
      def distance(rhs_)
        rhs_ = Features.cast(rhs_, @factory)
        case rhs_
        when SimplePointImpl
          dx_ = @x - rhs_.x
          dy_ = @y - rhs_.y
          ::Math.sqrt(dx_ * dx_ + dy_ * dy_)
        else
          super
        end
      end
      
      
    end
    
    
    class SimpleLineStringImpl
      
      
      include Features::LineString
      include ImplHelpers::BasicGeometryMethods
      include Cartesian::SimpleGeometryMethods
      include ImplHelpers::BasicLineStringMethods
      include Cartesian::SimpleLineStringMethods
      
      
    end
    
    
    class SimpleLineImpl
      
      
      include Features::Line
      include ImplHelpers::BasicGeometryMethods
      include Cartesian::SimpleGeometryMethods
      include ImplHelpers::BasicLineStringMethods
      include Cartesian::SimpleLineStringMethods
      include ImplHelpers::BasicLineMethods
      
      
    end
    
    
    class SimpleLinearRingImpl
      
      
      include Features::Line
      include ImplHelpers::BasicGeometryMethods
      include Cartesian::SimpleGeometryMethods
      include ImplHelpers::BasicLineStringMethods
      include Cartesian::SimpleLineStringMethods
      include ImplHelpers::BasicLinearRingMethods
      
      
    end
    
    
    class SimplePolygonImpl
      
      
      include Features::Polygon
      include ImplHelpers::BasicGeometryMethods
      include Cartesian::SimpleGeometryMethods
      include ImplHelpers::BasicPolygonMethods
      
      
    end
    
    
    class SimpleGeometryCollectionImpl
      
      
      include Features::GeometryCollection
      include ImplHelpers::BasicGeometryMethods
      include Cartesian::SimpleGeometryMethods
      include ImplHelpers::BasicGeometryCollectionMethods
      
      
    end
    
    
    class SimpleMultiPointImpl
      
      
      include Features::GeometryCollection
      include ImplHelpers::BasicGeometryMethods
      include Cartesian::SimpleGeometryMethods
      include ImplHelpers::BasicGeometryCollectionMethods
      include ImplHelpers::BasicMultiPointMethods
      
      
    end
    
    
    class SimpleMultiLineStringImpl
      
      
      include Features::GeometryCollection
      include ImplHelpers::BasicGeometryMethods
      include Cartesian::SimpleGeometryMethods
      include ImplHelpers::BasicGeometryCollectionMethods
      include ImplHelpers::BasicMultiLineStringMethods
      
      
    end
    
    
    class SimpleMultiPolygonImpl
      
      
      include Features::GeometryCollection
      include ImplHelpers::BasicGeometryMethods
      include Cartesian::SimpleGeometryMethods
      include ImplHelpers::BasicGeometryCollectionMethods
      include ImplHelpers::BasicMultiPolygonMethods
      
      
    end
    
    
  end
  
end
