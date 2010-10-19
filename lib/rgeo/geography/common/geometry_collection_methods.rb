# -----------------------------------------------------------------------------
# 
# Common methods for GeometryCollection geography features
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
      
      
      module GeometryCollectionMethods
        
        
        def _setup(elements_)
          @elements = elements_.map{ |elem_| factory.convert(elem_) }
          _validate_geometry
        end
        
        
        def num_geometries
          @elements.size
        end
        
        
        def geometry_n(n_)
          @elements[n_]
        end
        
        
        def each(&block_)
          @elements.each(&block_)
        end
        
        
        def dimension
          unless @dimension
            @dimension = -1
            @elements.each do |elem_|
              dim_ = elem_.dimension
              @dimension = dim_ if @dimension < dim_
            end
          end
          @dimension
        end
        
        
        def geometry_type
          Features::GeometryCollection
        end
        
        
        def is_empty?
          @elements.size == 0
        end
        
        
        def cast(type_)
          if type_ == self.geometry_type
            self
          else
            case type_
            when Features::MultiPoint
              factory.multi_point(@elements) rescue nil
            when Features::MultiLineString
              factory.multi_line_string(@elements) rescue nil
            when Features::MultiPolygon
              factory.multi_polygon(@elements) rescue nil
            when Features::GeometryCollection
              factory.collection(@elements) rescue nil
            else
              @elements.size == 1 ? @elements[0].cast(type_) : nil
            end
          end
        end
        
        
      end
      
      
      module MultiLineStringMethods
        
        
        def _validate_geometry  # :nodoc:
          super
          if any?{ |elem_| !Features::LineString.check_type(elem_) }
            raise Errors::InvalidGeometry, 'Collection element is not a LineString'
          end
        end
        
        
        def geometry_type
          Features::MultiLineString
        end
        
        
        def is_closed?
          all?{ |elem_| elem_.is_closed? }
        end
        
        
        def cast(type_)
          if type_ == Features::LineString && @elements.size == 1
            @elements[0]
          else
            super
          end
        end
        
        
      end
      
      
      module MultiPointMethods
        
        
        def _validate_geometry  # :nodoc:
          super
          if any?{ |elem_| !Features::Point.check_type(elem_) }
            raise Errors::InvalidGeometry, "Collection element is not a Point"
          end
        end
        
        
        def geometry_type
          Features::MultiPoint
        end
        
        
        def cast(type_)
          if type_.name == Features::Point && @elements.size == 1
            @elements[0]
          else
            super
          end
        end
        
        
      end
      
      
      module MultiPolygonMethods
        
        
        def _validate_geometry  # :nodoc:
          super
          if any?{ |elem_| !Features::Polygon.check_type(elem_) }
            raise Errors::InvalidGeometry, 'Collection element is not a Polygon'
          end
        end
        
        
        def geometry_type
          Features::MultiPolygon
        end
        
        
        def cast(type_)
          if type_ == Features::Polygon && @elements.size == 1
            @elements[0]
          else
            super
          end
        end
        
        
      end
      
      
    end
    
  end
  
end
