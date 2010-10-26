# -----------------------------------------------------------------------------
# 
# Common methods for GeometryCollection features
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
  
  module ImplHelpers  # :nodoc:
    
    
    module BasicGeometryCollectionMethods  # :nodoc:
      
      
      def initialize(factory_, elements_)
        _set_factory(factory_)
        @elements = elements_.map do |elem_|
          elem_ = Features.cast(elem_, factory_)
          unless elem_
            raise Errors::InvalidGeometry, "Could not cast #{elem_}"
          end
          elem_
        end
        _validate_geometry
      end
      
      
      def eql?(rhs_)
        if rhs_.is_a?(self.class) && rhs_.factory.eql?(@factory) && @elements.size == rhs_.num_geometries
          rhs_.each_with_index{ |p_, i_| return false unless @elements[i_].eql?(p_) }
        else
          false
        end
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
      
      
    end
    
    
    module BasicMultiLineStringMethods  # :nodoc:
      
      
      def initialize(factory_, elements_)
        _set_factory(factory_)
        @elements = elements_.map do |elem_|
          elem_ = Features.cast(elem_, factory_, Features::LineString, :keep_subtype)
          unless elem_
            raise Errors::InvalidGeometry, "Could not cast #{elem_}"
          end
          elem_
        end
        _validate_geometry
      end
      
      
      def geometry_type
        Features::MultiLineString
      end
      
      
      def is_closed?
        all?{ |elem_| elem_.is_closed? }
      end
      
      
    end
    
    
    module BasicMultiPointMethods  # :nodoc:
      
      
      def initialize(factory_, elements_)
        _set_factory(factory_)
        @elements = elements_.map do |elem_|
          elem_ = Features.cast(elem_, factory_, Features::Point, :keep_subtype)
          unless elem_
            raise Errors::InvalidGeometry, "Could not cast #{elem_}"
          end
          elem_
        end
        _validate_geometry
      end
      
      
      def geometry_type
        Features::MultiPoint
      end
      
      
    end
    
    
    module BasicMultiPolygonMethods  # :nodoc:
      
      
      def initialize(factory_, elements_)
        _set_factory(factory_)
        @elements = elements_.map do |elem_|
          elem_ = Features.cast(elem_, factory_, Features::Polygon, :keep_subtype)
          unless elem_
            raise Errors::InvalidGeometry, "Could not cast #{elem_}"
          end
          elem_
        end
        _validate_geometry
      end
      
      
      def geometry_type
        Features::MultiPolygon
      end
      
      
    end
    
    
  end
  
end
