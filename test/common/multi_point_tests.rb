# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Common tests for multi point implementations
#
# -----------------------------------------------------------------------------

module RGeo
  module Tests # :nodoc:
    module Common # :nodoc:
      module MultiPointTests # :nodoc:
        def setup
          @factory = create_factory
          @point1 = @factory.point(0, 0)
          @point2 = @factory.point(1, 0)
          @point3 = @factory.point(-4, 2)
          @point4 = @factory.point(-5, 3)
          @point5 = @factory.point(-5, 3)
        end

        def test_creation_simple
          geom = @factory.multi_point([@point1, @point2])
          assert(RGeo::Feature::MultiPoint === geom)
          assert_equal(RGeo::Feature::MultiPoint, geom.geometry_type)
          assert_equal(2, geom.num_geometries)
          assert(@point1.eql?(geom[0]))
          assert(@point2.eql?(geom[1]))
        end

        def test_creation_empty
          geom = @factory.multi_point([])
          assert(RGeo::Feature::MultiPoint === geom)
          assert_equal(RGeo::Feature::MultiPoint, geom.geometry_type)
          assert_equal(0, geom.num_geometries)
          assert_equal([], geom.to_a)
        end

        def test_creation_casting
          mp1 = @factory.collection([@point3])
          mp2 = @factory.multi_point([@point4])
          geom = @factory.multi_point([@point1, @point2, mp1, mp2])
          assert(geom)
          assert_equal(RGeo::Feature::MultiPoint, geom.geometry_type)
          assert_equal(4, geom.num_geometries)
          assert(@point1.eql?(geom[0]))
          assert(@point2.eql?(geom[1]))
          assert(@point3.eql?(geom[2]))
          assert(@point4.eql?(geom[3]))
        end

        def test_creation_wrong_type
          line = @factory.line_string([@point1, @point2])
          assert_raises(RGeo::Error::InvalidGeometry) do
            @factory.multi_point([@point3, line])
          end
        end

        def test_required_equivalences
          geom1 = @factory.multi_point([@point1, @point2])
          geom2 = @factory.multi_point([@point1, @point2])
          assert(geom1.eql?(geom2))
          assert(geom1 == geom2)
        end

        def test_fully_equal
          geom1 = @factory.multi_point([@point1, @point2])
          geom2 = @factory.multi_point([@point1, @point2])
          assert(geom1.rep_equals?(geom2))
          assert(geom1.equals?(geom2))
        end

        def test_geometrically_equal
          geom1 = @factory.multi_point([@point1, @point4])
          geom2 = @factory.multi_point([@point1, @point4, @point5])
          assert(!geom1.rep_equals?(geom2))
          assert(geom1.equals?(geom2))
        end

        def test_not_equal
          geom1 = @factory.multi_point([@point1, @point2])
          geom2 = @factory.multi_point([@point1])
          assert(!geom1.rep_equals?(geom2))
          assert(!geom1.equals?(geom2))
        end

        def test_hashes_equal_for_representationally_equivalent_objects
          geom1 = @factory.multi_point([@point1, @point2])
          geom2 = @factory.multi_point([@point1, @point2])
          assert_equal(geom1.hash, geom2.hash)
        end

        def test_wkt_creation_simple
          parsed_geom = @factory.parse_wkt("MULTIPOINT((0 0), (-4 2), (-5 3))")
          built_geom = @factory.multi_point([@point1, @point3, @point4])
          assert(built_geom.eql?(parsed_geom))
        end

        def test_wkt_creation_empty
          parsed_geom = @factory.parse_wkt("MULTIPOINT EMPTY")
          assert(RGeo::Feature::MultiPoint === parsed_geom)
          assert_equal(0, parsed_geom.num_geometries)
          assert_equal([], parsed_geom.to_a)
        end

        def test_clone
          geom1 = @factory.multi_point([@point1, @point2])
          geom2 = geom1.clone
          assert(geom1.eql?(geom2))
          assert_equal(RGeo::Feature::MultiPoint, geom2.geometry_type)
          assert_equal(2, geom2.num_geometries)
          assert(@point1.eql?(geom2[0]))
          assert(@point2.eql?(geom2[1]))
        end

        def test_type_check
          geom1 = @factory.multi_point([@point1, @point2])
          assert(RGeo::Feature::Geometry.check_type(geom1))
          assert(!RGeo::Feature::Point.check_type(geom1))
          assert(RGeo::Feature::GeometryCollection.check_type(geom1))
          assert(RGeo::Feature::MultiPoint.check_type(geom1))
          assert(!RGeo::Feature::MultiLineString.check_type(geom1))
          geom2 = @factory.multi_point([])
          assert(RGeo::Feature::Geometry.check_type(geom2))
          assert(!RGeo::Feature::Point.check_type(geom2))
          assert(RGeo::Feature::GeometryCollection.check_type(geom2))
          assert(RGeo::Feature::MultiPoint.check_type(geom2))
          assert(!RGeo::Feature::MultiLineString.check_type(geom2))
        end

        def test_as_text_wkt_round_trip
          geom1 = @factory.multi_point([@point1, @point2])
          text = geom1.as_text
          geom2 = @factory.parse_wkt(text)
          assert(geom1.eql?(geom2))
        end

        def test_as_binary_wkb_round_trip
          geom1 = @factory.multi_point([@point1, @point2])
          binary = geom1.as_binary
          geom2 = @factory.parse_wkb(binary)
          assert(geom1.eql?(geom2))
        end

        def test_dimension
          geom1 = @factory.multi_point([@point1, @point2])
          assert_equal(0, geom1.dimension)
          geom2 = @factory.multi_point([])
          assert_equal(-1, geom2.dimension)
        end

        def test_is_empty
          geom1 = @factory.multi_point([@point1, @point2])
          assert(!geom1.is_empty?)
          geom2 = @factory.multi_point([])
          assert(geom2.is_empty?)
        end

        def test_union
          geom1 = @factory.multi_point([@point1, @point2])
          geom2 = @factory.multi_point([@point1, @point3])
          geom3 = @factory.multi_point([@point1, @point2, @point3])
          assert_equal(geom3, geom1.union(geom2))
          assert_equal(geom3, geom1 + geom2)
        end

        def test_difference
          geom1 = @factory.multi_point([@point1, @point2])
          geom2 = @factory.multi_point([@point1, @point3])
          assert_equal(@point2, geom1.difference(geom2))
          assert_equal(@point2, geom1 - geom2)
        end

        def test_intersection
          geom1 = @factory.multi_point([@point1, @point2])
          geom2 = @factory.multi_point([@point1, @point3])
          assert_equal(@point1, geom1.intersection(geom2))
          assert_equal(@point1, geom1 * geom2)
        end

        def test_zm
          factory = create_factory(has_z_coordinate: true, has_m_coordinate: true)
          p1 = factory.point(1, 2, 3, 4)
          mp = factory.multi_point([p1])
          assert_equal(p1, mp[0])
        end

        def test_coordinate
          p0 = @factory.point(0, 0)
          p1 = @factory.point(1, 1)
          p2 = @factory.point(2, 2)
          points = [p0, p1, p2]
          mp = @factory.multi_point(points)
          assert_equal(mp.coordinates, points.map(&:coordinates))
        end

        def test_point_on_surface
          geom = @factory.multi_point([@point1, @point2, @point3])
          assert_equal(geom.point_on_surface, @point1)
        end
      end
    end
  end
end
