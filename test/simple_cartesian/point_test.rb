# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the simple cartesian point implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class CartesianPointTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::PointTests

  def setup
    @factory = RGeo::Cartesian.simple_factory(srid: 1, buffer_resolution: 8)
    @zfactory = RGeo::Cartesian.simple_factory(srid: 1, has_z_coordinate: true)
    @mfactory = RGeo::Cartesian.simple_factory(srid: 1, has_m_coordinate: true)
    @zmfactory = RGeo::Cartesian.simple_factory(srid: 1, has_z_coordinate: true, has_m_coordinate: true)
  end

  def test_srid
    point = @factory.point(11, 12)
    assert_equal(1, point.srid)
  end

  def test_distance
    point1 = @factory.point(2, 2)
    point2 = @factory.point(7, 14)
    assert_in_delta(13, point1.distance(point2), 0.0001)
  end

  def test_lon_180
    factory = RGeo::Geographic.simple_mercator_factory
    points = [
      [48.02006, -179.47466],
      [48.00986, -179.7496],
      [48.00000, 180.0]
    ].map { |coord| factory.point(coord[1], coord[0]) }

    assert_equal "LINESTRING (-179.47466 48.02006, -179.7496 48.00986, 180.0 48.0)",
      factory.line_string(points).to_s
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
