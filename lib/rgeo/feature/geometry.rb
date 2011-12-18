# -----------------------------------------------------------------------------
# 
# Geometry feature interface
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
  
  module Feature
    
    
    # == SFS 1.1 Description
    # 
    # Geometry is the root class of the hierarchy. Geometry is an abstract
    # (non-instantiable) class.
    # 
    # The instantiable subclasses of Geometry defined in this International
    # Standard are restricted to 0, 1 and 2-dimensional geometric objects
    # that exist in 2-dimensional coordinate space (R2).
    # 
    # All instantiable Geometry classes described in this part of ISO 19125
    # are defined so that valid instances of a Geometry class are
    # topologically closed, i.e. all defined geometries include their
    # boundary.
    # 
    # == Notes
    # 
    # Geometry is defined as a module and is provided primarily for the
    # sake of documentation. Implementations need not necessarily include
    # this module itself. Therefore, you should not depend on the result
    # of <tt>is_a?(Geometry)</tt> to check type. Instead, use the
    # provided check_type class method (or === operator) defined in the
    # Type module.
    # 
    # Some implementations may support higher dimensional objects or
    # coordinate systems, despite the limits of the SFS.
    # 
    # == Forms of equivalence
    # 
    # The Geometry model defines three forms of equivalence.
    # 
    # * <b>Spatial equivalence</b> is the weakest form of equivalence,
    #   indicating that the objects represent the same region of space,
    #   but may be different representations of that region. For example,
    #   POINT(0 0) and a MULTIPOINT(0 0) are spatially equivalent, as are
    #   LINESTRING(0 0, 10 10) and
    #   GEOMETRYCOLLECTION(POINT(0 0), LINESTRING(0 0, 10 10, 0 0)).
    #   As a general rule, objects must have factories that are
    #   Factory#eql? in order to be spatially equivalent.
    # 
    # * <b>Objective equivalence</b> is a stronger form of equivalence, 
    #   indicating that the objects are the same representation, but may
    #   be different objects. All objectively equivalent objects are
    #   spatially equivalent, but not all spatially equivalent objects are
    #   objectively equivalent. For example, none of the examples in the
    #   spatial equivalence section above are objectively equivalent.
    #   However, two separate objects that both represent POINT(1 2) are
    #   objectively equivalent as well as spatially equivalent.
    # 
    # * <b>Objective identity</b> is the strongest form, indicating that
    #   the references refer to the same object. Of course, all pairs of
    #   references with the same objective identity are both objectively
    #   equivalent and spatially equivalent.
    # 
    # Different methods test for different types of equivalence:
    # 
    # * <tt>equals?</tt> and <tt>==</tt> test for spatial equivalence.
    # * <tt>eql?</tt> tests for objective equivalence.
    # * <tt>equal?</tt> tests for objective identity.
    
    module Geometry
      
      extend Type
      
      
      # Returns a factory for creating features related to this one.
      # This does not necessarily need to be the same factory that created
      # this object, but it should create objects that are "compatible"
      # with this one. (i.e. they should be in the same spatial reference
      # system by default, and it should be possible to perform relational
      # operations on them.)
      
      def factory
        raise Error::UnsupportedOperation, "Method Geometry#factory not defined."
      end
      
      
      # Returns true if this geometric object is objectively equivalent
      # to the given object.
      
      def eql?(another_geometry_)
        raise Error::UnsupportedOperation, "Method Geometry#eql? not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # The inherent dimension of this geometric object, which must be less
      # than or equal to the coordinate dimension. This specification is
      # restricted to geometries in 2-dimensional coordinate space.
      # 
      # === Notes
      # 
      # Returns an integer. This value is -1 for an empty geometry, 0 for
      # point geometries, 1 for curves, and 2 for surfaces.
      
      def dimension
        raise Error::UnsupportedOperation, "Method Geometry#dimension not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns the instantiable subtype of Geometry of which this
      # geometric object is an instantiable member.
      # 
      # === Notes
      # 
      # Returns one of the type modules in RGeo::Feature. e.g. a point
      # object would return RGeo::Feature::Point. Note that this is
      # different from the SFS specification, which stipulates that the
      # string name of the type is returned. To obtain the name string,
      # call the +type_name+ method of the returned module.
      
      def geometry_type
        raise Error::UnsupportedOperation, "Method Geometry#geometry_type not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns the Spatial Reference System ID for this geometric object.
      # 
      # === Notes
      # 
      # Returns an integer.
      # 
      # This will normally be a foreign key to an index of reference systems
      # stored in either the same or some other datastore.
      
      def srid
        raise Error::UnsupportedOperation, "Method Geometry#srid not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # The minimum bounding box for this Geometry, returned as a Geometry.
      # The polygon is defined by the corner points of the bounding box
      # [(MINX, MINY), (MAXX, MINY), (MAXX, MAXY), (MINX, MAXY), (MINX, MINY)].
      # 
      # === Notes
      # 
      # Returns an object that supports the Geometry interface.
      
      def envelope
        raise Error::UnsupportedOperation, "Method Geometry#envelope not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Exports this geometric object to a specific Well-known Text
      # Representation of Geometry.
      # 
      # === Notes
      # 
      # Returns an ASCII string.
      
      def as_text
        raise Error::UnsupportedOperation, "Method Geometry#as_text not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Exports this geometric object to a specific Well-known Binary
      # Representation of Geometry.
      # 
      # === Notes
      # 
      # Returns a binary string.
      
      def as_binary
        raise Error::UnsupportedOperation, "Method Geometry#as_binary not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns true if this geometric object is the empty Geometry. If true,
      # then this geometric object represents the empty point set for the
      # coordinate space.
      # 
      # === Notes
      # 
      # Returns a boolean value. Note that this is different from the SFS
      # specification, which stipulates an integer return value.
      
      def is_empty?
        raise Error::UnsupportedOperation, "Method Geometry#is_empty? not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns true if this geometric object has no anomalous geometric
      # points, such as self intersection or self tangency. The description
      # of each instantiable geometric class will include the specific
      # conditions that cause an instance of that class to be classified as
      # not simple.
      # 
      # === Notes
      # 
      # Returns a boolean value. Note that this is different from the SFS
      # specification, which stipulates an integer return value.
      
      def is_simple?
        raise Error::UnsupportedOperation, "Method Geometry#is_simple? not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns the closure of the combinatorial boundary of this geometric
      # object. Because the result of this function is a closure, and hence
      # topologically closed, the resulting boundary can be represented using
      # representational Geometry primitives.
      # 
      # === Notes
      # 
      # Returns an object that supports the Geometry interface.
      
      def boundary
        raise Error::UnsupportedOperation, "Method Geometry#boundary not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns true if this geometric object is "spatially equal" to
      # another_geometry.
      # 
      # === Notes
      # 
      # Returns a boolean value. Note that this is different from the SFS
      # specification, which stipulates an integer return value.
      # 
      # Although implementations are free to attempt to handle
      # another_geometry values that do not share the same factory as
      # this geometry, strictly speaking, the result of comparing objects
      # of different factories is undefined.
      
      def equals?(another_geometry_)
        raise Error::UnsupportedOperation, "Method Geometry#equals? not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns true if this geometric object is "spatially disjoint" from
      # another_geometry.
      # 
      # === Notes
      # 
      # Returns a boolean value. Note that this is different from the SFS
      # specification, which stipulates an integer return value.
      # 
      # Although implementations are free to attempt to handle
      # another_geometry values that do not share the same factory as
      # this geometry, strictly speaking, the result of comparing objects
      # of different factories is undefined.
      
      def disjoint?(another_geometry_)
        raise Error::UnsupportedOperation, "Method Geometry#disjoint? not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns true if this geometric object "spatially intersects"
      # another_geometry.
      # 
      # === Notes
      # 
      # Returns a boolean value. Note that this is different from the SFS
      # specification, which stipulates an integer return value.
      # 
      # Although implementations are free to attempt to handle
      # another_geometry values that do not share the same factory as
      # this geometry, strictly speaking, the result of comparing objects
      # of different factories is undefined.
      
      def intersects?(another_geometry_)
        raise Error::UnsupportedOperation, "Method Geometry#intersects? not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns true if this geometric object "spatially touches"
      # another_geometry.
      # 
      # === Notes
      # 
      # Returns a boolean value. Note that this is different from the SFS
      # specification, which stipulates an integer return value.
      # 
      # Although implementations are free to attempt to handle
      # another_geometry values that do not share the same factory as
      # this geometry, strictly speaking, the result of comparing objects
      # of different factories is undefined.
      
      def touches?(another_geometry_)
        raise Error::UnsupportedOperation, "Method Geometry#touches? not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns true if this geometric object "spatially crosses"
      # another_geometry.
      # 
      # === Notes
      # 
      # Returns a boolean value. Note that this is different from the SFS
      # specification, which stipulates an integer return value.
      # 
      # Although implementations are free to attempt to handle
      # another_geometry values that do not share the same factory as
      # this geometry, strictly speaking, the result of comparing objects
      # of different factories is undefined.
      
      def crosses?(another_geometry_)
        raise Error::UnsupportedOperation, "Method Geometry#crosses? not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns true if this geometric object is "spatially within"
      # another_geometry.
      # 
      # === Notes
      # 
      # Returns a boolean value. Note that this is different from the SFS
      # specification, which stipulates an integer return value.
      # 
      # Although implementations are free to attempt to handle
      # another_geometry values that do not share the same factory as
      # this geometry, strictly speaking, the result of comparing objects
      # of different factories is undefined.
      
      def within?(another_geometry_)
        raise Error::UnsupportedOperation, "Method Geometry#within? not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns true if this geometric object "spatially contains"
      # another_geometry.
      # 
      # === Notes
      # 
      # Returns a boolean value. Note that this is different from the SFS
      # specification, which stipulates an integer return value.
      # 
      # Although implementations are free to attempt to handle
      # another_geometry values that do not share the same factory as
      # this geometry, strictly speaking, the result of comparing objects
      # of different factories is undefined.
      
      def contains?(another_geometry_)
        raise Error::UnsupportedOperation, "Method Geometry#contains? not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns true if this geometric object "spatially overlaps"
      # another_geometry.
      # 
      # === Notes
      # 
      # Returns a boolean value. Note that this is different from the SFS
      # specification, which stipulates an integer return value.
      # 
      # Although implementations are free to attempt to handle
      # another_geometry values that do not share the same factory as
      # this geometry, strictly speaking, the result of comparing objects
      # of different factories is undefined.
      
      def overlaps?(another_geometry_)
        raise Error::UnsupportedOperation, "Method Geometry#overlaps? not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns true if this geometric object is spatially related to
      # another_geometry by testing for intersections between the interior,
      # boundary and exterior of the two geometric objects as specified by
      # the values in the intersection_pattern_matrix.
      # 
      # === Notes
      # 
      # The intersection_pattern_matrix is provided as a nine-character
      # string in row-major order, representing the dimensionalities of
      # the different intersections in the DE-9IM. Supported characters
      # include T, F, *, 0, 1, and 2.
      # 
      # Returns a boolean value. Note that this is different from the SFS
      # specification, which stipulates an integer return value.
      # 
      # Although implementations are free to attempt to handle
      # another_geometry values that do not share the same factory as
      # this geometry, strictly speaking, the result of comparing objects
      # of different factories is undefined.
      
      def relate(another_geometry_, intersection_pattern_matrix_)
        raise Error::UnsupportedOperation, "Method Geometry#relate not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns the shortest distance between any two Points in the two
      # geometric objects as calculated in the spatial reference system of
      # this geometric object.
      # 
      # === Notes
      # 
      # Returns a floating-point scalar value.
      # 
      # Although implementations are free to attempt to handle
      # another_geometry values that do not share the same factory as
      # this geometry, strictly speaking, the result of measuring the
      # distance between objects of different factories is undefined.
      
      def distance(another_geometry_)
        raise Error::UnsupportedOperation, "Method Geometry#distance not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns a geometric object that represents all Points whose distance
      # from this geometric object is less than or equal to distance.
      # Calculations are in the spatial reference system of this geometric
      # object.
      # 
      # === Notes
      # 
      # Returns an object that supports the Geometry interface.
      
      def buffer(distance_)
        raise Error::UnsupportedOperation, "Method Geometry#buffer not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns a geometric object that represents the convex hull of this
      # geometric object.
      # 
      # === Notes
      # 
      # Returns an object that supports the Geometry interface.
      
      def convex_hull
        raise Error::UnsupportedOperation, "Method Geometry#convex_hull not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns a geometric object that represents the Point set
      # intersection of this geometric object with another_geometry.
      # 
      # === Notes
      # 
      # Returns an object that supports the Geometry interface.
      # 
      # Although implementations are free to attempt to handle
      # another_geometry values that do not share the same factory as
      # this geometry, strictly speaking, the result of performing
      # operations on objects of different factories is undefined.
      
      def intersection(another_geometry_)
        raise Error::UnsupportedOperation, "Method Geometry#intersection not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns a geometric object that represents the Point set
      # union of this geometric object with another_geometry.
      # 
      # === Notes
      # 
      # Returns an object that supports the Geometry interface.
      # 
      # Although implementations are free to attempt to handle
      # another_geometry values that do not share the same factory as
      # this geometry, strictly speaking, the result of performing
      # operations on objects of different factories is undefined.
      
      def union(another_geometry_)
        raise Error::UnsupportedOperation, "Method Geometry#union not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns a geometric object that represents the Point set
      # difference of this geometric object with another_geometry.
      # 
      # === Notes
      # 
      # Returns an object that supports the Geometry interface.
      # 
      # Although implementations are free to attempt to handle
      # another_geometry values that do not share the same factory as
      # this geometry, strictly speaking, the result of performing
      # operations on objects of different factories is undefined.
      
      def difference(another_geometry_)
        raise Error::UnsupportedOperation, "Method Geometry#difference not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns a geometric object that represents the Point set symmetric
      # difference of this geometric object with another_geometry.
      # 
      # === Notes
      # 
      # Returns an object that supports the Geometry interface.
      # 
      # Although implementations are free to attempt to handle
      # another_geometry values that do not share the same factory as
      # this geometry, strictly speaking, the result of performing
      # operations on objects of different factories is undefined.
      
      def sym_difference(another_geometry_)
        raise Error::UnsupportedOperation, "Method Geometry#sym_difference not defined."
      end
      
      
      # This operator should behave almost the same as the equals? method.
      # The difference is that the == operator is required to handle rhs
      # values that are not geometry objects (returning false in such cases)
      # in order to fulfill the standard Ruby contract for the == operator,
      # whereas the equals? method may assume that any rhs is a geometry.
      
      def ==(rhs_)
        rhs_.kind_of?(::RGeo::Feature::Instance) ? equals?(rhs_) : false
      end
      
      
      # If the given rhs is a geometry object, this operator must behave
      # the same as the difference method. The behavior for other rhs
      # types is not specified; an implementation may choose to provide
      # additional capabilities as appropriate.
      
      def -(rhs_)
        difference(rhs_)
      end
      
      
      # If the given rhs is a geometry object, this operator must behave
      # the same as the union method. The behavior for other rhs types
      # is not specified; an implementation may choose to provide
      # additional capabilities as appropriate.
      
      def +(rhs_)
        union(rhs_)
      end
      
      
      # If the given rhs is a geometry object, this operator must behave
      # the same as the intersection method. The behavior for other rhs
      # types is not specified; an implementation may choose to provide
      # additional capabilities as appropriate.
      
      def *(rhs_)
        intersection(rhs_)
      end
      
      
    end
  
    
  end
  
end
