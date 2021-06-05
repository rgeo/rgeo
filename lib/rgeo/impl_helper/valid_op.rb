# frozen_string_literal: true

module RGeo
  module ImplHelper
    module TopologyErrors
      # Standard error messages from
      # https://github.com/locationtech/jts/blob/0afbfb1956ec24912a8b4dc4edff0f1200442857/modules/core/src/main/java/org/locationtech/jts/operation/valid/TopologyValidationError.java#L98-L110
      TOPOLOGY_VALIDATION_ERR = "Topology Validation Error"
      REPEATED_POINT = "Repeated Point"
      HOLE_OUTSIDE_SHELL = "Hole lies outside shell"
      NESTED_HOLES = "Holes are nested"
      DISCONNECTED_INTERIOR = "Interior is disconnected"
      SELF_INTERSECTION = "Self-intersection"
      RING_SELF_INTERSECTION = "Ring Self-intersection"
      NESTED_SHELLS = "Nested shells"
      DUPLICATE_RINGS = "Duplicate Rings"
      TOO_FEW_POINTS = "Too few distinct points in geometry component"
      INVALID_COORDINATE = "Invalid Coordinate"
      UNCLOSED_RING = "Ring is not closed"
    end

    # Mixin based off of the JTS/GEOS IsValidOp class.
    # Implements #valid? and #invalid_reason on Features that include this.
    #
    # @see https://github.com/locationtech/jts/blob/master/modules/core/src/main/java/org/locationtech/jts/operation/valid/IsValidOp.java
    module ValidOp
      # TODO: determine if "Unkown Validity" should count as valid.
      # Validity of geometry
      #
      # @return Boolean
      def valid?
        invalid_reason.nil?
      end
      alias is_valid? valid?

      # Reason for invalidity or nil if valid
      #
      # @return String
      def invalid_reason
        return @invalid_reason if defined?(@invalid_reason)
        @invalid_reason = check_valid
      end

      private

      # Method that performs validity checking. Just checks the type of geometry
      # and delegates to the proper validity checker.
      #
      # Returns a string describing the error or nil if it's a valid geometry.
      # In some cases, "Unkown Validity" is returned if a dependent method has
      # not been implemented.
      #
      # @return String
      def check_valid
        case self
        when Feature::Point
          check_valid_point
        when Feature::LineString
          check_valid_line_string
        when Feature::LinearRing
          check_valid_linear_ring
        when Feature::Polygon
          check_valid_polygon
        when Feature::MultiPoint
          check_valid_multi_point
        when Feature::MultiPolygon
          check_valid_multi_polygon
        when Feature::GeometryCollection
          check_valid_geometry_collection
        else
          raise NotImplementedError, "check_valid is not implemented for #{self}"
        end
      rescue RGeo::Error::UnsupportedOperation, NoMethodError
        "Unkown Validity"
      end

      def check_valid_point
        check_invalid_coordinate(self)
      end

      def check_valid_line_string
        # check coordinates are all valid
        points.each do |pt|
          check = check_invalid_coordinate(pt)
          return check unless check.nil?
        end

        # check more than 1 point
        return TopologyErrors::TOO_FEW_POINTS unless num_points > 1

        nil
      end

      def check_valid_linear_ring
        # check coordinates are all valid
        points.each do |pt|
          check = check_invalid_coordinate(pt)
          return check unless check.nil?
        end

        # check closed
        return TopologyErrors::UNCLOSED_RING unless is_closed?

        # check more than 1 point
        return TopologyErrors::TOO_FEW_POINTS unless num_points > 1

        # check no self-intersections
        check = check_no_self_intersections(self)
        return check unless check.nil?

        nil
      end

      def check_valid_polygon
        # check coordinates are all valid
        exterior_ring.points.each do |pt|
          check = check_invalid_coordinate(pt)
          return check unless check.nil?
        end
        interior_rings.each do |ring|
          ring.points.each do |pt|
            check = check_invalid_coordinate(pt)
            return check unless check.nil?
          end
        end

        # check closed
        return TopologyErrors::UNCLOSED_RING unless exterior_ring.is_closed?
        return TopologyErrors::UNCLOSED_RING unless interior_rings.all?(&:is_closed?)

        # check more than 3 points in each ring
        return TopologyErrors::TOO_FEW_POINTS unless exterior_ring.num_points > 3
        return TopologyErrors::TOO_FEW_POINTS unless interior_rings.all? { |r| r.num_points > 3 }

        check = check_consistent_area(self)
        return check unless check.nil?

        # check that there are no self-intersections
        check = check_no_self_intersecting_rings(self)
        return check unless check.nil?

        check = check_holes_in_shell(self)
        return check unless check.nil?

        check = check_holes_not_nested(self)
        return check unless check.nil?

        check = check_connected_interiors(self)
        return check unless check.nil?

        nil
      end

      def check_valid_multi_point
        geometries.each do |pt|
          check = check_invalid_coordinate(pt)
          return check unless check.nil?
        end
        nil
      end

      def check_valid_multi_polygon
        geometries.each do |poly|
          return poly.invalid_reason unless poly.invalid_reason.nil?
        end

        # check no shells are nested
        check = check_shells_not_nested(self)
        return check unless check.nil?

        nil
      end

      def check_valid_geometry_collection
        geometries.each do |geom|
          return geom.invalid_reason unless geom.invalid_reason.nil?
        end

        nil
      end

      ##
      # Helper functions for specific validity checks
      ##

      def check_invalid_coordinate(pt)
        return unless pt.x.nan? || pt.x.infinite? || pt.y.nan? || pt.y.infinite?

        TopologyErrors::INVALID_COORDINATE
      end

      # Checks that the edges in the polygon form a consistent area.
      #
      # Specifically, checks that there are intersections no between the
      # holes and the shell.
      #
      # Also checks that there are no duplicate rings.
      #
      # @param poly [RGeo::Feature::Polygon]
      #
      # @return [String] invalid_reason
      def check_consistent_area(poly)
        # Holes don't intersect exterior check.
        # TODO: possibly make this a cross since one point of the interior
        # lying on the boundary is valid.
        # Also this can probably be handled in a planar graph later.
        exterior = poly.exterior_ring
        poly.interior_rings.each do |ring|
          return TopologyErrors::SELF_INTERSECTION if ring.intersects?(exterior)
        end

        # check interiors do not intersect
        poly.interior_rings.combination(2).each do |ring1, ring2|
          return TopologyErrors::SELF_INTERSECTION if ring1.intersects?(ring2)
        end

        # Duplicate rings check
        rings = [exterior] + poly.interior_rings
        return TopologyErrors::DUPLICATE_RINGS if rings.uniq.size != rings.size

        nil
      end

      # Checks that the ring does not self-intersect. This is just a simplicity
      # check on the ring.
      #
      # @param ring [RGeo::Feature::LinearRing]
      #
      # @return [String] invalid_reason
      def check_no_self_intersections(ring)
        return TopologyErrors::RING_SELF_INTERSECTION unless ring.is_simple?
      end

      # Check that rings do not self intersect in a polygon
      #
      # @param poly [RGeo::Feature::Polygon]
      #
      # @return [String] invalid_reason
      def check_no_self_intersecting_rings(poly)
        exterior = poly.exterior_ring

        check = check_no_self_intersections(exterior)
        return check unless check.nil?

        poly.interior_rings.each do |ring|
          check = check_no_self_intersections(ring)
          return check unless check.nil?
        end

        nil
      end

      # Checks holes are contained inside the exterior of a polygon.
      # Assuming check_consistent_area has already passed on the polygon,
      # a simple point in polygon check can be done on one of the points
      # in each hole to verify (since we know none of them intersect).
      #
      # @param poly [RGeo::Feature::Polygon]
      #
      # @return [String] invalid_reason
      def check_holes_in_shell(poly)
        # get hole-less shell as test polygon
        shell = poly.exterior_ring
        shell = shell.factory.polygon(shell)

        poly.interior_rings.each do |interior|
          test_pt = interior.points[0]
          return TopologyErrors::HOLE_OUTSIDE_SHELL unless shell.contains?(test_pt)
        end

        nil
      end

      # Checks that holes are not nested within each other.
      #
      # @param poly [RGeo::Feature::Polygon]
      #
      # @return [String] invalid_reason
      def check_holes_not_nested(poly)
        # convert holes from linear_rings to polygons
        holes = poly.interior_rings
        holes = holes.map { |v| v.factory.polygon(v) }

        i = 0
        while i < holes.size
          j = i
          h1 = holes[i]
          while j < holes.size
            h2 = holes[j]

            return TopologyErrors::NESTED_HOLES if h1.contains?(h2) || h2.contains?(h1)
            j += 1
          end
          i += 1
        end

        nil
      end

      # Checks that the interior of the polygon is connected.
      # A disconnected interior can be described by this polygon for example
      # POLYGON((0 0, 10 0, 10 10, 0 10, 0 0), (5 0, 10 5, 5 10, 0 5, 5 0))
      #
      # Which is a square with a diamond inside of it.
      #
      # @param poly [RGeo::Feature::Polygon]
      #
      # @return [String] invalid_reason
      def check_connected_interiors(_poly)
        raise NotImplementedError, "#{__method__} not yet implemented"
      end

      # Checks that individual polygons within a multipolygon are not nested.
      #
      # @param mp [RGeo::Feature::MultiPolygon]
      #
      # @return [String] invalid_reason
      def check_shells_not_nested(_mp)
        raise NotImplementedError, "#{__method__} not yet implemented"
      end
    end
  end
end
