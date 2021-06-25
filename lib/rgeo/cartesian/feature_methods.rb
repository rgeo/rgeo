# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Cartesian common methods
#
# -----------------------------------------------------------------------------

module RGeo
  module Cartesian
    module GeometryMethods # :nodoc:
      def srid
        factory.srid
      end

      def envelope
        BoundingBox.new(factory).add(self).to_geometry
      end
    end

    module PointMethods # :nodoc:
      def distance(rhs)
        rhs = RGeo::Feature.cast(rhs, @factory)
        case rhs
        when PointImpl
          dx = @x - rhs.x
          dy = @y - rhs.y
          Math.sqrt(dx * dx + dy * dy)
        else
          super
        end
      end

      def buffer(distance)
        point_count = factory.property(:buffer_resolution) * 4
        angle = -::Math::PI * 2.0 / point_count
        points = (0...point_count).map do |i|
          r = angle * i
          factory.point(@x + distance * Math.cos(r), @y + distance * Math.sin(r))
        end
        factory.polygon(factory.linear_ring(points))
      end
    end

    module LineStringMethods # :nodoc:
      def segments
        @segments ||= (0..num_points - 2).map do |i|
          Segment.new(point_n(i), point_n(i + 1))
        end
      end

      def is_simple?
        li = SweeplineIntersector.new(segments)
        li.proper_intersections.size.zero?
      end

      def length
        segments.inject(0.0) { |sum, seg| sum + seg.length }
      end

      def crosses?(rhs)
        case rhs
        when Feature::LineString
          crosses_line_string?(rhs)
        else
          super
        end
      end

      private

      # Determines if a cross occurs with another linestring.
      # Method is to get the number of proper intersections in each geom
      # then overlay and get the number of proper intersections from that.
      # If the overlaid number is higher than the sum of individual self-ints
      # then there is an intersection. Finally, we need to check the intersection
      # to see that it is not a boundary point of either segment.
      #
      # @param rhs [Feature::LineString]
      #
      # @return [Boolean]
      def crosses_line_string?(rhs)
        self_ints = SweeplineIntersector.new(segments).proper_intersections
        self_ints += SweeplineIntersector.new(rhs.segments).proper_intersections
        overlay_ints = SweeplineIntersector.new(segments + rhs.segments).proper_intersections

        (overlay_ints - self_ints).each do |int|
          s1s = int.s1.s
          s1e = int.s1.e
          s2s = int.s2.s
          s2e = int.s2.e
          return true unless [s1s, s1e, s2s, s2e].include?(int.point)
        end

        false
      end
    end

    module PolygonMethods
      def graph
        @graph ||= Graphs::GeometryGraph.new(self)
      end

      # Checks that there are no invalid intersections between the components
      # of a polygon.
      #
      # @return [Boolean]
      def consistent_area?
        # Get set of unique coords
        pts = exterior_ring.coordinates.to_set
        interior_rings.each do |ring|
          pts += ring.coordinates
        end
        num_points = pts.size

        # if additional nodes were added, there must be an intersection
        # through a boundary.
        if graph.incident_edges.size > num_points
          return false
        end
        true
      end

      # Checks that the interior of a polygon is connected.
      #
      # Process to do this is to walk around an interior cycle of the
      # exterior shell in the polygon's geometry graph. It will keep track
      # of all the nodes it visited and if that set is a superset of the
      # coordinates in the exterior_ring, the interior is connected, otherwise
      # it is split somewhere.
      #
      # @return [Boolean]
      def connected_interior?
        exterior_coords = exterior_ring.coordinates.to_set

        visited = []
        graph.geom_edges.first.exterior_edge.each do |hedge|
          visited << hedge.origin.coordinates
        end
        visited = visited.to_set

        exterior_coords.subset?(visited)
      end
    end

    module MultiLineStringMethods # :nodoc:
      def length
        inject(0.0) { |sum, geom| sum + geom.length }
      end
    end
  end
end
