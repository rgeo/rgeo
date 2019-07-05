# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Common tests for multi line string implementations
#
# -----------------------------------------------------------------------------

module RGeo
  module Tests # :nodoc:
    module Common # :nodoc:
      module MultiLineStringTests # :nodoc:
        def setup
          @factory = create_factory
          point1 = @factory.point(0, 0)
          point2 = @factory.point(1, 0)
          point3 = @factory.point(-4, 2)  # (-4, 2)
          point4 = @factory.point(-7, 6)  # (-5, 3)
          point5 = @factory.point(5, 11)  # (-3, 5)
          @linestring1 = @factory.line_string([point1, point2])
          @linestring2 = @factory.line_string([point3, point4, point5])
          @linearring1 = @factory.linear_ring([point5, point3, point4, point5])
          @line1 = @factory.line(point1, point2)
        end

        def test_creation_simple
          geom = @factory.multi_line_string([@linestring1, @linestring2])
          assert(geom)
          assert(RGeo::Feature::MultiLineString === geom)
          assert_equal(RGeo::Feature::MultiLineString, geom.geometry_type)
          assert_equal(2, geom.num_geometries)
          assert(@linestring1.eql?(geom[0]))
          assert(@linestring2.eql?(geom[1]))
        end

        def test_creation_empty
          geom = @factory.multi_line_string([])
          assert(RGeo::Feature::MultiLineString === geom)
          assert_equal(RGeo::Feature::MultiLineString, geom.geometry_type)
          assert_equal(0, geom.num_geometries)
          assert_equal([], geom.to_a)
        end

        def test_creation_save_types
          geom = @factory.multi_line_string([@linestring1, @linearring1, @line1])
          assert(RGeo::Feature::MultiLineString === geom)
          assert_equal(RGeo::Feature::MultiLineString, geom.geometry_type)
          assert_equal(3, geom.num_geometries)
          assert(geom[1].eql?(@linearring1))
          assert(geom[2].eql?(@line1))
        end

        def test_creation_casting
          mls1 = @factory.collection([@line1])
          mls2 = @factory.multi_line_string([@linearring1])
          geom = @factory.multi_line_string([@linestring1, @linestring2, mls1, mls2])
          assert_equal(RGeo::Feature::MultiLineString, geom.geometry_type)
          assert_equal(4, geom.num_geometries)
          assert(@linestring1.eql?(geom[0]))
          assert(@linestring2.eql?(geom[1]))
          assert(@line1.eql?(geom[2]))
          assert(@linearring1.eql?(geom[3]))
        end

        def test_required_equivalences
          geom1 = @factory.multi_line_string([@linestring1, @linestring2])
          geom2 = @factory.multi_line_string([@linestring1, @linestring2])
          assert(geom1.eql?(geom2))
          assert(geom1 == geom2)
        end

        def test_fully_equal
          geom1 = @factory.multi_line_string([@linestring1, @linestring2])
          geom2 = @factory.multi_line_string([@linestring1, @linestring2])
          assert(geom1.rep_equals?(geom2))
          assert(geom1.equals?(geom2))
        end

        def test_geometrically_equal
          geom1 = @factory.multi_line_string([@linestring1, @linestring2, @linearring1])
          geom2 = @factory.multi_line_string([@line1, @linearring1])
          assert(!geom1.rep_equals?(geom2))
          assert(geom1.equals?(geom2))
        end

        def test_not_equal
          geom1 = @factory.multi_line_string([@linestring2])
          geom2 = @factory.multi_line_string([@linearring1])
          assert(!geom1.rep_equals?(geom2))
          assert(!geom1.equals?(geom2))
        end

        def test_hashes_equal_for_representationally_equivalent_objects
          geom1 = @factory.multi_line_string([@linestring1, @linestring2])
          geom2 = @factory.multi_line_string([@linestring1, @linestring2])
          assert_equal(geom1.hash, geom2.hash)
        end

        def test_wkt_creation_simple
          parsed_geom = @factory.parse_wkt("MULTILINESTRING((0 0, 1 0), (-4 2, -7 6, 5 11))")
          built_geom = @factory.multi_line_string([@linestring1, @linestring2])
          assert(built_geom.eql?(parsed_geom))
        end

        def test_wkt_creation_empty
          parsed_geom = @factory.parse_wkt("MULTILINESTRING EMPTY")
          assert_equal(RGeo::Feature::MultiLineString, parsed_geom.geometry_type)
          assert_equal(0, parsed_geom.num_geometries)
          assert_equal([], parsed_geom.to_a)
        end

        def test_clone
          geom1 = @factory.multi_line_string([@linestring1, @linestring2])
          geom2 = geom1.clone
          assert(geom1.eql?(geom2))
          assert_equal(RGeo::Feature::MultiLineString, geom2.geometry_type)
          assert_equal(2, geom2.num_geometries)
          assert(@linestring1.eql?(geom2[0]))
          assert(@linestring2.eql?(geom2[1]))
        end

        def test_type_check
          geom1 = @factory.multi_line_string([@linestring1, @linestring2])
          assert(RGeo::Feature::Geometry.check_type(geom1))
          assert(!RGeo::Feature::LineString.check_type(geom1))
          assert(RGeo::Feature::GeometryCollection.check_type(geom1))
          assert(!RGeo::Feature::MultiPoint.check_type(geom1))
          assert(RGeo::Feature::MultiLineString.check_type(geom1))
          geom2 = @factory.multi_line_string([])
          assert(RGeo::Feature::Geometry.check_type(geom2))
          assert(!RGeo::Feature::LineString.check_type(geom2))
          assert(RGeo::Feature::GeometryCollection.check_type(geom2))
          assert(!RGeo::Feature::MultiPoint.check_type(geom2))
          assert(RGeo::Feature::MultiLineString.check_type(geom2))
        end

        def test_as_textwkt_round_trip
          geom1 = @factory.multi_line_string([@linestring1, @linestring2])
          text = geom1.as_text
          geom2 = @factory.parse_wkt(text)
          assert(geom1.eql?(geom2))
        end

        def test_as_binary_wkb_round_trip
          geom1 = @factory.multi_line_string([@linestring1, @linestring2])
          binary_ = geom1.as_binary
          geom2 = @factory.parse_wkb(binary_)
          assert(geom1.eql?(geom2))
        end

        def test_dimension
          geom1 = @factory.multi_line_string([@linestring1, @linestring2])
          assert_equal(1, geom1.dimension)
          geom2 = @factory.multi_line_string([])
          assert_equal(-1, geom2.dimension)
        end

        def test_is_empty
          geom1 = @factory.multi_line_string([@linestring1, @linestring2])
          assert(!geom1.is_empty?)
          geom2 = @factory.multi_line_string([])
          assert(geom2.is_empty?)
        end

        def test_length
          geom1 = @factory.multi_line_string([@linestring1, @linestring2])
          assert_equal(19, geom1.length)
          geom2 = @factory.multi_line_string([])
          assert_equal(0, geom2.length)
        end

        def test_coordinates
          ml = @factory.multi_line_string([@linestring1, @linestring2])
          assert_equal(ml.coordinates, [@linestring1, @linestring2].map(&:coordinates))
        end

        def test_point_on_surface
          ml = @factory.multi_line_string([@linestring1, @linestring2])
          assert_equal(ml.point_on_surface, @factory.point(-7, 6))
        end
      end
    end
  end
end
