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
      end
    end
  end
end
