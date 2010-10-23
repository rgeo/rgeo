# -----------------------------------------------------------------------------
# 
# Common methods for Polygon geography features
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
    
    module Common
      
      
      module PolygonMethods
        
        
        def _setup(exterior_ring_, interior_rings_)
          @exterior_ring = factory.cast(exterior_ring_)
          @interior_rings = (interior_rings_ || []).map{ |elem_| factory.cast(elem_) }
          unless Features::LinearRing.check_type(@exterior_ring)
            raise Errors::InvalidGeometry, 'Exterior ring must be a LinearRing'
          end
          @interior_rings.each do |ring_|
            unless Features::LinearRing.check_type(ring_)
              raise Errors::InvalidGeometry, 'Interior ring must be a LinearRing'
            end
          end
          _validate_geometry
        end
        
        
        def cast(type_)
          case type_
          when Features::Polygon
            self
          when Features::LinearRing
            @exterior_ring
          when Features::LineString
            @exterior_ring.cast(type_)
          when Features::GeometryCollection
            factory.collection([self]) rescue nil
          when Features::MultiPolygon
            factory.multi_polygon([self]) rescue nil
          else
            super
          end
        end
        
        
        def exterior_ring
          @exterior_ring
        end
        
        
        def num_interior_rings
          @interior_rings.size
        end
        
        
        def interior_ring_n(n_)
          @interior_rings[n_]
        end
        
        
        def interior_rings
          @interior_rings.dup
        end
        
        
        def dimension
          2
        end
        
        
        def geometry_type
          Features::Polygon
        end
        
        
        def is_empty?
          @exterior_ring.is_empty?
        end
        
        
      end
      
      
    end
    
  end
  
end
