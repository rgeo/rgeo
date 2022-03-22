# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS polygon implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class GeosFFIPolygonTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::PolygonTests

  def setup
    @factory = RGeo::Geos.factory(native_interface: :ffi)
  end

  def test_intersection
    point1 = @factory.point(0, 0)
    point2 = @factory.point(0, 2)
    point3 = @factory.point(2, 2)
    point4 = @factory.point(2, 0)
    poly1 = @factory.polygon(@factory.linear_ring([point1, point2, point3, point4]))
    poly2 = @factory.polygon(@factory.linear_ring([point1, point2, point4]))
    poly3 = poly1.intersection(poly2)
    assert_equal(poly2, poly3)
  end

  def test_union
    point1 = @factory.point(0, 0)
    point2 = @factory.point(0, 2)
    point3 = @factory.point(2, 2)
    point4 = @factory.point(2, 0)
    poly1 = @factory.polygon(@factory.linear_ring([point1, point2, point3, point4]))
    poly2 = @factory.polygon(@factory.linear_ring([point1, point2, point4]))
    poly3 = poly1.union(poly2)
    assert_equal(poly1, poly3)
  end

  def test_is_valid_polygon
    polygon_coordinates = [[0, 0], [0, 5], [5, 5], [5, 0], [0, 0]]
    points_arr = polygon_coordinates.map { |v| @factory.point(v[0], v[1]) }
    outer_ring = @factory.linear_ring(points_arr)
    polygon = @factory.polygon(outer_ring)

    assert_equal(polygon.valid?, true)

    polygon_coordinates = [[-1, -1], [-1, 0], [1, 0], [1, 1], [0, 1], [0, -1], [-1, -1]]
    points_arr = polygon_coordinates.map { |v| @factory.point(v[0], v[1]) }
    outer_ring = @factory.linear_ring(points_arr)
    polygon = @factory.polygon(outer_ring)

    assert_equal(polygon.valid?, false)
  end
end if RGeo::Geos.ffi_supported?
