# -----------------------------------------------------------------------------
# 
# Common methods for LineString geography features
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
      
      
      module LineStringMethods
        
        
        def _setup(points_)
          @points = points_.map{ |elem_| factory.coerce(elem_) }
          _validate_geometry
        end
        
        
        def _validate_geometry
          if @points.size == 1
            raise Errors::InvalidGeometry, 'LineString cannot have 1 point'
          end
        end
        
        
        def cast(type_)
          if type_ == self.geometry_type
            self
          else
            case type_
            when Features::Line
              if @points.size == 0 || @points.size == 2
                factory.line(@points.first, @points.last) rescue nil
              else
                nil
              end
            when Features::LinearRing
              factory.linear_ring(@points) rescue nil
            when Features::LineString
              factory.line_string(@points) rescue nil
            when Features::GeometryCollection
              factory.collection([self]) rescue nil
            when Features::MultiLineString
              factory.multi_line_string([self]) rescue nil
            when Features::Polygon
              ring_ = factory.linear_ring(@points) rescue nil
              ring_ ? factory.polygon(ring_, nil) : nil rescue nil
            else
              super
            end
          end
        end
        
        
        def num_points
          @points.size
        end
        
        
        def point_n(n_)
          @points[n_]
        end
        
        
        def points
          @points.dup
        end
        
        
        def dimension
          1
        end
        
        
        def geometry_type
          Features::LineString
        end
        
        
        def is_empty?
          @points.size == 0
        end
        
        
        def start_point
          @points.first
        end
        
        
        def end_point
          @points.last
        end
        
        
        def is_closed?
          if @is_closed.nil?
            @is_closed = @points.size > 2 && @points.first == @points.last
          end
          @is_closed
        end
        
        
        def is_ring?
          is_closed? && is_simple?
        end
        
        
      end
      
      
      module LineMethods
        
        
        def _validate_geometry  # :nodoc:
          super
          if @points.size > 2
            raise Errors::InvalidGeometry, 'Line must have 0 or 2 points'
          end
        end
        
        
        def geometry_type
          Features::Line
        end
        
        
      end
      
      
      module LinearRingMethods
        
        
        def _validate_geometry  # :nodoc:
          super
          if @points.size > 0 && !is_ring?
            raise Errors::InvalidGeometry, 'LinearRing failed ring test'
          end
        end
        
        
        def geometry_type
          Features::LinearRing
        end
        
        
      end
      
      
    end
    
  end
  
end
