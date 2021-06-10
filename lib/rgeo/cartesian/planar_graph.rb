# frozen_string_literal: true

module RGeo
  module Cartesian
    module Graphs
      # HalfEdge represents an edge as 2 directed edges.
      # One half-edge will have it's origin at edge.s, the other
      # at edge.e. Both half-edges will be linked as each other's twins.
      #
      # HalfEdges also contain pointers to the next and prev half-edges,
      # where next's origin is this half-edges destination. Prev's destination
      # is this half-edge's origin.
      class HalfEdge
        include Comparable

        # Creates 2 half edges from an edge.
        # They will be assigned as each other's twins.
        # The Half Edges will be returned in the order of points
        # of the edge (start, end).
        #
        # @param edge [RGeo::Cartesian::Segment]
        #
        # @return [Array]
        def self.from_edge(edge)
          # TODO: should we raise an error if the edge is degenerate?
          e1 = new(edge.s)
          e2 = new(edge.e)

          e1.twin = e2
          e2.twin = e1
          [e1, e2]
        end

        def initialize(origin)
          @origin = origin
          @twin = nil
          @next = nil
          @prev = nil
        end
        attr_reader :origin
        attr_accessor :twin, :next, :prev

        # HalfEdges will be sorted around their shared vertex
        # in a CW fashion. This means that face interiors will be
        # a CCW.
        def <=>(other)
          angle <=> other.angle
        end

        # Return the destination of the half edge
        #
        # @return [RGeo::Feature::Point]
        def destination
          twin.origin
        end

        # Compute the angle from the positive x-axis.
        # Used for sorting at each node.
        #
        # @return [Float]
        def angle
          @angle ||= Math.atan2(destination.y - origin.y, destination.x - origin.x)
        end
      end

      # A Doubly Connected Edge List (DCEL) implementation of a Planar Graph.
      # It represents geometries as vertices and half-edges.
      #
      # It includes an incident_edges hash that maps vertices to an array
      # of half-edges whose origins are that vertex.
      #
      # Upon instantiation, the graph will compute the intersections using
      # the SweeplineIntersector, populate the incident_edges map, and
      # link all cyclic edges.
      class PlanarGraph
        # Create a new PlanarGraph
        #
        # @param edges [Array<RGeo::Cartesian::Segment>] of Segments
        def initialize(edges)
          @edges = []
          @incident_edges = {}

          # this could be less efficient than computing the splits, then
          # adding adding them and linking them since this ends up creating
          # half edges that are potentially immediately split,
          #  but this creates a more consistent flow for adding edges.
          create_half_edges
          add_edges(edges)
          link_half_edges
        end
        attr_reader :edges, :incident_edges

        # Insert an edge into the graph. This will automatically
        # calculate intersections and add new vertices if necessary.
        #
        # @param edge [RGeo::Cartesian::Segment]
        def add_edge(edge)
          @edges << edge
          create_half_edge(edge)

          # It's possible that intersections were created from adding this edge.
          # Need to split the half-edges, while preserving existing half-edges
          # where possible since geometries may reference them.
          intersection_map.each do |seg, ints|
            compute_split_edges(seg, ints)
          end

          # could probably be done more efficiently since this re-links every
          # edge.
          link_half_edges
        end

        # Insert multiple edges into the graph. Like +add_edge+, this automatically
        # calculates intersections and adds new vertices.
        #
        # @param edge [Array<RGeo::Cartesian::Segment>]
        def add_edges(new_edges)
          @edges.concat(new_edges)
          new_edges.each do |edge|
            create_half_edge(edge)
          end

          intersection_map.each do |seg, ints|
            compute_split_edges(seg, ints)
          end

          link_half_edges
        end

        private

        # Creates a map of +proper_intersections+ for each segment
        # from a sweepline intersector.
        #
        # Can be used to determine which edges need to be split
        # after adding edges.
        def intersection_map
          intersector = SweeplineIntersector.new(edges)
          intersections = intersector.proper_intersections

          intersection_map = {}
          intersections.each do |int|
            # check the int_point against each edge.
            # if it is not on the boundary of the edge, add it to the
            # list of intersections for that edge.
            s1_intersects = int.point != int.s1.s && int.point != int.s1.e
            if s1_intersects
              unless intersection_map[int.s1]
                intersection_map[int.s1] = []
              end
              intersection_map[int.s1] << int.point
            end

            s2_intersects = int.point != int.s2.s && int.point != int.s2.e
            next unless s2_intersects
            unless intersection_map[int.s2]
              intersection_map[int.s2] = []
            end
            intersection_map[int.s2] << int.point
          end
          intersection_map
        end

        def create_half_edges
          @edges.each do |edge|
            create_half_edge(edge)
          end
        end

        def create_half_edge(edge)
          e1, e2 = HalfEdge.from_edge(edge)
          insert_half_edge(e1)
          insert_half_edge(e2)
        end

        def insert_half_edge(he)
          unless @incident_edges[he.origin.coordinates]
            @incident_edges[he.origin.coordinates] = []
          end
          @incident_edges[he.origin.coordinates] << he
        end

        # Links all half-edges where possible.
        # Defines +next+ and +prev+ for every half-edge by rotating
        # through all half-edges originating at a vertex.
        #
        # Assuming half-edges are sorted CCW, every sequential pair of
        # half-edges (e1, e2) can be linked by saying e1.prev = e2.twin
        # and e2.twin.next = e1.
        def link_half_edges
          @incident_edges.each_value do |hedges|
            hedges.sort!
            if hedges.size > 1
              (0..hedges.size - 2).each do |i|
                e1 = hedges[i]
                e2 = hedges[i + 1]

                e1.prev = e2.twin
                e2.twin.next = e1
              end

              hedges[-1].prev = hedges[0].twin
              hedges[0].twin.next = hedges[-1]

            # handle case of dangling line
            else
              e = hedges[0]
              e.twin.next = e
              e.prev = e.twin
            end
          end
        end

        # It is possible that intersections occur when new edges are added.
        # This will split those edges into more half-edges while preserving
        # the existing half-edges when possible since geometries may reference
        # them.
        def compute_split_edges(seg, ints)
          points = ints.concat([seg.s, seg.e])
          points = points.uniq.sort do |a, b|
            if a.y == b.y
              a.x <=> b.x
            else
              b.y <=> a.y
            end
          end
          he_start = @incident_edges[points.first.coordinates].find { |he| he.destination == points.last }
          he_end = @incident_edges[points.last.coordinates].find { |he| he.destination == points.first }

          points.each_cons(2) do |s, e|
            edge = Segment.new(s, e)
            if s == he_start.origin
              he = HalfEdge.new(e)
              he_start.twin = he
              he.twin = he_start
              insert_half_edge(he)
            elsif e == he_end.origin
              he = HalfEdge.new(s)
              he_end.twin = he
              he.twin = he_end
              insert_half_edge(he)
            else
              create_half_edge(edge)
            end
            @edges << edge
          end
          @edges.delete(seg)
        end
      end

      class GeometryGraph < PlanarGraph
      end
    end
  end
end
