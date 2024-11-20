# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the simple spherical point implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class SphericalPointTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::PointTests

  def setup
    @factory = RGeo::Geographic.spherical_factory(buffer_resolution: 8)
    @zfactory = RGeo::Geographic.spherical_factory(has_z_coordinate: true)
    @mfactory = RGeo::Geographic.spherical_factory(has_m_coordinate: true)
    @zmfactory = RGeo::Geographic.spherical_factory(has_z_coordinate: true, has_m_coordinate: true)
  end

  def test_latlon
    point = @factory.point(21, -22)
    assert_equal(21, point.longitude)
    assert_equal(-22, point.latitude)
  end

  def test_antimeridian_positive
    point = @factory.point(180, 85)
    assert_equal(180, point.longitude)
    assert_equal(85, point.latitude)
  end

  def test_antimeridian_netagive
    point = @factory.point(-180, -85)
    assert_equal(-180, point.longitude)
    assert_equal(-85, point.latitude)
  end

  def test_srid
    point = @factory.point(11, 12)
    assert_equal(4055, point.srid)
  end

  def test_point_distance
    point1 = @factory.point(0, 10)
    point2 = @factory.point(0, 10)
    point3 = @factory.point(0, 40)
    assert_in_delta(0, point1.distance(point2), 0.0001)
    assert_in_delta(Math::PI / 6.0 * RGeo::Geographic::SphericalMath::RADIUS, point1.distance(point3), 0.0001)
  end

  def test_line_string_distance
    line_string = @factory.line_string(
      [
        @factory.point(-10.0, 0.0),
        @factory.point(10.0, 0.0),
        @factory.point(30.0, 0.0),
        @factory.point(50.0, 0.0)
      ]
    )
    point1 = @factory.point(-5.0, 1.0)
    point2 = @factory.point(20.0, 2.0)
    point1_distance_rad = point1.distance(line_string) / (2 * Math::PI * RGeo::Geographic::SphericalMath::RADIUS)
    point2_distance_rad = point2.distance(line_string) / (2 * Math::PI * RGeo::Geographic::SphericalMath::RADIUS)
    assert_in_delta(1.0 / 360.0, point1_distance_rad, 1E-8)
    assert_in_delta(2.0 / 360.0, point2_distance_rad, 1E-8)
  end

  def test_line_string_diagonal_arc
    # https://jsfiddle.net/kLocyn6s/44/
    seattle = @factory.point(-122.2, 47.5)
    brussels = @factory.point(4.35, 50.8)
    reykjavik = @factory.point(-21.83, 64.13)

    seattle_brussels_arc = @factory.line_string([seattle, brussels])
    distance = reykjavik.distance(seattle_brussels_arc)
    # This isn't very precise, but it shows, that the arc is broadly near (50km) reykjavik:
    assert_in_delta(50_000, distance, 50_000)
  end

  def test_floating_point_perturbation
    # A naive way of wrapping longitudes to [-180,180] might cause
    # perturbation due to floating point errors. Make sure this
    # doesn't happen.
    point = @factory.point(-98.747534, 38.057583)
    assert_equal(-98.747534, point.x)
  end

  undef_method :test_disjoint
  undef_method :test_intersects
  undef_method :test_touches
  undef_method :test_crosses
  undef_method :test_within
  undef_method :test_contains
  undef_method :test_overlaps
  undef_method :test_intersection
  undef_method :test_union
  undef_method :test_difference
  undef_method :test_sym_difference
  undef_method :test_point_on_surface
end
