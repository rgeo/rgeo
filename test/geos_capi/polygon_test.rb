# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS polygon implementation
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"

if RGeo::Geos.capi_supported?
  class GeosPolygonTest < Minitest::Test # :nodoc:
    include RGeo::Tests::Common::PolygonTests

    def assert_close_enough(pt1, pt2)
      assert((pt1.x - pt2.x).abs < 0.00000001 && (pt1.y - pt2.y).abs < 0.00000001)
    end

    def setup
      @factory = RGeo::Geos.factory
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

    def test_simplify
      xys = [[0, 0], [5, 0], [10, 0], [10, 10], [5, 10.2], [0, 10], [0, 0]]
      points = xys.collect { |x, y| @factory.point(x, y) }
      poly = @factory.polygon(@factory.linear_ring(points))
      simplified = poly.simplify(0.3)
      new_points = simplified.exterior_ring.points
      extra = new_points.reject { |p| [0, 10].include?(p.x) && [0, 10].include?(p.y) }
      assert_equal 5, new_points.length, "Closed ring of the square should have 5 points"
      assert_equal 0, extra.length, "Should only have x/y's on 0 and 10"
    end

    def test_buffer
      polygon_coordinates = [[0.5527864045000421, 3.776393202250021],
                             [0.7763932022500211, 4.447213595499958],
                             [1.4472135954999579, 4.223606797749979],
                             [2.447213595499958, 2.223606797749979],
                             [2.223606797749979, 1.5527864045000421],
                             [1.5527864045000421, 1.776393202250021],
                             [0.5527864045000421, 3.776393202250021]]

      points_arr = polygon_coordinates.map { |v| @factory.point(v[0], v[1]) }
      outer_ring = @factory.linear_ring(points_arr)
      polygon = @factory.polygon(outer_ring)

      point1 = @factory.point(2, 2)
      point2 = @factory.point(1, 4)
      line_string = @factory.line_string([point1, point2])
      polygon2 = line_string.buffer(0.5)

      assert_equal polygon, polygon2
    end

    def test_simplify_preserve_topology
      xys1 = [[0.0, 0.0], [5.0, 0.0], [10.0, 0.0], [10.0, 10.0], [5.0, 12.0], [0.0, 10.0], [0.0, 0.0]]
      xys2 = [[0.1, 0.1], [0.1, 0.6], [0.3, 0.8],  [0.5, 0.5],   [0.7, 0.3],  [0.3, 0.1],  [0.1, 0.1]]

      points1 = xys1.collect { |x, y| @factory.point(x, y) }
      points2 = xys2.collect { |x, y| @factory.point(x, y) }

      ln1 = @factory.line_string(points1)
      ln2 = @factory.line_string(points2)

      poly = @factory.polygon(ln1, [ln2])

      simplified = poly.simplify_preserve_topology(1)
      interior_points = simplified.interior_rings[0].points

      assert_equal 5, interior_points.length
    end

    def test_buffer_with_style
      polygon_coordinates = [[0.514589803375032, 4.299999999999999],
                             [6.0, 4.3],
                             [6.3, 4.3],
                             [6.3, 3.7],
                             [1.4854101966249682, 3.7],
                             [2.2683281572999747, 2.134164078649987],
                             [2.4024922359499623, 1.8658359213500124],
                             [1.8658359213500126, 1.597507764050038],
                             [0.514589803375032, 4.299999999999999]]

      points_arr = polygon_coordinates.map { |v| @factory.point(v[0], v[1]) }
      outer_ring = @factory.linear_ring(points_arr)
      polygon = @factory.polygon(outer_ring)

      point1 = @factory.point(2, 2)
      point2 = @factory.point(1, 4)
      point3 = @factory.point(6, 4)
      line_string = @factory.line_string([point1, point2, point3])
      buffered_line_string =
        line_string.buffer_with_style(0.3, RGeo::Geos::CAP_SQUARE, RGeo::Geos::JOIN_MITRE, 5)

      # having issues with floating point errors on some systems
      # 4.3 -> 4.29999999999999, for example, and throws an error
      # iterating through points and using assert_in_delta instead
      # of assert_equal
      buffered_points = buffered_line_string.exterior_ring.points
      polygon.exterior_ring.points.each_with_index do |pt, idx|
        assert_close_enough(pt, buffered_points[idx])
      end
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

    def test_invalid_reason
      polygon_coordinates = [[-1, -1], [-1, 0], [1, 0], [1, 1], [0, 1], [0, -1], [-1, -1]]
      points_arr = polygon_coordinates.map { |v| @factory.point(v[0], v[1]) }
      outer_ring = @factory.linear_ring(points_arr)
      polygon = @factory.polygon(outer_ring)

      assert_equal("Self-intersection", polygon.invalid_reason)
    end

    def test_invalid_reason_with_valid_polygon
      polygon_coordinates = [[0, 0], [0, 5], [5, 5], [5, 0], [0, 0]]
      points_arr = polygon_coordinates.map { |v| @factory.point(v[0], v[1]) }
      outer_ring = @factory.linear_ring(points_arr)
      polygon = @factory.polygon(outer_ring)
      assert_nil(polygon.invalid_reason)
    end

    def test_self_intersecting_polygon
      # issue 218
      polygon_coordinates = [[0, 0], [1, 1], [0, 1], [1, 0], [0, 0]]
      points_arr = polygon_coordinates.map { |v| @factory.point(v[0], v[1]) }
      outer_ring = @factory.linear_ring(points_arr)
      polygon = @factory.polygon(outer_ring)

      refute(polygon.simple?)
    end

    def test_polygonize
      input = @factory.parse_wkt("POLYGON ((0 0, 1 1, 1 0, 0 0))")
      expected = @factory.parse_wkt("GEOMETRYCOLLECTION (POLYGON ((0 0, 1 1, 1 0, 0 0)))")

      assert_equal expected, input.polygonize
    end
  end
end
