# -----------------------------------------------------------------------------
#
# Tests for basic GeoJSON usage
#
# -----------------------------------------------------------------------------

require "test_helper"

class CartesianAnalysisTest < Test::Unit::TestCase # :nodoc:
  def setup
    @factory = RGeo::Cartesian.simple_factory
  end

  def test_ring_direction_clockwise_triangle
    p1 = @factory.point(1, 1)
    p2 = @factory.point(2, 4)
    p3 = @factory.point(5, 2)
    ring = @factory.line_string([p1, p2, p3, p1])
    assert_equal(-1, RGeo::Cartesian::Analysis.ring_direction(ring))
  end

  def test_ring_direction_counterclockwise_triangle
    p1 = @factory.point(1, 1)
    p2 = @factory.point(2, 4)
    p3 = @factory.point(5, 2)
    ring = @factory.line_string([p1, p3, p2, p1])
    assert_equal(1, RGeo::Cartesian::Analysis.ring_direction(ring))
  end

  def test_ring_direction_clockwise_puckered_quad
    p1 = @factory.point(1, 1)
    p2 = @factory.point(2, 6)
    p3 = @factory.point(3, 3)
    p4 = @factory.point(5, 2)
    ring = @factory.line_string([p1, p2, p3, p4, p1])
    assert_equal(-1, RGeo::Cartesian::Analysis.ring_direction(ring))
  end

  def test_ring_direction_counterclockwise_puckered_quad
    p1 = @factory.point(1, 1)
    p2 = @factory.point(2, 6)
    p3 = @factory.point(3, 3)
    p4 = @factory.point(5, 2)
    ring = @factory.line_string([p1, p4, p3, p2, p1])
    assert_equal(1, RGeo::Cartesian::Analysis.ring_direction(ring))
  end

  def test_ring_direction_counterclockwise_near_circle
    p1 = @factory.point(0, -3)
    p2 = @factory.point(2, -2)
    p3 = @factory.point(3, 0)
    p4 = @factory.point(2, 2)
    p5 = @factory.point(0, 3)
    p6 = @factory.point(-2, 2)
    p7 = @factory.point(-3, 0)
    p8 = @factory.point(-2, -2)
    ring = @factory.line_string([p1, p2, p3, p4, p5, p6, p7, p8, p1])
    assert_equal(1, RGeo::Cartesian::Analysis.ring_direction(ring))
  end
end
