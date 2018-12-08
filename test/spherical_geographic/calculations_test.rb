# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the internal calculations for simple spherical
#
# -----------------------------------------------------------------------------

require "test_helper"

class SphericalCalculationsTest < Minitest::Test # :nodoc:
  def assert_close_enough(v1, v2)
    diff = (v1 - v2).abs
    # denom = (v1 + v2).abs
    # diff /= denom if denom > 0.01
    assert(diff < 0.00000001, "#{v1} is not close to #{v2}")
  end

  def test_point_eql
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
    assert_equal(point1, point2)
  end

  def test_point_from_latlng
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.from_latlon(45, -45)
    assert_close_enough(0.5, point1.x)
    assert_close_enough(-0.5, point1.y)
    assert_close_enough(Math.sqrt(2) * 0.5, point1.z)
  end

  def test_point_dot_one
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 1, 1)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 1, 1)
    assert_close_enough(1.0, point1 * point2)
  end

  def test_point_dot_minusone
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 1, 1)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(-1, -1, -1)
    assert_close_enough(-1.0, point1 * point2)
  end

  def test_point_dot_zero
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 1, 0)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, -1, 0)
    assert_close_enough(0.0, point1 * point2)
  end

  def test_point_cross
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 1, 0)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, -1, 0)
    assert_close_enough(-1.0, (point1 % point2).z)
  end

  def test_point_cross_coincident
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
    assert_nil(point1 % point2)
  end

  def test_point_cross_opposite
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(-1, 0, 0)
    assert_nil(point1 % point2)
  end

  def test_distance_coincident
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
    assert_equal(0.0, point1.dist_to_point(point2))
  end

  def test_distance_opposite
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(-1, 0, 0)
    assert_close_enough(Math::PI, point1.dist_to_point(point2))
  end

  def test_distance_right_angle
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(0, -1, 0)
    assert_close_enough(Math::PI / 2, point1.dist_to_point(point2))
  end

  def test_arc_axis
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 1, 0)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, -1, 0)
    arc1 = RGeo::Geographic::SphericalMath::ArcXYZ.new(point1, point2)
    assert_close_enough(-1.0, arc1.axis.z)
  end

  def test_arc_axis2
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0.000001, 0)
    arc1 = RGeo::Geographic::SphericalMath::ArcXYZ.new(point1, point2)
    assert_close_enough(1.0, arc1.axis.z)
  end

  def test_arc_intersects_point_off
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0.000002, 0)
    point3 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0.000001, 0.1)
    arc1 = RGeo::Geographic::SphericalMath::ArcXYZ.new(point1, point2)
    assert_equal(false, arc1.contains_point?(point3))
  end

  def test_arc_intersects_point_between
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0.000002, 0)
    point3 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0.000001, 0)
    arc1 = RGeo::Geographic::SphericalMath::ArcXYZ.new(point1, point2)
    assert_equal(true, arc1.contains_point?(point3))
  end

  def test_arc_intersects_point_endpoint
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0.000002, 0)
    arc1 = RGeo::Geographic::SphericalMath::ArcXYZ.new(point1, point2)
    assert_equal(true, arc1.contains_point?(point1))
  end

  def test_arc_intersects_arc_true
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(0, 0.1, 1)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(0, -0.1, 1)
    point3 = RGeo::Geographic::SphericalMath::PointXYZ.new(-0.1, 0, 1)
    point4 = RGeo::Geographic::SphericalMath::PointXYZ.new(0.1, 0, 1)
    arc1 = RGeo::Geographic::SphericalMath::ArcXYZ.new(point1, point2)
    arc2 = RGeo::Geographic::SphericalMath::ArcXYZ.new(point3, point4)
    assert_equal(true, arc1.intersects_arc?(arc2))
  end

  def test_arc_intersects_arc_parallel
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(0, 0.1, 1)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(0, -0.1, 1)
    point3 = RGeo::Geographic::SphericalMath::PointXYZ.new(0.1, 0.1, 1)
    point4 = RGeo::Geographic::SphericalMath::PointXYZ.new(0.1, -0.1, 1)
    arc1 = RGeo::Geographic::SphericalMath::ArcXYZ.new(point1, point2)
    arc2 = RGeo::Geographic::SphericalMath::ArcXYZ.new(point3, point4)
    assert_equal(false, arc1.intersects_arc?(arc2))
  end

  def test_arc_intersects_arc_separated_tee
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(0, 0.1, 1)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(0, -0.1, 1)
    point3 = RGeo::Geographic::SphericalMath::PointXYZ.new(0.1, 0, 1)
    point4 = RGeo::Geographic::SphericalMath::PointXYZ.new(0.2, 0, 1)
    arc1 = RGeo::Geographic::SphericalMath::ArcXYZ.new(point1, point2)
    arc2 = RGeo::Geographic::SphericalMath::ArcXYZ.new(point3, point4)
    assert_equal(false, arc1.intersects_arc?(arc2))
  end

  def test_arc_intersects_arc_connected_tee
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(0, 0.1, 1)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(0, -0.1, 1)
    point3 = RGeo::Geographic::SphericalMath::PointXYZ.new(0, 0, 1)
    point4 = RGeo::Geographic::SphericalMath::PointXYZ.new(0.1, 0, 1)
    arc1 = RGeo::Geographic::SphericalMath::ArcXYZ.new(point1, point2)
    arc2 = RGeo::Geographic::SphericalMath::ArcXYZ.new(point3, point4)
    assert_equal(true, arc1.intersects_arc?(arc2))
  end
end
