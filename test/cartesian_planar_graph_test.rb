# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the planar graph and related classes
#
# -----------------------------------------------------------------------------

require "test_helper"

class CartesianPlanarGraphTest < Minitest::Test
  def setup
    @factory = RGeo::Cartesian.simple_factory

    @point1 = @factory.point(0, 0)
    @point2 = @factory.point(1, 0)
    @point3 = @factory.point(1, 1)
    @point4 = @factory.point(0, 1)

    @point5 = @factory.point(0, 0.5)
    @point6 = @factory.point(0.5, 0)
    @point7 = @factory.point(1, 0.5)
    @point8 = @factory.point(0.5, 1)

    @point9 = @factory.point(0.33, 0.33)
    @point10 = @factory.point(0.66, 0.33)
    @point11 = @factory.point(0.66, 0.66)
    @point12 = @factory.point(0.33, 0.66)

    @point13 = @factory.point(0.33, 1.5)
    @point14 = @factory.point(0.5, 0.5)
    @point15 = @factory.point(0.66, 1.5)

    @big_sq_ring = @factory.linear_ring([@point1, @point2, @point3, @point4, @point1])
    @incscribed_diamond_ring = @factory.linear_ring([@point5, @point6, @point7, @point8, @point5])
    @little_sq_ring = @factory.linear_ring([@point9, @point10, @point11, @point12, @point9])
    @intersecting_triangle_ring = @factory.linear_ring([@point13, @point14, @point15, @point13])
    @hourglass = @factory.line_string([@point1, @point3, @point4, @point2, @point1])
  end

  def test_half_edge_from_edge
    seg = @big_sq_ring.segments.first
    e1, e2 = RGeo::Cartesian::Graphs::HalfEdge.from_edge(seg)

    assert_equal(@point1, e1.origin)
    assert_equal(@point2, e2.origin)
    assert_equal(e2, e1.twin)
    assert_equal(e1, e2.twin)
    assert_equal(e2.origin, e1.destination)
    assert_equal(e1.origin, e2.destination)
  end

  def test_half_edge_angle
    seg = RGeo::Cartesian::Segment.new(@point1, @point3)
    e1, e2 = RGeo::Cartesian::Graphs::HalfEdge.from_edge(seg)

    assert_equal(Math::PI / 4, e1.angle)
    assert_equal(Math::PI * (-3 / 4.0), e2.angle)
  end

  def test_half_edge_sort
    # test edges going into every quadrant
    pt5 = @factory.point(-1, 1)
    pt6 = @factory.point(-1, -1)
    pt7 = @factory.point(1, -1)

    seg1 = RGeo::Cartesian::Segment.new(@point1, @point2)
    seg2 = RGeo::Cartesian::Segment.new(@point1, @point3)
    seg3 = RGeo::Cartesian::Segment.new(@point1, @point4)
    seg4 = RGeo::Cartesian::Segment.new(@point1, pt5)
    seg5 = RGeo::Cartesian::Segment.new(@point1, pt6)
    seg6 = RGeo::Cartesian::Segment.new(@point1, pt7)

    e1, = RGeo::Cartesian::Graphs::HalfEdge.from_edge(seg1)
    e2, = RGeo::Cartesian::Graphs::HalfEdge.from_edge(seg2)
    e3, = RGeo::Cartesian::Graphs::HalfEdge.from_edge(seg3)
    e4, = RGeo::Cartesian::Graphs::HalfEdge.from_edge(seg4)
    e5, = RGeo::Cartesian::Graphs::HalfEdge.from_edge(seg5)
    e6, = RGeo::Cartesian::Graphs::HalfEdge.from_edge(seg6)

    edges = [e3, e1, e2, e5, e4, e6] # wrong order
    edges.sort!

    assert_equal([e5, e6, e1, e2, e3, e4], edges)
  end

  def test_create_planar_graph
    graph_shapes = [@big_sq_ring, @hourglass]
    graph_shapes.each do |shape|
      graph = RGeo::Cartesian::Graphs::PlanarGraph.new(shape.segments)

      # assert that all the links are made properly
      graph.incident_edges.each_value do |hedges|
        hedges.each do |hedge|
          assert_equal(hedge.destination, hedge.next.origin)
          assert_equal(hedge.origin, hedge.prev.destination)
        end
      end
    end
  end

  def test_planar_graph_add_edge_existing_vertices
    e = RGeo::Cartesian::Segment.new(@point1, @point3)
    graph = RGeo::Cartesian::Graphs::PlanarGraph.new(@big_sq_ring.segments)
    exp_vertices = 4
    exp_edges = 5

    graph.add_edge(e)
    assert_equal(exp_vertices, graph.incident_edges.size)
    assert_equal(exp_edges, graph.edges.size)

    assert_equal(3, graph.incident_edges[[0.0, 0.0]].size)
    assert_equal(3, graph.incident_edges[[1.0, 1.0]].size)

    graph.incident_edges.each_value do |hedges|
      hedges.each do |hedge|
        assert_equal(hedge.destination, hedge.next.origin)
        assert_equal(hedge.origin, hedge.prev.destination)
      end
    end
  end

  def test_planar_graph_add_edge_new_vertex_no_intersections
    pt = @factory.point(-1, 2)
    e = RGeo::Cartesian::Segment.new(@point4, pt)
    graph = RGeo::Cartesian::Graphs::PlanarGraph.new(@big_sq_ring.segments)
    exp_vertices = graph.incident_edges.size + 1
    exp_edges = 5

    graph.add_edge(e)
    assert_equal(exp_vertices, graph.incident_edges.size)
    assert_equal(exp_edges, graph.edges.size)

    assert_equal(3, graph.incident_edges[[0.0, 1.0]].size)
    assert_equal(1, graph.incident_edges[[-1.0, 2.0]].size)

    graph.incident_edges.each_value do |hedges|
      hedges.each do |hedge|
        assert_equal(hedge.destination, hedge.next.origin)
        assert_equal(hedge.origin, hedge.prev.destination)
      end
    end
  end

  def test_planar_graph_add_edge_new_vertex_boundary_intersections
    pt1 = @factory.point(0, 0.5)
    pt2 = @factory.point(1, 0.5)
    e = RGeo::Cartesian::Segment.new(pt1, pt2)
    graph = RGeo::Cartesian::Graphs::PlanarGraph.new(@big_sq_ring.segments)
    exp_vertices = 6
    exp_edges = 7

    graph.add_edge(e)
    assert_equal(exp_vertices, graph.incident_edges.size)
    assert_equal(exp_edges, graph.edges.size)

    assert_equal(3, graph.incident_edges[pt1.coordinates].size)
    assert_equal(3, graph.incident_edges[pt2.coordinates].size)

    graph.incident_edges.each_value do |hedges|
      hedges.each do |hedge|
        assert_equal(hedge.destination, hedge.next.origin)
        assert_equal(hedge.origin, hedge.prev.destination)
      end
    end
  end

  def test_planar_graph_add_edge_new_vertex_interior_intersections
    pt1 = @factory.point(0.5, 1.5)
    pt2 = @factory.point(0.5, 0.5)
    e = RGeo::Cartesian::Segment.new(pt1, pt2)
    graph = RGeo::Cartesian::Graphs::PlanarGraph.new(@big_sq_ring.segments)
    exp_vertices = 7
    exp_edges = 7

    graph.add_edge(e)
    assert_equal(exp_edges, graph.incident_edges.size)
    assert_equal(exp_vertices, graph.edges.size)

    assert_equal(1, graph.incident_edges[pt1.coordinates].size)
    assert_equal(1, graph.incident_edges[pt2.coordinates].size)
    assert_equal(4, graph.incident_edges[[0.5, 1.0]].size)

    graph.incident_edges.each_value do |hedges|
      hedges.each do |hedge|
        assert_equal(hedge.destination, hedge.next.origin)
        assert_equal(hedge.origin, hedge.prev.destination)
      end
    end
  end

  def test_planar_graph_add_edge_disconnected
    e = RGeo::Cartesian::Segment.new(@point9, @point10)
    graph = RGeo::Cartesian::Graphs::PlanarGraph.new(@big_sq_ring.segments)
    exp_vertices = 6
    exp_edges = 5

    graph.add_edge(e)
    assert_equal(exp_vertices, graph.incident_edges.size)
    assert_equal(exp_edges, graph.edges.size)

    assert_equal(1, graph.incident_edges[@point9.coordinates].size)
    assert_equal(1, graph.incident_edges[@point10.coordinates].size)

    graph.incident_edges.each_value do |hedges|
      hedges.each do |hedge|
        assert_equal(hedge.destination, hedge.next.origin)
        assert_equal(hedge.origin, hedge.prev.destination)
      end
    end
  end

  def test_planar_graph_add_edges_multiple_ints
    graph = RGeo::Cartesian::Graphs::PlanarGraph.new(@big_sq_ring.segments)
    graph.add_edges(@intersecting_triangle_ring.segments)
    exp_vertices = 9
    exp_edges = 11

    assert_equal(exp_vertices, graph.incident_edges.size)
    assert_equal(exp_edges, graph.edges.size)

    graph.incident_edges.each_value do |hedges|
      hedges.each do |hedge|
        assert_equal(hedge.destination, hedge.next.origin)
        assert_equal(hedge.origin, hedge.prev.destination)
      end
    end

    # do one last test to ensure that all loops can be traversed
    # We need to find one of the new vertices on the top of the square
    # it will be more stable to look through incident_edges and find one
    # that has 4 incident half-edges. This is because the x-intersection
    # points are floating point numbers and may be different between systems.
    hedges = graph.incident_edges.find { |_, v| v.size == 4 }.last
    hedges.each do |hedge|
      origin = hedge.origin
      n = hedge.next
      ct = 0
      until n.eql?(hedge)
        n = n.next

        # safely bail out if something went wrong
        ct += 1
        assert(false, "Infinite Loop in Graph") if ct > exp_edges
      end

      assert_equal(origin, n.origin)
    end
  end
end
