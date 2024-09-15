# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the internal calculations for simple spherical
#
# -----------------------------------------------------------------------------

require "test_helper"

class SphericalCalculationsTest < Minitest::Test # :nodoc:
  def assert_close_enough(val1, val2)
    diff = (val1 - val2).abs
    # denom = (v1 + v2).abs
    # diff /= denom if denom > 0.01
    assert(diff < 0.00000001, "#{val1} is not close to #{val2}")
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

  def test_arc_project_point_on_great_circle
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(0, 1, 0)

    # Point on the x-y plane, within the circle defined by the arc
    point3 = RGeo::Geographic::SphericalMath::PointXYZ.new(0.5, 0.5, 0)

    arc = RGeo::Geographic::SphericalMath::ArcXYZ.new(point1, point2)
    projected_point = arc.project_point(point3)

    # Projected point should lie on the great circle defined by the arc
    # Since arc is on the x-y plane, the z-coordinate of the projected point should be close to 0.
    assert_in_delta(projected_point.z, 0.0, 1E-8)

    # Check if the projected point lies on the arc.
    # Since we're projecting from the z-axis, the result should be on the arc.
    # For arc from (1,0,0) to (0,1,0), we expect a point on this circle, i.e., x^2 + y^2 = 1
    # Projected point should lie on the circle defined by the arc
    assert_in_delta(projected_point.x**2 + projected_point.y**2, 1.0, 1E-8)
  end

  def test_arc_project_point_on_arc
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(0, 1, 0)
    point3 = RGeo::Geographic::SphericalMath::PointXYZ.new(0.5, 0.5, Math.sqrt(0.5)) # Point near the plane of the arc
    arc = RGeo::Geographic::SphericalMath::ArcXYZ.new(point1, point2)
    projected_point = arc.project_point(point3)

    # Closest point should be on the arc's great circle plane and normalized
    assert_in_delta(Math.sqrt(projected_point.x**2 + projected_point.y**2 + projected_point.z**2), 1.0, 1E-8)

    # Since point1 and point2 define a great circle in the xy-plane, z should be 0 for the closest point
    assert_in_delta(projected_point.z, 0.0, 1E-8)
  end

  def test_arc_project_point_outside_arc
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)  # Point on x-axis
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(0, 1, 0)  # Point on y-axis

    # Choose a point that projects outside of the arc segment
    point3 = RGeo::Geographic::SphericalMath::PointXYZ.new(-0.5, -0.5, Math.sqrt(0.5)) # Point near the plane of the arc

    arc = RGeo::Geographic::SphericalMath::ArcXYZ.new(point1, point2)
    projected_point = arc.project_point(point3)

    # Check if the projected point lies on the great circle plane
    assert_in_delta(projected_point.z, 0.0, 1E-8)

    # Ensure the projected point is on the great circle defined by the arc
    assert_in_delta(Math.sqrt(projected_point.x**2 + projected_point.y**2 + projected_point.z**2), 1.0, 1E-8)

    # Check if the projected point is within the bounds of the arc
    refute(arc.contains_point?(projected_point), "Projected point should not be within the arc segment")
  end

  def test_arc_closest_point_on_arc
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(0, 1, 0)
    point3 = RGeo::Geographic::SphericalMath::PointXYZ.new(0.5, 0.5, Math.sqrt(0.5)) # Point near the plane of the arc
    arc = RGeo::Geographic::SphericalMath::ArcXYZ.new(point1, point2)
    closest_point = arc.closest_point(point3)

    # Closest point should be on the arc's great circle plane and normalized
    assert_in_delta(Math.sqrt(closest_point.x**2 + closest_point.y**2 + closest_point.z**2), 1.0, 1E-8)

    # Since point1 and point2 define a great circle in the xy-plane, z should be 0 for the closest point
    assert_in_delta(closest_point.z, 0.0, 1E-8)
    assert(arc.contains_point?(closest_point))
  end

  def test_arc_closest_point_outside_arc
    point1 = RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)  # Point on x-axis
    point2 = RGeo::Geographic::SphericalMath::PointXYZ.new(0, 1, 0)  # Point on y-axis

    # Choose a point that closests outside of the arc segment
    point3 = RGeo::Geographic::SphericalMath::PointXYZ.new(1.0, -0.5, 0) # Point near the plane of the arc

    arc = RGeo::Geographic::SphericalMath::ArcXYZ.new(point1, point2)
    closest_point = arc.closest_point(point3)

    # Since the projected point is outside the arc, it shoudl return the closer end of the arc
    assert_equal(closest_point, point1)
  end

end
