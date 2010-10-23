# -----------------------------------------------------------------------------
# 
# Common methods for Point geography features
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
      
      
      module PointMethods
        
        
        def _setup(x_, y_)
          @x = x_.to_f
          @y = y_.to_f
          _validate_geometry
        end
        
        
        def x
          @x
        end
        
        
        def y
          @y
        end
        
        
        def eql?(rhs_)
          rhs_.is_a?(self.class) && rhs_.factory.eql?(@factory) && @x == rhs_.x && @y == rhs_.y
        end
        
        
        def cast(type_)
          case type_
          when Features::Point
            self
          when Features::GeometryCollection
            factory.collection([self]) rescue nil
          when Features::MultiPoint
            factory.multi_point([self]) rescue nil
          else
            super
          end
        end
        
        
        def dimension
          0
        end
        
        
        def geometry_type
          Features::Point
        end
        
        
        def is_empty?
          false
        end
        
        
        def is_simple?
          true
        end
        
        
        def envelope
          self
        end
        
        
        def boundary
          factory.collection([])
        end
        
        
        def convex_hull
          self
        end
        
        
        def equals?(rhs_)
          return false unless rhs_.factory.is_a?(Factory)
          rhs_ = factory.cast(rhs_)
          case rhs_
          when Features::Point
            if @y == 90
              rhs_.y == 90
            elsif @y == -90
              rhs_.y == -90
            else
              rhs_.x == @x && rhs_.y == @y
            end
          when Features::LineString
            rhs_.num_points > 0 && rhs_.points.all?{ |elem_| equals?(elem_) }
          when Features::GeometryCollection
            rhs_.num_geometries > 0 && rhs_.all?{ |elem_| equals?(elem_) }
          else
            false
          end
        end
        
        
        alias_method :longitude, :x
        alias_method :lon, :x
        alias_method :latitude, :y
        alias_method :lat, :y
        
        
      end
      
      
    end
    
  end
  
end
