# -----------------------------------------------------------------------------
#
# Common tests for multi polygon implementations
#
# -----------------------------------------------------------------------------

require "rgeo"

module RGeo
  module Tests # :nodoc:
    module Common # :nodoc:
      module MultiPolygonTests # :nodoc:
        def setup
          create_factories
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 10)
          point3_ = @factory.point(10, 10)
          point4_ = @factory.point(10, 0)
          point5_ = @factory.point(4, 4)
          point6_ = @factory.point(5, 6)
          point7_ = @factory.point(6, 4)
          point8_ = @factory.point(0, -10)
          point9_ = @factory.point(-10, 0)
          exterior1_ = @factory.linear_ring([point1_, point8_, point9_, point1_])
          exterior2_ = @factory.linear_ring([point1_, point2_, point3_, point4_, point1_])
          exterior3_ = @factory.linear_ring([point1_, point2_, point3_, point1_])
          exterior4_ = @factory.linear_ring([point1_, point3_, point4_, point1_])
          interior1_ = @factory.linear_ring([point5_, point6_, point7_, point5_])
          @poly1 = @factory.polygon(exterior1_)
          @poly2 = @factory.polygon(exterior2_, [interior1_])
          @poly3 = @factory.polygon(exterior3_)
          @poly4 = @factory.polygon(exterior4_)
          @line1 = interior1_
        end

        def test_creation_simple
          geom_ = @factory.multi_polygon([@poly1, @poly2])
          assert_not_nil(geom_)
          assert(::RGeo::Feature::MultiPolygon === geom_)
          assert_equal(::RGeo::Feature::MultiPolygon, geom_.geometry_type)
          assert_equal(2, geom_.num_geometries)
          assert(@poly1.eql?(geom_[0]))
          assert(@poly2.eql?(geom_[1]))
        end

        def test_creation_empty
          geom_ = @factory.multi_polygon([])
          assert_not_nil(geom_)
          assert(::RGeo::Feature::MultiPolygon === geom_)
          assert_equal(::RGeo::Feature::MultiPolygon, geom_.geometry_type)
          assert_equal(0, geom_.num_geometries)
          assert_equal([], geom_.to_a)
        end

        def test_creation_wrong_type
          geom_ = @factory.multi_polygon([@poly1, @line1])
          assert_nil(geom_)
        end

        def test_creation_overlapping
          geom_ = @factory.multi_polygon([@poly1, @poly1])
          assert_nil(geom_)
          geom2_ = @lenient_factory.multi_polygon([@poly1, @poly1])
          assert_not_nil(geom2_)
        end

        def test_creation_connected
          geom_ = @factory.multi_polygon([@poly3, @poly4])
          assert_nil(geom_)
          geom2_ = @lenient_factory.multi_polygon([@poly3, @poly4])
          assert_not_nil(geom2_)
        end

        def test_required_equivalences
          geom1_ = @factory.multi_polygon([@poly1, @poly2])
          geom2_ = @factory.multi_polygon([@poly1, @poly2])
          assert(geom1_.eql?(geom2_))
          assert(geom1_ == geom2_)
        end

        def test_equal
          geom1_ = @factory.multi_polygon([@poly1, @poly2])
          geom2_ = @factory.multi_polygon([@poly1, @poly2])
          assert(geom1_.rep_equals?(geom2_))
          assert(geom1_.equals?(geom2_))
        end

        def test_not_equal
          geom1_ = @factory.multi_polygon([@poly1])
          geom2_ = @factory.multi_polygon([@poly2])
          assert(!geom1_.rep_equals?(geom2_))
          assert(!geom1_.equals?(geom2_))
        end

        def test_hashes_equal_for_representationally_equivalent_objects
          geom1_ = @factory.multi_polygon([@poly1, @poly2])
          geom2_ = @factory.multi_polygon([@poly1, @poly2])
          assert_equal(geom1_.hash, geom2_.hash)
        end

        def test_wkt_creation_simple
          parsed_geom_ = @factory.parse_wkt("MULTIPOLYGON(((0 0, 0 -10, -10 0, 0 0)), ((0 0, 0 10, 10 10, 10 0, 0 0), (4 4, 5 6, 6 4, 4 4)))")
          built_geom_ = @factory.multi_polygon([@poly1, @poly2])
          assert(built_geom_.eql?(parsed_geom_))
        end

        def test_wkt_creation_empty
          parsed_geom_ = @factory.parse_wkt("MULTIPOLYGON EMPTY")
          assert_equal(::RGeo::Feature::MultiPolygon, parsed_geom_.geometry_type)
          assert_equal(0, parsed_geom_.num_geometries)
          assert_equal([], parsed_geom_.to_a)
        end

        def test_clone
          geom1_ = @factory.multi_polygon([@poly1, @poly2])
          geom2_ = geom1_.clone
          assert(geom1_.eql?(geom2_))
          assert_equal(::RGeo::Feature::MultiPolygon, geom2_.geometry_type)
          assert_equal(2, geom2_.num_geometries)
          assert(@poly1.eql?(geom2_[0]))
          assert(@poly2.eql?(geom2_[1]))
        end

        def test_type_check
          geom1_ = @factory.multi_polygon([@poly1, @poly2])
          assert(::RGeo::Feature::Geometry.check_type(geom1_))
          assert(!::RGeo::Feature::Polygon.check_type(geom1_))
          assert(::RGeo::Feature::GeometryCollection.check_type(geom1_))
          assert(!::RGeo::Feature::MultiPoint.check_type(geom1_))
          assert(::RGeo::Feature::MultiPolygon.check_type(geom1_))
          geom2_ = @factory.multi_polygon([])
          assert(::RGeo::Feature::Geometry.check_type(geom2_))
          assert(!::RGeo::Feature::Polygon.check_type(geom2_))
          assert(::RGeo::Feature::GeometryCollection.check_type(geom2_))
          assert(!::RGeo::Feature::MultiPoint.check_type(geom2_))
          assert(::RGeo::Feature::MultiPolygon.check_type(geom2_))
        end

        def test_as_text_wkt_round_trip
          geom1_ = @factory.multi_polygon([@poly1, @poly2])
          text_ = geom1_.as_text
          geom2_ = @factory.parse_wkt(text_)
          assert(geom1_.eql?(geom2_))
        end

        def test_as_binary_wkb_round_trip
          geom1_ = @factory.multi_polygon([@poly1, @poly2])
          binary_ = geom1_.as_binary
          geom2_ = @factory.parse_wkb(binary_)
          assert(geom1_.eql?(geom2_))
        end

        def test_dimension
          geom1_ = @factory.multi_polygon([@poly1, @poly2])
          assert_equal(2, geom1_.dimension)
          geom2_ = @factory.multi_polygon([])
          assert_equal(-1, geom2_.dimension)
        end

        def test_is_empty
          geom1_ = @factory.multi_polygon([@poly1, @poly2])
          assert(!geom1_.is_empty?)
          geom2_ = @factory.multi_polygon([])
          assert(geom2_.is_empty?)
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
      end
    end
  end
end
