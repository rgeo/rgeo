# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the simple mercator window implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class MercatorWindowTest < Minitest::Test # :nodoc:
  def setup
    @factory = RGeo::Geographic.simple_mercator_factory
  end

  def assert_close_enough(p1_, p2_)
    assert((p1_.x - p2_.x).abs < 0.00001 && (p1_.y - p2_.y).abs < 0.00001)
  end

  def assert_contains_approx(point, mp_)
    assert(mp_.any? { |q_| (point.x - q_.x).abs < 0.00001 && (point.y - q_.y).abs < 0.00001 })
  end

  def test_limits
    limits_ = @factory.projection_limits_window
    assert_in_delta(-20_037_508, limits_.x_min, 1)
    assert_in_delta(-20_037_508, limits_.y_min, 1)
    assert_in_delta(20_037_508, limits_.x_max, 1)
    assert_in_delta(20_037_508, limits_.y_max, 1)
  end

  def test_limits_unprojected
    limits_ = @factory.projection_limits_window
    assert_close_enough(@factory.point(-180, -85.051129), limits_.sw_point)
    assert_close_enough(@factory.point(180, -85.051129), limits_.se_point)
    assert_close_enough(@factory.point(-180, 85.051129), limits_.nw_point)
    assert_close_enough(@factory.point(180, 85.051129), limits_.ne_point)
    assert_close_enough(@factory.point(0, 0), limits_.center_point)
  end

  def test_center_point
    window1_ = RGeo::Geographic::ProjectedWindow.for_corners(@factory.point(-160, -30), @factory.point(170, 30))
    assert_close_enough(@factory.point(5, 0), window1_.center_point)
    window2_ = RGeo::Geographic::ProjectedWindow.for_corners(@factory.point(160, -30), @factory.point(-170, 30))
    assert_close_enough(@factory.point(175, 0), window2_.center_point)
  end

  def test_random_point
    window1_ = RGeo::Geographic::ProjectedWindow.for_corners(@factory.point(-170, 30), @factory.point(-160, 40))
    20.times { assert(window1_.contains_point?(window1_.random_point)) }
    window2_ = RGeo::Geographic::ProjectedWindow.for_corners(@factory.point(170, 30), @factory.point(-170, 40))
    20.times { assert(window2_.contains_point?(window2_.random_point)) }
  end

  def test_crosses_seam
    window1_ = RGeo::Geographic::ProjectedWindow.for_corners(@factory.point(-170, 30), @factory.point(170, 40))
    assert(!window1_.crosses_seam?)
    window2_ = RGeo::Geographic::ProjectedWindow.for_corners(@factory.point(170, 30), @factory.point(-170, 40))
    assert(window2_.crosses_seam?)
  end

  def test_degenerate
    window1_ = RGeo::Geographic::ProjectedWindow.for_corners(@factory.point(-20, 30), @factory.point(-10, 40))
    assert(!window1_.degenerate?)
    window2_ = RGeo::Geographic::ProjectedWindow.for_corners(@factory.point(-20, 30), @factory.point(-20, 40))
    assert(window2_.degenerate?)
    window3_ = RGeo::Geographic::ProjectedWindow.for_corners(@factory.point(-20, 30), @factory.point(-10, 30))
    assert(window3_.degenerate?)
  end

  def test_contains_point
    window1_ = RGeo::Geographic::ProjectedWindow.for_corners(@factory.point(-170, 30), @factory.point(-160, 40))
    window2_ = RGeo::Geographic::ProjectedWindow.for_corners(@factory.point(170, 30), @factory.point(-170, 40))
    point1_ = @factory.point(-169, 32)
    point2_ = @factory.point(-171, 32)
    point3_ = @factory.point(-169, 29)
    point4_ = @factory.point(171, 32)
    point5_ = @factory.point(169, 32)
    assert(window1_.contains_point?(point1_))
    assert(!window1_.contains_point?(point2_))
    assert(!window1_.contains_point?(point3_))
    assert(!window2_.contains_point?(point1_))
    assert(window2_.contains_point?(point2_))
    assert(window2_.contains_point?(point4_))
    assert(!window2_.contains_point?(point5_))
  end

  def test_noseam_contains_window
    window = RGeo::Geographic::ProjectedWindow.for_corners(@factory.point(10, 10), @factory.point(30, 30))
    assert_window_contains_window(window, south: 15, west: 15, north: 25, east: 25)

    refute_window_contains_window(window, south: 5, west: 15, north: 25, east: 25)
    refute_window_contains_window(window, south: 15, west: 15, north: 35, east: 25)
    refute_window_contains_window(window, south: 0, west: 15, north: 5, east: 25)
    refute_window_contains_window(window, south: 35, west: 15, north: 40, east: 25)
    refute_window_contains_window(window, south: 5, west: 15, north: 35, east: 25)

    refute_window_contains_window(window, south: 15, west: 5, north: 25, east: 25)
    refute_window_contains_window(window, south: 15, west: 15, north: 25, east: 35)
    refute_window_contains_window(window, south: 15, west: 0, north: 25, east: 5)
    refute_window_contains_window(window, south: 15, west: 35, north: 25, east: 40)
    refute_window_contains_window(window, south: 15, west: 5, north: 25, east: 35)

    refute_window_contains_window(window, south: 170, west: 35, north: -170, east: 40)
  end

  def test_seam_contains_window
    window = RGeo::Geographic::ProjectedWindow.for_corners(@factory.point(160, 10), @factory.point(-160, 30))

    assert_window_contains_window(window, south: 175, west: 15, north: -175, east: 25)
    assert_window_contains_window(window, south: 170, west: 15, north: 175, east: 25)
    assert_window_contains_window(window, south: -175, west: 15, north: -170, east: 25)

    refute_window_contains_window(window, south: 150, west: 15, north: 170, east: 25)
    refute_window_contains_window(window, south: 150, west: 15, north: -170, east: 25)
    refute_window_contains_window(window, south: -170, west: 15, north: -150, east: 25)
    refute_window_contains_window(window, south: 170, west: 15, north: -150, east: 25)

    refute_window_contains_window(window, south: -150, west: 15, north: 150, east: 25)
    refute_window_contains_window(window, south: 150, west: 15, north: -150, east: 25)
  end

  def test_scaled_by
    window1_ = RGeo::Geographic::ProjectedWindow.for_corners(@factory.point(20, -20), @factory.point(50, 40))
    window1s_ = window1_.scaled_by(2, 1.5)
    assert(window1s_.contains_point?(@factory.point(10, -25)))
    assert(window1s_.contains_point?(@factory.point(60, 45)))
    assert(!window1s_.contains_point?(@factory.point(0, -25)))
    assert(!window1s_.contains_point?(@factory.point(10, -35)))
  end

  def test_scaled_by_across_seam
    window1_ = RGeo::Geographic::ProjectedWindow.for_corners(@factory.point(170, -20), @factory.point(-160, 40))
    window1s_ = window1_.scaled_by(2, 1.5)
    assert(window1s_.contains_point?(@factory.point(160, -25)))
    assert(window1s_.contains_point?(@factory.point(-150, 45)))
    assert(!window1s_.contains_point?(@factory.point(150, -25)))
    assert(!window1s_.contains_point?(@factory.point(-140, 45)))
  end

  def test_surrounding_point
    window1_ = RGeo::Geographic::ProjectedWindow.surrounding_point(@factory.point(20, -20), 1)
    assert(window1_.contains_point?(@factory.point(20, -20)))
    assert(!window1_.contains_point?(@factory.point(20, -21)))
    assert(!window1_.contains_point?(@factory.point(19, -20)))
  end

  def test_bounding_1_point
    window1_ = RGeo::Geographic::ProjectedWindow.bounding_points([@factory.point(20, -20)]).with_margin(1)
    assert(window1_.contains_point?(@factory.point(20, -20)))
    assert(!window1_.contains_point?(@factory.point(20, -21)))
    assert(!window1_.contains_point?(@factory.point(19, -20)))
  end

  def test_bounding_2_points
    window1_ = RGeo::Geographic::ProjectedWindow.bounding_points([@factory.point(10, 10), @factory.point(30, 30)])
    assert(window1_.contains_point?(@factory.point(20, 20)))
    assert(!window1_.contains_point?(@factory.point(5, 20)))
    assert(!window1_.contains_point?(@factory.point(20, 35)))
  end

  def test_bounding_2_points_across_seam
    window1_ = RGeo::Geographic::ProjectedWindow.bounding_points([@factory.point(-170, 10), @factory.point(170, 30)])
    assert(window1_.contains_point?(@factory.point(-174, 20)))
    assert(!window1_.contains_point?(@factory.point(-160, 20)))
    assert(!window1_.contains_point?(@factory.point(160, 20)))
    assert(!window1_.contains_point?(@factory.point(-174, 35)))
  end

  def test_random_point_not_crossing_seam
    point_ = @factory.point(-74, 40.7)
    max_distance_mercator_ = 1000
    max_distance_hypotenuse_ = Math.sqrt(max_distance_mercator_**2 * 2)
    window1_ = RGeo::Geographic::ProjectedWindow.surrounding_point(point_, max_distance_mercator_)
    10.times do
      actual_distance_ = window1_.random_point.distance(point_)
      assert_in_delta(0, actual_distance_, max_distance_hypotenuse_)
    end
  end

  def test_eql
    # Tests issue https://github.com/rgeo/rgeo/issues/379
    window1 = RGeo::Geographic::ProjectedWindow.new(@factory, 0, 5, 10, 10)
    window2 = RGeo::Geographic::ProjectedWindow.new(@factory, 0, 0, 10, 10)
    refute(window1.eql?(window2))

    window1 = RGeo::Geographic::ProjectedWindow.new(@factory, 0, 0, 10, 10)
    window2 = RGeo::Geographic::ProjectedWindow.new(@factory, 0, 0, 10, 10)
    assert(window1.eql?(window1))
  end

  private

  def assert_window_contains_window(window, south:, west:, north:, east:)
    contained = RGeo::Geographic::ProjectedWindow.for_corners(
      @factory.point(south, west), @factory.point(north, east)
    )

    assert(
      window.contains_window?(contained),
      "Window #{window} does not contain #{contained}"
    )
  end

  def refute_window_contains_window(window, south:, west:, north:, east:)
    contained = RGeo::Geographic::ProjectedWindow.for_corners(
      @factory.point(south, west), @factory.point(north, east)
    )

    refute(
      window.contains_window?(contained),
      "Window #{window} contains #{contained}"
    )
  end
end
