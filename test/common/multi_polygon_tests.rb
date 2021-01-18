# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Common tests for multi polygon implementations
#
# -----------------------------------------------------------------------------

module RGeo
  module Tests # :nodoc:
    module Common # :nodoc:
      module MultiPolygonTests # :nodoc:
        def setup
          create_factories
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 10)
          point3 = @factory.point(10, 10)
          point4 = @factory.point(10, 0)
          point5 = @factory.point(4, 4)
          point6 = @factory.point(5, 6)
          point7 = @factory.point(6, 4)
          point8 = @factory.point(0, -10)
          point9 = @factory.point(-10, 0)
          exterior1_ = @factory.linear_ring([point1, point8, point9, point1])
          exterior2_ = @factory.linear_ring([point1, point2, point3, point4, point1])
          exterior3_ = @factory.linear_ring([point1, point2, point3, point1])
          exterior4_ = @factory.linear_ring([point1, point3, point4, point1])
          interior1_ = @factory.linear_ring([point5, point6, point7, point5])
          @poly1 = @factory.polygon(exterior1_)
          @poly2 = @factory.polygon(exterior2_, [interior1_])
          @poly3 = @factory.polygon(exterior3_)
          @poly4 = @factory.polygon(exterior4_)
          @line1 = interior1_
        end

        def test_creation_simple
          geom = @factory.multi_polygon([@poly1, @poly2])
          assert(RGeo::Feature::MultiPolygon === geom)
          assert_equal(RGeo::Feature::MultiPolygon, geom.geometry_type)
          assert_equal(2, geom.num_geometries)
          assert(@poly1.eql?(geom[0]))
          assert(@poly2.eql?(geom[1]))
        end

        def test_creation_empty
          geom = @factory.multi_polygon([])
          assert(RGeo::Feature::MultiPolygon === geom)
          assert_equal(RGeo::Feature::MultiPolygon, geom.geometry_type)
          assert_equal(0, geom.num_geometries)
          assert_equal([], geom.to_a)
        end

        def test_creation_wrong_type
          assert_raises(RGeo::Error::InvalidGeometry) do
            @factory.multi_polygon([@poly1, @line1])
          end
        end

        def test_creation_overlapping
          assert_raises(RGeo::Error::InvalidGeometry) do
            @factory.multi_polygon([@poly1, @poly1])
          end
          geom = @lenient_factory.multi_polygon([@poly1, @poly1])
          assert_equal RGeo::Feature::MultiPolygon, geom.geometry_type
        end

        def test_creation_connected
          assert_raises(RGeo::Error::InvalidGeometry) do
            @factory.multi_polygon([@poly3, @poly4])
          end
          geom = @lenient_factory.multi_polygon([@poly3, @poly4])
          assert_equal RGeo::Feature::MultiPolygon, geom.geometry_type
        end

        def test_required_equivalences
          geom1 = @factory.multi_polygon([@poly1, @poly2])
          geom2 = @factory.multi_polygon([@poly1, @poly2])
          assert(geom1.eql?(geom2))
          assert(geom1 == geom2)
        end

        def test_equal
          geom1 = @factory.multi_polygon([@poly1, @poly2])
          geom2 = @factory.multi_polygon([@poly1, @poly2])
          assert(geom1.rep_equals?(geom2))
          assert(geom1.equals?(geom2))
        end

        def test_not_equal
          geom1 = @factory.multi_polygon([@poly1])
          geom2 = @factory.multi_polygon([@poly2])
          assert(!geom1.rep_equals?(geom2))
          assert(!geom1.equals?(geom2))
        end

        def test_hashes_equal_for_representationally_equivalent_objects
          geom1 = @factory.multi_polygon([@poly1, @poly2])
          geom2 = @factory.multi_polygon([@poly1, @poly2])
          assert_equal(geom1.hash, geom2.hash)
        end

        def test_wkt_creation_simple
          parsed_geom = @factory.parse_wkt("MULTIPOLYGON(((0 0, 0 -10, -10 0, 0 0)), ((0 0, 0 10, 10 10, 10 0, 0 0), (4 4, 5 6, 6 4, 4 4)))")
          built_geom = @factory.multi_polygon([@poly1, @poly2])
          assert(built_geom.eql?(parsed_geom))
        end

        def test_wkt_creation_empty
          parsed_geom = @factory.parse_wkt("MULTIPOLYGON EMPTY")
          assert_equal(RGeo::Feature::MultiPolygon, parsed_geom.geometry_type)
          assert_equal(0, parsed_geom.num_geometries)
          assert_equal([], parsed_geom.to_a)
        end

        def test_clone
          geom1 = @factory.multi_polygon([@poly1, @poly2])
          geom2 = geom1.clone
          assert(geom1.eql?(geom2))
          assert_equal(RGeo::Feature::MultiPolygon, geom2.geometry_type)
          assert_equal(2, geom2.num_geometries)
          assert(@poly1.eql?(geom2[0]))
          assert(@poly2.eql?(geom2[1]))
        end

        def test_type_check
          geom1 = @factory.multi_polygon([@poly1, @poly2])
          assert(RGeo::Feature::Geometry.check_type(geom1))
          assert(!RGeo::Feature::Polygon.check_type(geom1))
          assert(RGeo::Feature::GeometryCollection.check_type(geom1))
          assert(!RGeo::Feature::MultiPoint.check_type(geom1))
          assert(RGeo::Feature::MultiPolygon.check_type(geom1))
          geom2 = @factory.multi_polygon([])
          assert(RGeo::Feature::Geometry.check_type(geom2))
          assert(!RGeo::Feature::Polygon.check_type(geom2))
          assert(RGeo::Feature::GeometryCollection.check_type(geom2))
          assert(!RGeo::Feature::MultiPoint.check_type(geom2))
          assert(RGeo::Feature::MultiPolygon.check_type(geom2))
        end

        def test_as_textwkt_round_trip
          geom1 = @factory.multi_polygon([@poly1, @poly2])
          text = geom1.as_text
          geom2 = @factory.parse_wkt(text)
          assert(geom1.eql?(geom2))
        end

        def test_as_binary_wkb_round_trip
          geom1 = @factory.multi_polygon([@poly1, @poly2])
          binary_ = geom1.as_binary
          geom2 = @factory.parse_wkb(binary_)
          assert(geom1.eql?(geom2))
        end

        def test_dimension
          geom1 = @factory.multi_polygon([@poly1, @poly2])
          assert_equal(2, geom1.dimension)
          geom2 = @factory.multi_polygon([])
          assert_equal(-1, geom2.dimension)
        end

        def test_is_empty
          geom1 = @factory.multi_polygon([@poly1, @poly2])
          assert(!geom1.is_empty?)
          geom2 = @factory.multi_polygon([])
          assert(geom2.is_empty?)
        end

        def test_multi_polygon_coordinates
          poly1_coordinates = [
            [[0.0, 0.0], [1.0, 0.0], [1.0, 1.0], [0.0, 1.0], [0.0, 0.0]],
            [[0.25, 0.25], [0.75, 0.25], [0.75, 0.75], [0.25, 0.75], [0.25, 0.25]]
          ]
          poly2_coordinates = [
            [[2.0, 2.0], [3.0, 2.0], [3.0, 3.0], [2.0, 3.0], [2.0, 2.0]],
            [[2.25, 2.25], [2.75, 2.25], [2.75, 2.75], [2.25, 2.75], [2.25, 2.25]]
          ]

          ring = @factory.line_string(poly1_coordinates.first.map { |(x, y)| @factory.point x, y })
          inner_ring = @factory.line_string(poly1_coordinates.last.map { |(x, y)| @factory.point x, y })
          poly1 = @factory.polygon ring, [inner_ring]

          ring = @factory.line_string(poly2_coordinates.first.map { |(x, y)| @factory.point x, y })
          inner_ring = @factory.line_string(poly2_coordinates.last.map { |(x, y)| @factory.point x, y })
          poly2 = @factory.polygon ring, [inner_ring]

          multi_polygon = @factory.multi_polygon [poly1, poly2]
          assert_equal(multi_polygon.coordinates, [poly1_coordinates, poly2_coordinates])
        end

        def test_point_on_surface
          assert_equal(@poly4.point_on_surface, @factory.point(7.5, 5.0))
        end

        def test_boundary
          parsed_geom = @factory.parse_wkt("MULTILINESTRING ((0.0 0.0, 0.0 -10.0, -10.0 0.0, 0.0 0.0), (0.0 0.0, 0.0 10.0, 10.0 10.0, 10.0 0.0, 0.0 0.0), (4.0 4.0, 5.0 6.0, 6.0 4.0, 4.0 4.0))")
          built_geom = @factory.multi_polygon([@poly1, @poly2])
          boundary_geom = built_geom.boundary
          parsed_coordinates = parsed_geom.coordinates
          boundary_coordinates = boundary_geom.coordinates
          parsed_coordinates.zip(boundary_coordinates).each do |parsed_line, boundary_line|
            parsed_line.zip(boundary_line).each do |p_coord, b_coord|
              p_coord.zip(b_coord).each do |p_val, b_val|
                assert_in_delta(p_val, b_val, 1e-13)
              end
            end
          end
        end

        def test_contains_point
          geom1 = @factory.multi_polygon([@poly1, @poly2])

          assert_equal(true, geom1.contains?(@factory.point(9, 9)))
          assert_equal(false, geom1.contains?(@factory.point(6, 4)))
          assert_equal(false, geom1.contains?(@factory.point(11, 11)))
        end

        def test_triangle_contains_point
          point1 = @factory.point(4, 4)
          point2 = @factory.point(5, 6)
          point3 = @factory.point(6, 4)
          line_string1 = @factory.line_string([point1, point2, point3, point1])
          poly1 = @factory.polygon(line_string1)
          point4 = @factory.point(14, 14)
          point5 = @factory.point(15, 16)
          point6 = @factory.point(16, 14)
          line_string2 = @factory.linear_ring([point4, point5, point6, point4])
          poly2 = @factory.polygon(line_string2)
          multi_polygon = @factory.multi_polygon([poly1, poly2])
          assert_equal(true, multi_polygon.contains?(@factory.point(5, 5)))
          assert_equal(true, multi_polygon.contains?(@factory.point(15, 15)))
          assert_equal(false, multi_polygon.contains?(@factory.point(0, 0)))
        end

        def test_one_hole_contains_point
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 10)
          point3 = @factory.point(10, 10)
          point4 = @factory.point(10, 0)
          point5 = @factory.point(4, 4)
          point6 = @factory.point(5, 6)
          point7 = @factory.point(6, 4)
          exterior1 = @factory.linear_ring([point1, point2, point3, point4, point1])
          interior1 = @factory.linear_ring([point5, point6, point7, point5])
          poly1 = @factory.polygon(exterior1, [interior1])
          point8 = @factory.point(50, 50)
          point9 = @factory.point(50, 60)
          point10 = @factory.point(60, 60)
          point11 = @factory.point(60, 50)
          point12 = @factory.point(54, 54)
          point13 = @factory.point(55, 56)
          point14 = @factory.point(56, 54)
          exterior2 = @factory.linear_ring([point8, point9, point10, point11, point8])
          interior2 = @factory.linear_ring([point12, point13, point14, point12])
          poly2 = @factory.polygon(exterior2, [interior2])
          multi_polygon = @factory.multi_polygon([poly1, poly2])
          assert_equal(true, multi_polygon.contains?(@factory.point(2, 3)))
          assert_equal(false, multi_polygon.contains?(@factory.point(5, 5)))
          assert_equal(false, multi_polygon.contains?(@factory.point(4, 4)))
          assert_equal(true, multi_polygon.contains?(@factory.point(52, 53)))
          assert_equal(false, multi_polygon.contains?(@factory.point(55, 55)))
          assert_equal(false, multi_polygon.contains?(@factory.point(54, 54)))
        end
      end
    end
  end
end
