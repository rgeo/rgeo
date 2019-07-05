# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Common tests for polygon implementations
#
# -----------------------------------------------------------------------------

module RGeo
  module Tests # :nodoc:
    module Common # :nodoc:
      module PolygonTests # :nodoc:
        def test_creation_simple
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          point3 = @factory.point(1, 0)
          exterior = @factory.linear_ring([point1, point2, point3, point1])
          polygon = @factory.polygon(exterior)
          assert(RGeo::Feature::Polygon === polygon)
          assert_equal(RGeo::Feature::Polygon, polygon.geometry_type)
          assert(exterior.eql?(polygon.exterior_ring))
          assert_equal(0, polygon.num_interior_rings)
          assert_nil(polygon.interior_ring_n(0))
          assert_nil(polygon.interior_ring_n(-1))
        end

        def test_creation_one_hole
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 10)
          point3 = @factory.point(10, 10)
          point4 = @factory.point(10, 0)
          point5 = @factory.point(4, 4)
          point6 = @factory.point(5, 6)
          point7 = @factory.point(6, 4)
          exterior = @factory.linear_ring([point1, point2, point3, point4, point1])
          interior = @factory.linear_ring([point5, point6, point7, point5])
          polygon = @factory.polygon(exterior, [interior])
          assert(RGeo::Feature::Polygon === polygon)
          assert_equal(RGeo::Feature::Polygon, polygon.geometry_type)
          assert(exterior.eql?(polygon.exterior_ring))
          assert_equal(1, polygon.num_interior_rings)
          assert(interior.eql?(polygon.interior_ring_n(0)))
          assert_nil(polygon.interior_ring_n(1))
          assert_nil(polygon.interior_ring_n(-1))
        end

        def test_required_equivalences
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          point3 = @factory.point(1, 0)
          exterior1 = @factory.linear_ring([point1, point2, point3, point1])
          poly1 = @factory.polygon(exterior1)
          point4 = @factory.point(0, 0)
          point5 = @factory.point(0, 1)
          point6 = @factory.point(1, 0)
          exterior2 = @factory.linear_ring([point4, point5, point6, point4])
          poly2 = @factory.polygon(exterior2)
          assert(poly1.eql?(poly2))
          assert(poly1 == poly2)
        end

        def test_fully_equal
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          point3 = @factory.point(1, 0)
          exterior1 = @factory.linear_ring([point1, point2, point3, point1])
          poly1 = @factory.polygon(exterior1)
          point4 = @factory.point(0, 0)
          point5 = @factory.point(0, 1)
          point6 = @factory.point(1, 0)
          exterior2 = @factory.linear_ring([point4, point5, point6, point4])
          poly2 = @factory.polygon(exterior2)
          assert(poly1.rep_equals?(poly2))
          assert(poly1.equals?(poly2))
        end

        def test_geometrically_equal_but_ordered_different
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          point3 = @factory.point(1, 0)
          exterior1 = @factory.linear_ring([point1, point2, point3, point1])
          poly1 = @factory.polygon(exterior1)
          exterior2 = @factory.linear_ring([point2, point3, point1, point2])
          poly2 = @factory.polygon(exterior2)
          assert(!poly1.rep_equals?(poly2))
          assert(poly1.equals?(poly2))
        end

        def test_geometrically_equal_but_different_directions
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          point3 = @factory.point(1, 0)
          exterior1 = @factory.linear_ring([point1, point2, point3, point1])
          poly1 = @factory.polygon(exterior1)
          exterior2 = @factory.linear_ring([point1, point3, point2, point1])
          poly2 = @factory.polygon(exterior2)
          assert(!poly1.rep_equals?(poly2))
          assert(poly1.equals?(poly2))
        end

        def test_hashes_equal_for_representationally_equivalent_objects
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          point3 = @factory.point(1, 0)
          exterior1 = @factory.linear_ring([point1, point2, point3, point1])
          poly1 = @factory.polygon(exterior1)
          point4 = @factory.point(0, 0)
          point5 = @factory.point(0, 1)
          point6 = @factory.point(1, 0)
          exterior2 = @factory.linear_ring([point4, point5, point6, point4])
          poly2 = @factory.polygon(exterior2)
          assert_equal(poly1.hash, poly2.hash)
        end

        def test_wkt_creation_simple
          parsed_poly = @factory.parse_wkt("POLYGON((0 0, 0 1, 1 0, 0 0))")
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          point3 = @factory.point(1, 0)
          exterior = @factory.linear_ring([point1, point2, point3, point1])
          built_poly = @factory.polygon(exterior)
          assert(built_poly.eql?(parsed_poly))
        end

        def test_wkt_creation_one_hole
          parsed_poly = @factory.parse_wkt("POLYGON((0 0, 0 10, 10 10, 10 0, 0 0), (4 4, 5 6, 6 4, 4 4))")
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 10)
          point3 = @factory.point(10, 10)
          point4 = @factory.point(10, 0)
          point5 = @factory.point(4, 4)
          point6 = @factory.point(5, 6)
          point7 = @factory.point(6, 4)
          exterior = @factory.linear_ring([point1, point2, point3, point4, point1])
          interior = @factory.linear_ring([point5, point6, point7, point5])
          built_poly = @factory.polygon(exterior, [interior])
          assert(built_poly.eql?(parsed_poly))
        end

        def test_clone
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          point3 = @factory.point(1, 0)
          exterior = @factory.linear_ring([point1, point2, point3, point1])
          poly1 = @factory.polygon(exterior)
          poly2 = poly1.clone
          assert(poly1.eql?(poly2))
          assert(exterior.eql?(poly2.exterior_ring))
          assert_equal(0, poly2.num_interior_rings)
        end

        def test_type_check
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          point3 = @factory.point(1, 0)
          exterior = @factory.linear_ring([point1, point2, point3, point1])
          poly = @factory.polygon(exterior)
          assert(RGeo::Feature::Geometry.check_type(poly))
          assert(!RGeo::Feature::Point.check_type(poly))
          assert(!RGeo::Feature::GeometryCollection.check_type(poly))
          assert(RGeo::Feature::Surface.check_type(poly))
          assert(RGeo::Feature::Polygon.check_type(poly))
        end

        def test_as_text_wkt_round_trip
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          point3 = @factory.point(1, 0)
          exterior = @factory.linear_ring([point1, point2, point3, point1])
          poly1 = @factory.polygon(exterior)
          text = poly1.as_text
          poly2 = @factory.parse_wkt(text)
          assert(poly1.eql?(poly2))
        end

        def test_as_binary_wkb_round_trip
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          point3 = @factory.point(1, 0)
          exterior = @factory.linear_ring([point1, point2, point3, point1])
          poly1 = @factory.polygon(exterior)
          binary = poly1.as_binary
          poly2 = @factory.parse_wkb(binary)
          assert(poly1.eql?(poly2))
        end

        def test_dimension
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 10)
          point3 = @factory.point(10, 10)
          point4 = @factory.point(10, 0)
          point5 = @factory.point(4, 4)
          point6 = @factory.point(5, 6)
          point7 = @factory.point(6, 4)
          exterior = @factory.linear_ring([point1, point2, point3, point4, point1])
          interior = @factory.linear_ring([point5, point6, point7, point5])
          poly = @factory.polygon(exterior, [interior])
          assert_equal(2, poly.dimension)
        end

        def test_is_empty
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          point3 = @factory.point(1, 0)
          exterior = @factory.linear_ring([point1, point2, point3, point1])
          poly1 = @factory.polygon(exterior)
          assert(!poly1.is_empty?)
          poly2 = @factory.polygon(@factory.linear_ring([]))
          assert(poly2.is_empty?)
        end

        def test_polygon_coordinates
          coordinates = [
            [[0.0, 0.0], [1.0, 0.0], [1.0, 1.0], [0.0, 1.0], [0.0, 0.0]],
            [[0.25, 0.25], [0.75, 0.25], [0.75, 0.75], [0.25, 0.75], [0.25, 0.25]]
          ]

          ring = @factory.line_string(coordinates.first.map { |(x, y)| @factory.point x, y })
          inner_ring = @factory.line_string(coordinates.last.map { |(x, y)| @factory.point x, y })
          polygon = @factory.polygon ring, [inner_ring]
          assert_equal(polygon.coordinates, coordinates)
        end

        def test_ignores_consecutive_repeated_points
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 0)
          point3 = @factory.point(0, 1)
          point4 = @factory.point(0, 1)
          point5 = @factory.point(0, 1)
          point6 = @factory.point(1, 0)
          point7 = @factory.point(1, 0)
          point8 = @factory.point(1, 0)
          exterior = @factory.linear_ring([point1, point2, point3, point4, point5, point6, point7, point8])

          poly1 = @factory.polygon(exterior)
          assert(!poly1.nil?)

          line_string = poly1.exterior_ring

          case line_string.class.name
          when "GeosPolygonTest"
          when "RGeo::Geos::FFILinearRingImpl"
          when "RGeo::Geos::CAPILinearRingImpl"
          when "GeosFFIPolygonTest"
            assert(line_string.points.count == 9)
          else
            assert(line_string.num_points == 4)
          end

          points = line_string.points
          assert(points.first.x == points.last.x)
          assert(points.first.y == points.last.y)
          assert(points.first.z == points.last.z)
        end

        def test_point_on_surface
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 10)
          point3 = @factory.point(10, 10)
          point4 = @factory.point(10, 0)
          exterior = @factory.linear_ring([point1, point2, point3, point4, point1])
          polygon = @factory.polygon(exterior)
          assert_equal(polygon.point_on_surface, @factory.point(5.0, 5.0))
        end
      end
    end
  end
end
