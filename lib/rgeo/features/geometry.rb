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
  
  module Features
    
    
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
    # this module itself. Therefore, you should not depend on the
    # kind_of? method to check type. Instead, use the provided check_type
    # class method. A corresponding === operator is also provided to
    # to support case-when constructs.
    # 
    # Some implementations may support higher dimensional objects or
    # coordinate systems, despite the limits of the SFS.
    # 
    # == Forms of equivalence
    # 
    # The Geometry model defines three forms of equivalence.
    # 
    # Spatial equivalence::
    #   Spatial equivalence is the weakest form of equivalence, indicating
    #   that the two objects represent the same region of space, but may
    #   be different representations of that region. For example, a
    #   POINT(0 0) and a MULTIPOINT(0 0) are spatially equivalent, as are
    #   LINESTRING(0 0, 10 10) and
    #   GEOMETRYCOLLECTION(POINT(0 0), LINESTRING(0 0, 10 10, 0 0)).
    #   As a general rule, objects must have factories that are eql? in
    #   order to be spatially equivalent.
    # Objective equivalence::
    #   Objective equivalence is a stronger form of equivalence, indicating
    #   that the two objects are the same representation, but may be
    #   different objects. All objectively equivalent objects are spatially
    #   equivalent, but not all spatially equivalent objects are
    #   objectively equivalent. For example, none of the examples in the
    #   spatial equivalence section above are objectively equivalent.
    #   However, two separate objects that both represent POINT(1 2) are
    #   objectively equivalent as well as spatially equivalent.
    # Objective identity::
    #   Objective identity is the strongest form, indicating that the two
    #   references refer to the same object. Of course, all pairs of
    #   references with the same objective identity are both objectively
    #   equivalent and spatially equivalent.
    # 
    # Different methods test for different types of equivalence:
    # 
    # * <tt>equals?</tt> and <tt>==</tt> test for spatial equivalence.
    # * <tt>eql?</tt> tests for objective equivalence.
    # * <tt>equal?</tt> tests for objective identity.
    
    module Geometry
      
      
      module ClassMethods
        
        # Returns true if the given object is this type or a subtype
        # thereof, or if it is a feature object whose geometry_type is
        # this type or a subtype thereof.
        # 
        # Note that feature objects need not actually include this module.
        
        def check_type(rhs_)
          rhs_ = rhs_.geometry_type if rhs_.respond_to?(:geometry_type)
          rhs_.kind_of?(::Module) && (rhs_ == self || rhs_.include?(self))
        end
        alias_method :===, :check_type
        
        
        def included(mod_)  # :nodoc:
          mod_.extend(ClassMethods) unless mod_.kind_of?(Class)
        end
        
      end
      
      
      extend ClassMethods
      
      
      # Returns a factory for creating features related to this one.
      # This does not necessarily need to be the same factory that created
      # this object, but it should create objects that are "compatible"
      # with this one. (i.e. they should be in the same spatial reference
      # system by default, and it should be possible to perform relational
      # operations on them.)
      
      def factory
        raise Errors::MethodUnimplemented
      end
      
      
      # Cast this geometry to the given type (which must be one of the
      # type modules in the Features module) and return the resulting
      # object. Returns nil if the cast fails because the types are not
      # compatible or the object does not satisfy the assertions for the
      # new type.
      # 
      # Generally, this is only useful for casting general classes to
      # subclasses; e.g. a GeometryCollection to a MultiPoint, or a
      # LineString to a LinearRing.
      
      def cast(type_)
        raise Errors::MethodUnimplemented
      end
      
      
      # Returns true if this geometric object is objectively equivalent
      # to the given object.
      
      def eql?(another_geometry_)
        raise Errors::MethodUnimplemented
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
        raise Errors::MethodUnimplemented
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns the instantiable subtype of Geometry of which this
      # geometric object is an instantiable member.
      # 
      # === Notes
      # 
      # Returns one of the type modules in RGeo::Features. e.g. a point
      # object would return RGeo::Features::Point. Note that this is
      # different from the SFS specification, which stipulates that the
      # string name of the type is returned. To obtain the name string,
      # call the +name+ method of the returned module.
      
      def geometry_type
        raise Errors::MethodUnimplemented
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
        raise Errors::MethodUnimplemented
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
        raise Errors::MethodUnimplemented
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
        raise Errors::MethodUnimplemented
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
        raise Errors::MethodUnimplemented
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
        raise Errors::MethodUnimplemented
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
        raise Errors::MethodUnimplemented
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
        raise Errors::MethodUnimplemented
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
      
      def equals?(another_geometry_)
        raise Errors::MethodUnimplemented
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
      
      def disjoint?(another_geometry_)
        raise Errors::MethodUnimplemented
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
      
      def intersects?(another_geometry_)
        raise Errors::MethodUnimplemented
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
      
      def touches?(another_geometry_)
        raise Errors::MethodUnimplemented
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
      
      def crosses?(another_geometry_)
        raise Errors::MethodUnimplemented
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
      
      def within?(another_geometry_)
        raise Errors::MethodUnimplemented
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
      
      def contains?(another_geometry_)
        raise Errors::MethodUnimplemented
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
      
      def overlaps?(another_geometry_)
        raise Errors::MethodUnimplemented
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
      
      def relate(another_geometry_, intersection_pattern_matrix_)
        raise Errors::MethodUnimplemented
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
      
      def distance(another_geometry_)
        raise Errors::MethodUnimplemented
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
        raise Errors::MethodUnimplemented
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns a geometric object that represents the convex hull of this
      # geometric object.
      # 
      # === Notes
      # 
      # Returns an object that supports the Geometry interface.
      
      def convex_hull()
        raise Errors::MethodUnimplemented
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns a geometric object that represents the Point set
      # intersection of this geometric object with another_geometry.
      # 
      # === Notes
      # 
      # Returns an object that supports the Geometry interface.
      
      def intersection(another_geometry_)
        raise Errors::MethodUnimplemented
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns a geometric object that represents the Point set
      # union of this geometric object with another_geometry.
      # 
      # === Notes
      # 
      # Returns an object that supports the Geometry interface.
      
      def union(another_geometry_)
        raise Errors::MethodUnimplemented
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns a geometric object that represents the Point set
      # difference of this geometric object with another_geometry.
      # 
      # === Notes
      # 
      # Returns an object that supports the Geometry interface.
      
      def difference(another_geometry_)
        raise Errors::MethodUnimplemented
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns a geometric object that represents the Point set symmetric
      # difference of this geometric object with another_geometry.
      # 
      # === Notes
      # 
      # Returns an object that supports the Geometry interface.
      
      def sym_difference(another_geometry_)
        raise Errors::MethodUnimplemented
      end
      
      
      # Alias of the equals? method.
      
      def ==(rhs_)
        equals?(rhs_)
      end
      
      
      # Alias of the difference method.
      
      def -(rhs_)
        difference(rhs_)
      end
      
      
      # Alias of the union method.
      
      def +(rhs_)
        union(rhs_)
      end
      
      
      # Alias of the intersection method.
      
      def *(rhs_)
        intersection(rhs_)
      end
      
      
    end
  
    
  end
  
end
