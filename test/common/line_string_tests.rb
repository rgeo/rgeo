# -----------------------------------------------------------------------------
#
# Common tests for line string implementations
#
# -----------------------------------------------------------------------------

require "test_helper"

module RGeo
  module Tests # :nodoc:
    module Common # :nodoc:
      module LineStringTests # :nodoc:
        def test_creation_points2
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          line1_ = @factory.line_string([point1_, point2_])
          assert_not_nil(line1_)
          assert_equal(::RGeo::Feature::LineString, line1_.geometry_type)
          assert_equal(2, line1_.num_points)
          assert_equal(point1_, line1_.point_n(0))
          assert_equal(point2_, line1_.point_n(1))
          assert_nil(line1_.point_n(-1))
          assert_nil(line1_.point_n(2))
          assert_equal(point1_, line1_.start_point)
          assert_equal(point2_, line1_.end_point)
        end

        def test_creation_points3
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(1, 0)
          line2_ = @factory.line_string([point1_, point2_, point3_])
          assert_not_nil(line2_)
          assert_equal(::RGeo::Feature::LineString, line2_.geometry_type)
          assert_equal(3, line2_.num_points)
          assert_equal(point1_, line2_.point_n(0))
          assert_equal(point2_, line2_.point_n(1))
          assert_equal(point3_, line2_.point_n(2))
          assert_nil(line2_.point_n(3))
          assert_equal(point1_, line2_.start_point)
          assert_equal(point3_, line2_.end_point)
        end

        def test_creation_points2_degenerate
          point1_ = @factory.point(0, 0)
          line3_ = @factory.line_string([point1_, point1_])
          assert_not_nil(line3_)
          assert_equal(::RGeo::Feature::LineString, line3_.geometry_type)
          assert_equal(2, line3_.num_points)
          assert_equal(point1_, line3_.point_n(0))
          assert_equal(point1_, line3_.point_n(1))
          assert_equal(point1_, line3_.start_point)
          assert_equal(point1_, line3_.end_point)
        end

        def test_creation_points_empty
          line4_ = @factory.line_string([])
          assert_not_nil(line4_)
          assert_equal(::RGeo::Feature::LineString, line4_.geometry_type)
          assert_equal(0, line4_.num_points)
          assert_nil(line4_.start_point)
          assert_nil(line4_.end_point)
        end

        def test_creation_line_string
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(1, 1)
          line1_ = @factory.line_string([point1_, point2_, point3_])
          assert_not_nil(line1_)
          assert(::RGeo::Feature::LineString === line1_)
          assert(!(::RGeo::Feature::LinearRing === line1_))
          assert(!(::RGeo::Feature::Line === line1_))
          assert_equal(::RGeo::Feature::LineString, line1_.geometry_type)
        end

        def test_creation_linear_ring
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(1, 0)
          line1_ = @factory.linear_ring([point1_, point2_, point3_, point1_])
          assert_not_nil(line1_)
          assert(line1_.is_ring?)
          assert(::RGeo::Feature::LinearRing === line1_)
          assert_equal(::RGeo::Feature::LinearRing, line1_.geometry_type)
          line2_ = @factory.linear_ring([point1_, point2_, point3_])
          assert_not_nil(line2_)
          assert(line2_.is_ring?)
          assert(::RGeo::Feature::LinearRing === line2_)
          assert_equal(4, line2_.num_points)
          assert_equal(::RGeo::Feature::LinearRing, line2_.geometry_type)
        end

        def test_creation_line
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          line1_ = @factory.line(point1_, point2_)
          assert_not_nil(line1_)
          assert(::RGeo::Feature::Line === line1_)
          assert_equal(::RGeo::Feature::Line, line1_.geometry_type)
        end

        def test_creation_errors
          point1_ = @factory.point(0, 0)
          collection_ = point1_.boundary
          line1_ = @factory.line_string([point1_])
          assert_nil(line1_)
          line2_ = @factory.line_string([point1_, collection_])
          assert_nil(line2_)
        end

        def test_required_equivalences
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(1, 0)
          line1_ = @factory.line_string([point1_, point2_, point3_])
          point4_ = @factory.point(0, 0)
          point5_ = @factory.point(0, 1)
          point6_ = @factory.point(1, 0)
          line2_ = @factory.line_string([point4_, point5_, point6_])
          assert(line1_.eql?(line2_))
          assert(line1_ == line2_)
        end

        def test_fully_equal
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(1, 0)
          line1_ = @factory.line_string([point1_, point2_, point3_])
          point4_ = @factory.point(0, 0)
          point5_ = @factory.point(0, 1)
          point6_ = @factory.point(1, 0)
          line2_ = @factory.line_string([point4_, point5_, point6_])
          assert(line1_.rep_equals?(line2_))
          assert(line1_.equals?(line2_))
        end

        def test_geometrically_equal_but_different_type
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          line1_ = @factory.line_string([point1_, point2_])
          point4_ = @factory.point(0, 0)
          point5_ = @factory.point(0, 1)
          line2_ = @factory.line(point4_, point5_)
          assert(!line1_.rep_equals?(line2_))
          assert(line1_.equals?(line2_))
        end

        def test_geometrically_equal_but_different_type2
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(1, 0)
          line1_ = @factory.line_string([point1_, point2_, point3_, point1_])
          point4_ = @factory.point(0, 0)
          point5_ = @factory.point(0, 1)
          point6_ = @factory.point(1, 0)
          line2_ = @factory.linear_ring([point4_, point5_, point6_, point4_])
          assert(!line1_.rep_equals?(line2_))
          assert(line1_.equals?(line2_))
        end

        def test_geometrically_equal_but_different_overlap
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(1, 0)
          line1_ = @factory.line_string([point1_, point2_, point3_])
          point4_ = @factory.point(0, 0)
          point5_ = @factory.point(0, 1)
          point6_ = @factory.point(1, 0)
          line2_ = @factory.line_string([point4_, point5_, point6_, point5_])
          assert(!line1_.rep_equals?(line2_))
          assert(line1_.equals?(line2_))
        end

        def test_empty_equal
          line1_ = @factory.line_string([])
          line2_ = @factory.line_string([])
          assert(line1_.rep_equals?(line2_))
          assert(line1_.equals?(line2_))
        end

        def test_not_equal
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          line1_ = @factory.line_string([point1_, point2_])
          point4_ = @factory.point(0, 0)
          point5_ = @factory.point(0, 1)
          point6_ = @factory.point(1, 0)
          line2_ = @factory.line_string([point4_, point5_, point6_])
          assert(!line1_.rep_equals?(line2_))
          assert(!line1_.equals?(line2_))
        end

        def test_hashes_equal_for_representationally_equivalent_objects
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(1, 0)
          line1_ = @factory.line_string([point1_, point2_, point3_])
          point4_ = @factory.point(0, 0)
          point5_ = @factory.point(0, 1)
          point6_ = @factory.point(1, 0)
          line2_ = @factory.line_string([point4_, point5_, point6_])
          assert_equal(line1_.hash, line2_.hash)
        end

        def test_out_of_order_is_not_equal
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          line1_ = @factory.line_string([point1_, point2_])
          point4_ = @factory.point(0, 1)
          point5_ = @factory.point(0, 0)
          line2_ = @factory.line_string([point4_, point5_])
          assert(!line1_.rep_equals?(line2_))
          assert_not_equal(line1_.hash, line2_.hash)
        end

        def test_wkt_creation
          line1_ = @factory.parse_wkt("LINESTRING(21 22, 11 12)")
          assert_equal(@factory.point(21, 22), line1_.point_n(0))
          assert_equal(@factory.point(11, 12), line1_.point_n(1))
          assert_equal(2, line1_.num_points)
          line2_ = @factory.parse_wkt("LINESTRING(-1 -1, 21 22, 11 12, -1 -1)")
          assert_equal(@factory.point(-1, -1), line2_.point_n(0))
          assert_equal(@factory.point(21, 22), line2_.point_n(1))
          assert_equal(@factory.point(11, 12), line2_.point_n(2))
          assert_equal(@factory.point(-1, -1), line2_.point_n(3))
          assert_equal(4, line2_.num_points)
        end

        def test_clone
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          line1_ = @factory.line_string([point1_, point2_])
          line2_ = line1_.clone
          assert(line1_.eql?(line2_))
          assert_equal(2, line2_.num_points)
          assert(point1_.eql?(line2_.point_n(0)))
          assert(point2_.eql?(line2_.point_n(1)))
        end

        def test_type_check
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          line_ = @factory.line_string([point1_, point2_])
          assert(::RGeo::Feature::Geometry.check_type(line_))
          assert(!::RGeo::Feature::Point.check_type(line_))
          assert(!::RGeo::Feature::GeometryCollection.check_type(line_))
          assert(::RGeo::Feature::Curve.check_type(line_))
          assert(::RGeo::Feature::LineString.check_type(line_))
          assert(!::RGeo::Feature::LinearRing.check_type(line_))
        end

        def test_as_text_wkt_round_trip
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          line1_ = @factory.line_string([point1_, point2_])
          text_ = line1_.as_text
          line2_ = @factory.parse_wkt(text_)
          assert(line2_.eql?(line1_))
        end

        def test_as_binary_wkb_round_trip
          point1_ = @factory.point(-42, 0)
          point2_ = @factory.point(0, 193)
          line1_ = @factory.line_string([point1_, point2_])
          binary_ = line1_.as_binary
          line2_ = @factory.parse_wkb(binary_)
          assert(line2_.eql?(line1_))
        end

        def test_empty_as_text_wkt_round_trip
          line1_ = @factory.line_string([])
          text_ = line1_.as_text
          line2_ = @factory.parse_wkt(text_)
          assert(line2_.is_empty?)
        end

        def test_empty_as_binary_wkb_round_trip
          line1_ = @factory.line_string([])
          binary_ = line1_.as_binary
          line2_ = @factory.parse_wkb(binary_)
          assert(line2_.is_empty?)
        end

        def test_dimension
          point1_ = @factory.point(-42, 0)
          point2_ = @factory.point(0, 193)
          line1_ = @factory.line_string([point1_, point2_])
          assert_equal(1, line1_.dimension)
        end

        def test_is_empty
          point1_ = @factory.point(-42, 0)
          point2_ = @factory.point(0, 193)
          line1_ = @factory.line_string([point1_, point2_])
          assert(!line1_.is_empty?)
          line2_ = @factory.line_string([])
          assert(line2_.is_empty?)
        end

        def test_marshal_roundtrip
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          line1_ = @factory.line_string([point1_, point2_])
          data_ = ::Marshal.dump(line1_)
          line2_ = ::Marshal.load(data_)
          assert_equal(line1_, line2_)
        end

        def test_linestring_coordinates
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
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          line1_ = @factory.line_string([point1_, point2_])
          data_ = Psych.dump(line1_)
          line2_ = Psych.load(data_)
          assert_equal(line1_, line2_)
        end
      end
    end
  end
end
