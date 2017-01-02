# -----------------------------------------------------------------------------
#
# Geometry feature interface
#
# -----------------------------------------------------------------------------

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
    # * <b>Representational equivalence</b> is a stronger form, indicating
    #   that the objects have the same representation, but may be
    #   different objects. All representationally equivalent objects are
    #   spatially equivalent, but not all spatially equivalent objects are
    #   representationally equivalent. For example, none of the examples
    #   in the spatial equivalence section above are representationally
    #   equivalent. However, two separate objects that both represent
    #   POINT(1 2) are representationally equivalent as well as spatially
    #   equivalent.
    #
    # * <b>Objective equivalence</b> is the strongest form, indicating
    #   that the references refer to the same object. Of course, all
    #   pairs of references with the same objective identity are also
    #   both representationally and spatially equivalent.
    #
    # Different methods test for different types of equivalence:
    #
    # * <tt>equals?</tt> and <tt>==</tt> test for spatial equivalence.
    # * <tt>rep_equals?</tt> and <tt>eql?</tt> test for representational
    #   equivalence.
    # * <tt>equal?</tt> tests for objective equivalence.
    #
    # All ruby objects must provide a suitable test for objective
    # equivalence. Normally, this is simply provided by the Ruby Object
    # base class. Geometry implementations should normally also provide
    # tests for representational and spatial equivalence, if possible.
    # The <tt>==</tt> operator and the <tt>eql?</tt> method are standard
    # Ruby methods that are often expected to be usable for every object.
    # Therefore, if an implementation cannot provide a suitable test for
    # their equivalence types, they must degrade to use a stronger form
    # of equivalence.

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
      # from different factories is undefined.

      def equals?(_another_geometry_)
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
      # from different factories is undefined.

      def disjoint?(_another_geometry_)
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
      # from different factories is undefined.

      def intersects?(_another_geometry_)
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
      # from different factories is undefined.

      def touches?(_another_geometry_)
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
      # from different factories is undefined.

      def crosses?(_another_geometry_)
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
      # from different factories is undefined.

      def within?(_another_geometry_)
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
      # from different factories is undefined.

      def contains?(_another_geometry_)
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
      # from different factories is undefined.

      def overlaps?(_another_geometry_)
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
      # from different factories is undefined.

      def relate?(_another_geometry_, _intersection_pattern_matrix_)
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
      # distance between objects from different factories is undefined.

      def distance(_another_geometry_)
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

      def buffer(_distance_)
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
      # operations on objects from different factories is undefined.

      def intersection(_another_geometry_)
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
      # operations on objects from different factories is undefined.

      def union(_another_geometry_)
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
      # operations on objects from different factories is undefined.

      def difference(_another_geometry_)
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
      # operations on objects from different factories is undefined.

      def sym_difference(_another_geometry_)
        raise Error::UnsupportedOperation, "Method Geometry#sym_difference not defined."
      end

      # Returns true if this geometric object is representationally
      # equivalent to the given object.
      #
      # Although implementations are free to attempt to handle
      # another_geometry values that do not share the same factory as
      # this geometry, strictly speaking, the result of comparing objects
      # from different factories is undefined.

      def rep_equals?(_another_geometry_)
        raise Error::UnsupportedOperation, "Method Geometry#rep_equals? not defined."
      end

      # This method should behave almost the same as the rep_equals?
      # method, with two key differences.
      #
      # First, the <tt>eql?</tt> method is required to handle rhs values
      # that are not geometry objects (returning false in such cases) in
      # order to fulfill the standard Ruby contract for the method,
      # whereas the rep_equals? method may assume that any rhs is a
      # geometry.
      #
      # Second, the <tt>eql?</tt> method should always be defined. That
      # is, it should never raise Error::UnsupportedOperation. In cases
      # where the underlying implementation cannot provide a
      # representational equivalence test, this method must fall back on
      # objective equivalence.

      def eql?(rhs_)
        if rhs_.is_a?(::RGeo::Feature::Instance)
          begin
            rep_equals?(rhs_)
          rescue Error::UnsupportedOperation
            equal?(rhs_)
          end
        else
          false
        end
      end

      # This operator should behave almost the same as the equals? method,
      # with two key differences.
      #
      # First, the == operator is required to handle rhs values that are
      # not geometry objects (returning false in such cases) in order to
      # fulfill the standard Ruby contract for the == operator, whereas
      # the equals? method may assume that any rhs is a geometry.
      #
      # Second, the == operator should always be defined. That is, it
      # should never raise Error::UnsupportedOperation. In cases where
      # the underlying implementation cannot provide a spatial equivalence
      # test, the == operator must fall back on representational or
      # objective equivalence.

      def ==(rhs_)
        if rhs_.is_a?(::RGeo::Feature::Instance)
          begin
            equals?(rhs_)
          rescue Error::UnsupportedOperation
            eql?(rhs_)
          end
        else
          false
        end
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
