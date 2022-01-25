# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for basic GeoJSON usage
#
# -----------------------------------------------------------------------------

require_relative "test_helper"

class CartesianAnalysisTest < Minitest::Test # :nodoc:
  class Fixtures
    def initialize(factory)
      @factory = factory
    end

    def line
      p1 = @factory.point(1, 1)
      p2 = @factory.point(2, 1)
      p3 = @factory.point(5, 1)
      @factory.line_string([p1, p2, p3, p1])
    end

    def clockwise_triangle
      p1 = @factory.point(1, 1)
      p2 = @factory.point(2, 4)
      p3 = @factory.point(5, 2)
      @factory.line_string([p1, p2, p3, p1])
    end

    def counterclockwise_triangle
      p1 = @factory.point(1, 1)
      p2 = @factory.point(2, 4)
      p3 = @factory.point(5, 2)
      @factory.line_string([p1, p3, p2, p1])
    end

    def clockwise_puckered_quad
      p1 = @factory.point(1, 1)
      p2 = @factory.point(2, 6)
      p3 = @factory.point(3, 3)
      p4 = @factory.point(5, 2)
      @factory.line_string([p1, p2, p3, p4, p1])
    end

    def counterclockwise_puckered_quad
      p1 = @factory.point(1, 1)
      p2 = @factory.point(2, 6)
      p3 = @factory.point(3, 3)
      p4 = @factory.point(5, 2)
      @factory.line_string([p1, p4, p3, p2, p1])
    end

    def clockwise_hat
      p1 = @factory.point(1, 2)
      p2 = @factory.point(2, 3)
      p3 = @factory.point(3, 2)
      p4 = @factory.point(2, 1)
      p5 = @factory.point(2, 0)
      p6 = @factory.point(0, 2)
      @factory.line_string([p1, p2, p3, p4, p5, p6, p1])
    end

    def counterclockwise_hat
      p1 = @factory.point(2, 1)
      p2 = @factory.point(3, 2)
      p3 = @factory.point(2, 3)
      p4 = @factory.point(1, 2)
      p5 = @factory.point(0, 2)
      p6 = @factory.point(2, 0)
      @factory.line_string([p1, p2, p3, p4, p5, p6, p1])
    end

    def counterclockwise_near_circle
      p1 = @factory.point(0, -3)
      p2 = @factory.point(2, -2)
      p3 = @factory.point(3, 0)
      p4 = @factory.point(2, 2)
      p5 = @factory.point(0, 3)
      p6 = @factory.point(-2, 2)
      p7 = @factory.point(-3, 0)
      p8 = @factory.point(-2, -2)
      @factory.line_string([p1, p2, p3, p4, p5, p6, p7, p8, p1])
    end
  end

  def setup
    @fixtures = Fixtures.new(RGeo::Cartesian.simple_factory)
  end

  # --------------------------------------------- RGeo::Cartesian::Analysis.ccw?

  def test_ccw_p_clockwise_triangle
    ring = @fixtures.clockwise_triangle
    assert_equal(
      false,
      RGeo::Cartesian::Analysis.ccw?(ring),
      "falls back to ring_direction"
    )
  end

  def test_ccw_p_counterclockwise_triangle
    ring = @fixtures.counterclockwise_triangle
    assert_equal(
      true,
      RGeo::Cartesian::Analysis.ccw?(ring),
      "falls back to ring_direction"
    )
  end

  def test_ccw_p_clockwise_puckered_quad
    ring = @fixtures.clockwise_puckered_quad
    assert_equal(false, RGeo::Cartesian::Analysis.ccw?(ring))
  end

  def test_ccw_p_counterclockwise_puckered_quad
    ring = @fixtures.counterclockwise_puckered_quad
    assert_equal(true, RGeo::Cartesian::Analysis.ccw?(ring))
  end

  def test_ccw_p_clockwise_hat
    ring = @fixtures.clockwise_hat
    assert_equal(false, RGeo::Cartesian::Analysis.ccw?(ring))
  end

  def test_ccw_p_counterclockwise_hat
    ring = @fixtures.counterclockwise_hat
    assert_equal(true, RGeo::Cartesian::Analysis.ccw?(ring))
  end

  def test_ccw_p_counterclockwise_near_circle
    ring = @fixtures.counterclockwise_near_circle
    assert_equal(true, RGeo::Cartesian::Analysis.ccw?(ring))
  end

  # ----------------------------------- RGeo::Cartesian::Analysis.ring_direction

  def test_ring_direction_line
    ring = @fixtures.line
    assert_equal(0, RGeo::Cartesian::Analysis.ring_direction(ring))
  end

  def test_ring_direction_clockwise_triangle
    ring = @fixtures.clockwise_triangle
    assert_equal(-1, RGeo::Cartesian::Analysis.ring_direction(ring))
  end

  def test_ring_direction_counterclockwise_triangle
    ring = @fixtures.counterclockwise_triangle
    assert_equal(1, RGeo::Cartesian::Analysis.ring_direction(ring))
  end

  def test_ring_direction_clockwise_puckered_quad
    ring = @fixtures.clockwise_puckered_quad
    assert_equal(-1, RGeo::Cartesian::Analysis.ring_direction(ring))
  end

  def test_ring_direction_counterclockwise_puckered_quad
    ring = @fixtures.counterclockwise_puckered_quad
    assert_equal(1, RGeo::Cartesian::Analysis.ring_direction(ring))
  end

  def test_ring_direction_clockwise_hat
    ring = @fixtures.clockwise_hat
    assert_equal(-1, RGeo::Cartesian::Analysis.ring_direction(ring))
  end

  def test_ring_direction_counterclockwise_hat
    ring = @fixtures.counterclockwise_hat
    assert_equal(1, RGeo::Cartesian::Analysis.ring_direction(ring))
  end

  def test_ring_direction_counterclockwise_near_circle
    ring = @fixtures.counterclockwise_near_circle
    assert_equal(1, RGeo::Cartesian::Analysis.ring_direction(ring))
  end
end
