# -----------------------------------------------------------------------------
# 
# Feature factory interface
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
  
  module Features
    
    
    # This is a standard interface for factories of features.
    # Generally, each Features implementation will implement these
    # methods as a standard way to create features.
    # 
    # If the implementation is unable to create the given feature,
    # it should return nil.
    # 
    # Some implementations may extend this interface to provide facilities
    # for creating additional objects according to the features handled
    # by that implementation. Examples might include higher-dimensional
    # coordinates or additional subclasses not explicitly required by the
    # Simple Features Specification.
    # 
    # A particular factory implementation may not necessarily include
    # this module. Do not depend on kind_of? or === to check for
    # factory-ness. This module is present primarily for documentation.
    
    module Factory
      
      
      # Parse the given string in well-known-text format and return the
      # resulting feature. Returns nil if the string couldn't be parsed.
      
      def parse_wkt(str_)
        nil
      end
      
      
      # Parse the given string in well-known-binary format and return the
      # resulting feature. Returns nil if the string couldn't be parsed.
      
      def parse_wkb(str_)
        nil
      end
      
      
      # Create a feature of type Point.
      # The x and y parameters should be Float values.
      
      def point(x_, y_)
        nil
      end
      
      
      # Create a feature of type LineString.
      # The given points argument should be an Enumerable of Point objects.
      
      def line_string(points_)
        nil
      end
      
      
      # Create a feature of type Line.
      # The given point arguments should be Point objects.
      
      def line(start_, end_)
        nil
      end
      
      
      # Create a feature of type LinearRing.
      # The given points argument should be an Enumerable of Point objects.
      # If the first and last points are not equal, the ring is
      # automatically closed by appending the first point to the end of the
      # string.
      
      def linear_ring(points_)
        nil
      end
      
      
      # Create a feature of type Polygon.
      # The outer_ring should be a LinearRing.
      # The inner_rings should be a possibly empty Enumerable of
      # LinearRing. You may also pass nil to indicate no inner rings.
      
      def polygon(outer_ring_, inner_rings_=nil)
        nil
      end
      
      
      # Create a feature of type GeometryCollection.
      # The elems should be an Enumerable of Geometry objects.
      # This method does not "flatten" collection hierarchies in the way
      # that multi_point, multi_line_string, and multi_polygon do.
      
      def collection(elems_)
        nil
      end
      
      
      # Create a feature of type MultiPoint.
      # The elems should be an Enumerable of Point objects, or collections
      # whose contents, recursively expanded, eventually include only
      # Point objects. The resultant MultiPoint will thus be "flattened"
      # so that its elements include only those leaf Points.
      # Returns nil if any of the leaf geometries is not a Point, which
      # would break the MultiPoint contract.
      
      def multi_point(elems_)
        nil
      end
      
      
      # Create a feature of type MultiLineString.
      # The elems should be an Enumerable of LineString objects, or
      # collections whose contents, recursively expanded, eventually
      # include only LineString objects (or subclasses thereof).
      # The resultant MultiLineString will thus be "flattened" so that its
      # elements include only those leaf LineStrings.
      # Returns nil if any of the leaf geometries is not a LineString,
      # which would break the MultiLineString contract.
      
      def multi_line_string(elems_)
        nil
      end
      
      
      # Create a feature of type MultiPolygon.
      # The elems should be an Enumerable of Polygon objects, or
      # collections whose contents, recursively expanded, eventually
      # include only Polygon objects.
      # The resultant MultiPolygon will thus be "flattened" so that its
      # elements include only those leaf Polygons.
      # Returns nil if any of the leaf geometries is not a Polygon,
      # which would break the MultiPolygon contract.
      # Also returns nil if any of the other assertions for MultiPolygon
      # are not met-- e.g. if any of the polygons overlap.
      
      def multi_polygon(elems_)
        nil
      end
      
      
      # Coerce an existing feature to a feature of the type created by
      # this implementation.
      # If force_new is true, a new object is returned even if the original
      # is already of this implementation.
      
      def coerce(original_, force_new_=false)
        nil
      end
      
      
    end
  
    
  end
  
end
