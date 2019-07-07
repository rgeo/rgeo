# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Common tests for line string implementations
#
# -----------------------------------------------------------------------------

module RGeo
  module Tests # :nodoc:
    module Common # :nodoc:
      module LineStringTests # :nodoc:
        def test_creation_points2
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          line1 = @factory.line_string([point1, point2])
          assert_equal(RGeo::Feature::LineString, line1.geometry_type)
          assert_equal(2, line1.num_points)
          assert_equal(point1, line1.point_n(0))
          assert_equal(point2, line1.point_n(1))
          assert_nil(line1.point_n(-1))
          assert_nil(line1.point_n(2))
          assert_equal(point1, line1.start_point)
          assert_equal(point2, line1.end_point)
        end

        def test_creation_points3
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          point3 = @factory.point(1, 0)
          line2 = @factory.line_string([point1, point2, point3])
          assert_equal(RGeo::Feature::LineString, line2.geometry_type)
          assert_equal(3, line2.num_points)
          assert_equal(point1, line2.point_n(0))
          assert_equal(point2, line2.point_n(1))
          assert_equal(point3, line2.point_n(2))
          assert_nil(line2.point_n(3))
          assert_equal(point1, line2.start_point)
          assert_equal(point3, line2.end_point)
        end

        def test_creation_points2_degenerate
          point1 = @factory.point(0, 0)
          line3 = @factory.line_string([point1, point1])
          assert_equal(RGeo::Feature::LineString, line3.geometry_type)
          assert_equal(2, line3.num_points)
          assert_equal(point1, line3.point_n(0))
          assert_equal(point1, line3.point_n(1))
          assert_equal(point1, line3.start_point)
          assert_equal(point1, line3.end_point)
        end

        def test_creation_points_empty
          line4 = @factory.line_string([])
          assert_equal(RGeo::Feature::LineString, line4.geometry_type)
          assert_equal(0, line4.num_points)
          assert_nil(line4.start_point)
          assert_nil(line4.end_point)
        end

        def test_creation_line_string
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          point3 = @factory.point(1, 1)
          line1 = @factory.line_string([point1, point2, point3])
          assert(RGeo::Feature::LineString === line1)
          assert(!(RGeo::Feature::LinearRing === line1))
          assert(!(RGeo::Feature::Line === line1))
          assert_equal(RGeo::Feature::LineString, line1.geometry_type)
        end

        def test_creation_linear_ring
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          point3 = @factory.point(1, 0)
          line1 = @factory.linear_ring([point1, point2, point3, point1])
          assert(line1.is_ring?)
          assert(RGeo::Feature::LinearRing === line1)
          assert_equal(RGeo::Feature::LinearRing, line1.geometry_type)
          line2 = @factory.linear_ring([point1, point2, point3])
          assert(line2)
          assert(line2.is_ring?)
          assert(RGeo::Feature::LinearRing === line2)
          assert_equal(4, line2.num_points)
          assert_equal(RGeo::Feature::LinearRing, line2.geometry_type)
        end

        def test_creation_line
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          line1 = @factory.line(point1, point2)
          assert(RGeo::Feature::Line === line1)
          assert_equal(RGeo::Feature::Line, line1.geometry_type)
        end

        def test_creation_errors
          point1 = @factory.point(0, 0)
          collection = point1.boundary
          assert_raises(RGeo::Error::InvalidGeometry) do
            @factory.line_string([point1])
          end
          assert_raises(RGeo::Error::InvalidGeometry) do
            @factory.line_string([point1, collection])
          end
        end

        def test_required_equivalences
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          point3 = @factory.point(1, 0)
          line1 = @factory.line_string([point1, point2, point3])
          point4 = @factory.point(0, 0)
          point5 = @factory.point(0, 1)
          point6 = @factory.point(1, 0)
          line2 = @factory.line_string([point4, point5, point6])
          assert(line1.eql?(line2))
          assert(line1 == line2)
        end

        def test_fully_equal
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          point3 = @factory.point(1, 0)
          line1 = @factory.line_string([point1, point2, point3])
          point4 = @factory.point(0, 0)
          point5 = @factory.point(0, 1)
          point6 = @factory.point(1, 0)
          line2 = @factory.line_string([point4, point5, point6])
          assert(line1.rep_equals?(line2))
          assert(line1.equals?(line2))
        end

        def test_geometrically_equal_but_different_type
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          line1 = @factory.line_string([point1, point2])
          point4 = @factory.point(0, 0)
          point5 = @factory.point(0, 1)
          line2 = @factory.line(point4, point5)
          assert(!line1.rep_equals?(line2))
          assert(line1.equals?(line2))
        end

        def test_geometrically_equal_but_different_type2
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          point3 = @factory.point(1, 0)
          line1 = @factory.line_string([point1, point2, point3, point1])
          point4 = @factory.point(0, 0)
          point5 = @factory.point(0, 1)
          point6 = @factory.point(1, 0)
          line2 = @factory.linear_ring([point4, point5, point6, point4])
          assert(!line1.rep_equals?(line2))
          assert(line1.equals?(line2))
        end

        def test_geometrically_equal_but_different_overlap
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          point3 = @factory.point(1, 0)
          line1 = @factory.line_string([point1, point2, point3])
          point4 = @factory.point(0, 0)
          point5 = @factory.point(0, 1)
          point6 = @factory.point(1, 0)
          line2 = @factory.line_string([point4, point5, point6, point5])
          assert(!line1.rep_equals?(line2))
          assert(line1.equals?(line2))
        end

        def test_empty_equal
          line1 = @factory.line_string([])
          line2 = @factory.line_string([])
          assert(line1.rep_equals?(line2))
          assert(line1.equals?(line2))
        end

        def test_not_equal
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          line1 = @factory.line_string([point1, point2])
          point4 = @factory.point(0, 0)
          point5 = @factory.point(0, 1)
          point6 = @factory.point(1, 0)
          line2 = @factory.line_string([point4, point5, point6])
          assert(!line1.rep_equals?(line2))
          assert(!line1.equals?(line2))
        end

        def test_hashes_equal_for_representationally_equivalent_objects
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          point3 = @factory.point(1, 0)
          line1 = @factory.line_string([point1, point2, point3])
          point4 = @factory.point(0, 0)
          point5 = @factory.point(0, 1)
          point6 = @factory.point(1, 0)
          line2 = @factory.line_string([point4, point5, point6])
          assert_equal(line1.hash, line2.hash)
        end

        def test_out_of_order_is_not_equal
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          line1 = @factory.line_string([point1, point2])
          point4 = @factory.point(0, 1)
          point5 = @factory.point(0, 0)
          line2 = @factory.line_string([point4, point5])
          assert(!line1.rep_equals?(line2))
          refute_equal(line1.hash, line2.hash)
        end

        def test_wkt_creation
          line1 = @factory.parse_wkt("LINESTRING(21 22, 11 12)")
          assert_equal(@factory.point(21, 22), line1.point_n(0))
          assert_equal(@factory.point(11, 12), line1.point_n(1))
          assert_equal(2, line1.num_points)
          line2 = @factory.parse_wkt("LINESTRING(-1 -1, 21 22, 11 12, -1 -1)")
          assert_equal(@factory.point(-1, -1), line2.point_n(0))
          assert_equal(@factory.point(21, 22), line2.point_n(1))
          assert_equal(@factory.point(11, 12), line2.point_n(2))
          assert_equal(@factory.point(-1, -1), line2.point_n(3))
          assert_equal(4, line2.num_points)
        end

        def test_clone
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          line1 = @factory.line_string([point1, point2])
          line2 = line1.clone
          assert(line1.eql?(line2))
          assert_equal(2, line2.num_points)
          assert(point1.eql?(line2.point_n(0)))
          assert(point2.eql?(line2.point_n(1)))
        end

        def test_type_check
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          line = @factory.line_string([point1, point2])
          assert(RGeo::Feature::Geometry.check_type(line))
          assert(!RGeo::Feature::Point.check_type(line))
          assert(!RGeo::Feature::GeometryCollection.check_type(line))
          assert(RGeo::Feature::Curve.check_type(line))
          assert(RGeo::Feature::LineString.check_type(line))
          assert(!RGeo::Feature::LinearRing.check_type(line))
        end

        def test_as_text_wkt_round_trip
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          line1 = @factory.line_string([point1, point2])
          text = line1.as_text
          line2 = @factory.parse_wkt(text)
          assert(line2.eql?(line1))
        end

        def test_as_binary_wkb_round_trip
          point1 = @factory.point(-42, 0)
          point2 = @factory.point(0, 193)
          line1 = @factory.line_string([point1, point2])
          binary = line1.as_binary
          line2 = @factory.parse_wkb(binary)
          assert(line2.eql?(line1))
        end

        def test_empty_as_text_wkt_round_trip
          line1 = @factory.line_string([])
          text = line1.as_text
          line2 = @factory.parse_wkt(text)
          assert(line2.is_empty?)
        end

        def test_empty_as_binary_wkb_round_trip
          line1 = @factory.line_string([])
          binary = line1.as_binary
          line2 = @factory.parse_wkb(binary)
          assert(line2.is_empty?)
        end

        def test_dimension
          point1 = @factory.point(-42, 0)
          point2 = @factory.point(0, 193)
          line1 = @factory.line_string([point1, point2])
          assert_equal(1, line1.dimension)
        end

        def test_is_empty
          point1 = @factory.point(-42, 0)
          point2 = @factory.point(0, 193)
          line1 = @factory.line_string([point1, point2])
          assert(!line1.is_empty?)
          line2 = @factory.line_string([])
          assert(line2.is_empty?)
        end

        def test_marshal_roundtrip
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          line1 = @factory.line_string([point1, point2])
          data = Marshal.dump(line1)
          line2 = Marshal.load(data)
          assert_equal(line1, line2)
        end

        def test_line_string_coordinates
          line = @factory.line_string([@factory.point(0.0, 1.0), @factory.point(2.0, 3.0)])
          assert_equal(line.coordinates, [[0.0, 1.0], [2.0, 3.0]])
        end

        def test_validate_coordinates
          p1 = @factory.point(-169.478, -56)
          p2 = @factory.point(167.95, 64.8333)
          bbox = RGeo::Cartesian::BoundingBox.create_from_points(p1, p2)
          assert_equal "POLYGON ((-169.478 -56.0, 167.95 -56.0, 167.95 64.8333, "\
            "-169.478 64.8333, -169.478 -56.0))", bbox.to_geometry.to_s
        end

        def test_psych_roundtrip
          point1 = @factory.point(0, 0)
          point2 = @factory.point(0, 1)
          line1 = @factory.line_string([point1, point2])
          data = Psych.dump(line1)
          line2 = Psych.load(data)
          assert_equal(line1, line2)
        end

        def test_point_on_surface
          point1 = @factory.point(1, 0)
          point2 = @factory.point(-4, 2)
          point3 = @factory.point(-7, 6)
          line = @factory.line_string([point1, point2, point3])
          assert_equal(line.point_on_surface, point2)
        end
      end
    end
  end
end
