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

  def test_distance
    point1 = @factory.point(0, 10)
    point2 = @factory.point(0, 10)
    point3 = @factory.point(0, 40)
    assert_in_delta(0, point1.distance(point2), 0.0001)
    assert_in_delta(Math::PI / 6.0 * RGeo::Geographic::SphericalMath::RADIUS, point1.distance(point3), 0.0001)
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
