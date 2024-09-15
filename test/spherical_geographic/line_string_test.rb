# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the simple spherical line string implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class SphericalLineStringTest < Minitest::Test # :nodoc:
  def setup
    @factory = RGeo::Geographic.spherical_factory
    @equator_line_string = @factory.line_string([
      @factory.point(-10.0, 0.0),
      @factory.point(10.0, 0.0),
      @factory.point(30.0, 0.0),
      @factory.point(50.0, 0.0)
    ])
    @null_meridian_line_string = @factory.line_string([
      @factory.point(0.0, -10.0),
      @factory.point(0.0, 10.0),
      @factory.point(0.0, 30.0),
      @factory.point(0.0, 80.0)
    ])
  end

  include RGeo::Tests::Common::LineStringTests

  def test_point_distance
    point1 = @factory.point(-5.0, 1.0)
    point2 = @factory.point(20.0, 2.0)
    point1_distance_rad = @equator_line_string.distance(point1) / (2 * Math::PI * RGeo::Geographic::SphericalMath::RADIUS)
    point2_distance_rad = @equator_line_string.distance(point2) / (2 * Math::PI * RGeo::Geographic::SphericalMath::RADIUS)
    assert_in_delta(1.0/360.0, point1_distance_rad, 1E-8)
    assert_in_delta(2.0/360.0, point2_distance_rad, 1E-8)
  end

  def test_closest_point_on_equator
    point = @factory.point(15.0, 1.0)
    closest_point = @equator_line_string.closest_point(point)
    assert_in_delta(closest_point.lat, 0, 1E-8)
    assert_in_delta(closest_point.lon, 15, 1E-8)
  end

  def test_closest_is_endpoint
    point = @factory.point(-15.0, -5.0)
    closest_point = @equator_line_string.closest_point(point)
    assert_in_delta(closest_point.lat, 0, 1E-8)
    assert_in_delta(closest_point.lon, -10, 1E-8)
  end

  def test_closest_point_on_meridian
    point = @factory.point(1.0, 5.0)
    closest_point = @null_meridian_line_string.closest_point(point)

    # The further north you get, the the more the closest point is not on the same latitude
    assert_in_delta(closest_point.lat, 5, 1E-3)
    assert_in_delta(closest_point.lon, 0, 1E-8)
  end

  def test_closest_point_on_meridian_north
    point = @factory.point(10.0, 75.0)
    closest_point = @null_meridian_line_string.closest_point(point)

    # The further north you get, the the more the closest point is not on the same latitude
    assert_in_delta(closest_point.lat, 75.21783354642534)
    assert_in_delta(closest_point.lon, 0, 1E-8)
  end

  undef_method :test_fully_equal
  undef_method :test_geometrically_equal_but_different_type
  undef_method :test_geometrically_equal_but_different_type2
  undef_method :test_geometrically_equal_but_different_overlap
  undef_method :test_empty_equal
  undef_method :test_not_equal
  undef_method :test_point_on_surface
end
