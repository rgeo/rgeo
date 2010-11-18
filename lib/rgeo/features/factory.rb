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
    # it should generally return nil. Implementations may also choose to
    # raise an exception on failure.
    # 
    # Some implementations may extend this interface to provide facilities
    # for creating additional objects according to the capabilities
    # provided by that implementation. Examples might include
    # higher-dimensional coordinates or additional subclasses not
    # explicitly required by the Simple Features Specification.
    # 
    # Factory is defined as a module and is provided primarily for the
    # sake of documentation. Implementations need not necessarily include
    # this module itself. Therefore, you should not depend on the
    # kind_of? method to check type. However, to support testing for
    # factory-ness, the Factory::Instance submodule is provided. All
    # factory implementation classes MUST include Factory::Instance, and
    # you may use it in kind_of?, ===, and case-when constructs.
    
    module Factory
      
      
      # All factory implementations MUST include this submodule.
      # This serves as a marker that may be used to test an object for
      # factory-ness.
      
      module Instance
      end
      
      
      # Determine support for the given capability, identified by a
      # symbolic name. This method may be used to test this factory, and
      # any features created by it, to determine whether they support
      # certain capabilities or operations. Most queries return a boolean
      # value, though some may return other values to indicate different
      # levels of support. Generally speaking, if a query returns a false
      # or nil value, support for that capability is not guaranteed, and
      # calls related to that function may fail or raise exceptions.
      # 
      # Each capability must have a symbolic name. Names that have no
      # periods are considered well-known names and are reserved for use
      # by RGeo. If you want to define your own capabilities, use a name
      # that is namespaced, such as <tt>:'mycompany.mycapability'</tt>.
      # 
      # Currently defined standard capabilities are:
      # 
      # <tt>:z_coordinate</tt>::
      #   Supports a "z" coordinate. When an implementation supports
      #   z_coordinate, the Factory#epoint and Point#z methods are
      #   available.
      # <tt>:m_coordinate</tt>::
      #   Supports a "m" coordinate. When an implementation supports
      #   m_coordinate, the Factory#epoint and Point#m methods are
      #   available.
      
      def has_capability?(name_)
        nil
      end
      
      
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
      # 
      # The extra parameters should be the Z and/or M coordinates, if the
      # capabilities are supported. If both Z and M capabilities are
      # supported, Z should be passed first.
      
      def point(x_, y_, *extra_)
        nil
      end
      
      
      # Create a feature of type LineString.
      # The given points argument should be an Enumerable of Point
      # objects, or objects that can be casted to Point.
      
      def line_string(points_)
        nil
      end
      
      
      # Create a feature of type Line.
      # The given point arguments should be Point objects, or objects
      # that can be casted to Point.
      
      def line(start_, end_)
        nil
      end
      
      
      # Create a feature of type LinearRing.
      # The given points argument should be an Enumerable of Point
      # objects, or objects that can be casted to Point.
      # If the first and last points are not equal, the ring is
      # automatically closed by appending the first point to the end of the
      # string.
      
      def linear_ring(points_)
        nil
      end
      
      
      # Create a feature of type Polygon.
      # The outer_ring should be a LinearRing, or an object that can be
      # casted to LinearRing.
      # The inner_rings should be a possibly empty Enumerable of
      # LinearRing (or objects that can be casted to LinearRing).
      # You may also pass nil to indicate no inner rings.
      
      def polygon(outer_ring_, inner_rings_=nil)
        nil
      end
      
      
      # Create a feature of type GeometryCollection.
      # The elems should be an Enumerable of Geometry objects.
      
      def collection(elems_)
        nil
      end
      
      
      # Create a feature of type MultiPoint.
      # The elems should be an Enumerable of Point objects, or objects
      # that can be casted to Point.
      # Returns nil if any of the contained geometries is not a Point,
      # which would break the MultiPoint contract.
      
      def multi_point(elems_)
        nil
      end
      
      
      # Create a feature of type MultiLineString.
      # The elems should be an Enumerable of objects that are or can be
      # casted to LineString or any of its subclasses.
      # Returns nil if any of the contained geometries is not a
      # LineString, which would break the MultiLineString contract.
      
      def multi_line_string(elems_)
        nil
      end
      
      
      # Create a feature of type MultiPolygon.
      # The elems should be an Enumerable of objects that are or can be
      # casted to Polygon or any of its subclasses.
      # Returns nil if any of the contained geometries is not a Polygon,
      # which would break the MultiPolygon contract.
      # Also returns nil if any of the other assertions for MultiPolygon
      # are not met-- e.g. if any of the polygons overlap.
      
      def multi_polygon(elems_)
        nil
      end
      
      
      # This is an optional method that may be implemented to customize
      # casting for this factory. Basically, RGeo defines standard ways
      # to cast certain types of objects from one factory to another and
      # one SFS type to another. However, a factory may choose to
      # override how things are casted TO its implementation using this
      # method. It can do this to optimize certain casting cases, or
      # implement special cases particular to this factory.
      # 
      # This method will be called (if defined) on the destination
      # factory, and will be passed the original object (which may or may
      # not already be created by this factory), the SFS feature type
      # (which again may or may not already be the type of the original
      # object), a flag indicating whether to keep the subtype if casting
      # to a supertype of the current type, and a flag indicating whether
      # to force the creation of a new object even if the original is
      # already of the desired factory and type.
      # 
      # It should return either a casted result object, false, or nil.
      # A nil return value indicates that casting should be forced to
      # fail (and ::RGeo::Features::cast will return nil).
      # A false return value indicates that this method declines to
      # override the casting algorithm, and RGeo should use its default
      # algorithm to cast the object.
      
      def override_cast(original_, type_, keep_subtype_, force_new_)
        false
      end
      
      
    end
  
    
  end
  
end
