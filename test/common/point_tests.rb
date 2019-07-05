# frozen_string_literal: false

# -----------------------------------------------------------------------------
#
# Common tests for point implementations
#
# -----------------------------------------------------------------------------

module RGeo
  module Tests # :nodoc:
    module Common # :nodoc:
      module PointTests # :nodoc:
        def assert_close_enough(p1, p2)
          assert((p1.x - p2.x).abs < 0.00000001 && (p1.y - p2.y).abs < 0.00000001)
        end

        def assert_contains_approx(p, mp)
          assert(mp.any? { |q| (p.x - q.x).abs < 0.00000001 && (p.y - q.y).abs < 0.00000001 })
        end

        def test_creation
          point = @factory.point(21, -22)
          assert_equal(21, point.x)
          assert_equal(-22, point.y)
        end

        def test_wkt_creation
          point1 = @factory.parse_wkt("Point (21 -22)")
          assert_equal(21, point1.x)
          assert_equal(-22, point1.y)
        end

        def test_clone
          point1 = @factory.point(11, 12)
          point2 = point1.clone
          assert_equal(point1, point2)
          point3 = @factory.point(13, 12)
          point4 = point3.dup
          assert_equal(point3, point4)
          refute_equal(point2, point4)
        end

        def test_type_check
          point = @factory.point(21, 22)
          assert(RGeo::Feature::Geometry.check_type(point))
          assert(RGeo::Feature::Point.check_type(point))
          assert(!RGeo::Feature::GeometryCollection.check_type(point))
          assert(!RGeo::Feature::Curve.check_type(point))
        end

        def test_geometry_type
          point = @factory.point(11, 12)
          assert_equal(RGeo::Feature::Point, point.geometry_type)
        end

        def test_dimension
          point = @factory.point(11, 12)
          assert_equal(0, point.dimension)
        end

        def test_envelope
          point = @factory.point(11, 12)
          assert_close_enough(point, point.envelope)
        end

        def test_as_text
          point = @factory.point(11, 12)
          assert_equal("POINT (11.0 12.0)", point.as_text)
        end

        def test_as_text_wkt_round_trip
          point1 = @factory.point(11, 12)
          text = point1.as_text
          point2 = @factory.parse_wkt(text)
          assert_equal(point2, point1)
        end

        def test_as_binary_wkb_round_trip
          point1 = @factory.point(211, 12)
          binary = point1.as_binary
          point2 = @factory.parse_wkb(binary)
          assert_equal(point2, point1)
        end

        def test_is_empty
          point1 = @factory.point(0, 0)
          assert(!point1.is_empty?)
        end

        def test_is_simple
          point1 = @factory.point(0, 0)
          assert(point1.is_simple?)
        end

        def test_boundary
          point = @factory.point(11, 12)
          assert point.boundary.is_empty?
        end

        def test_equals
          point1 = @factory.point(11, 12)
          point2 = @factory.point(11, 12)
          point3 = @factory.point(13, 12)
          assert(point1.equals?(point2))
          assert(point1 == point2)
          assert(point1.rep_equals?(point2))
          assert(point1.eql?(point2))
          assert(!point1.equals?(point3))
          assert(point1 != point3)
          assert(!point1.rep_equals?(point3))
          assert(!point1.eql?(point3))
          assert(point1 != "hello")
          assert(!point1.eql?("hello"))
        end

        def test_out_of_order_is_not_equal
          point1 = @factory.point(11, 12)
          point2 = @factory.point(12, 11)
          refute_equal(point1, point2)
          refute_equal(point1.hash, point2.hash)
        end

        def test_hashes_equal_for_representationally_equivalent_objects
          point1 = @factory.point(11, 12)
          point2 = @factory.point(11, 12)
          assert_equal(point1.hash, point2.hash)
        end

        def test_pointas_hash_key
          hash_ = { @factory.point(11, 12) => :hello }
          assert_equal(:hello, hash_[@factory.point(11, 12)])
        end

        def test_disjoint
          point1 = @factory.point(11, 12)
          point2 = @factory.point(11, 12)
          point3 = @factory.point(12, 12)
          assert(!point1.disjoint?(point2))
          assert(point1.disjoint?(point3))
        end

        def test_intersects
          point1 = @factory.point(11, 12)
          point2 = @factory.point(11, 12)
          point3 = @factory.point(12, 12)
          assert(point1.intersects?(point2))
          assert(!point1.intersects?(point3))
        end

        def test_touches
          point1 = @factory.point(11, 12)
          point2 = @factory.point(11, 12)
          point3 = @factory.point(12, 12)
          assert(!point1.touches?(point2))
          assert(!point1.touches?(point3))
        end

        def test_crosses
          point1 = @factory.point(11, 12)
          point2 = @factory.point(11, 12)
          point3 = @factory.point(12, 12)
          assert(!point1.crosses?(point2))
          assert(!point1.crosses?(point3))
        end

        def test_within
          point1 = @factory.point(11, 12)
          point2 = @factory.point(11, 12)
          point3 = @factory.point(12, 12)
          assert(point1.within?(point2))
          assert(!point1.within?(point3))
        end

        def test_contains
          point1 = @factory.point(11, 12)
          point2 = @factory.point(11, 12)
          point3 = @factory.point(12, 12)
          assert(point1.contains?(point2))
          assert(!point1.contains?(point3))
        end

        def test_overlaps
          point1 = @factory.point(11, 12)
          point2 = @factory.point(11, 12)
          point3 = @factory.point(12, 12)
          assert(!point1.overlaps?(point2))
          assert(!point1.overlaps?(point3))
        end

        def test_convex_hull
          point = @factory.point(11, 12)
          assert_close_enough(point, point.convex_hull)
        end

        def test_intersection
          point1 = @factory.point(11, 12)
          point2 = @factory.point(11, 12)
          point3 = @factory.point(12, 12)
          assert_close_enough(point1, point1.intersection(point2))
          assert point1.intersection(point3).is_empty?
        end

        def test_union
          point1 = @factory.point(11, 12)
          point2 = @factory.point(11, 12)
          point3 = @factory.point(12, 12)
          union12 = point1.union(point2)
          union13 = point1.union(point3)
          assert_close_enough(point1, union12)
          assert_equal(RGeo::Feature::MultiPoint, union13.geometry_type)
          assert_contains_approx(point1, union13)
          assert_contains_approx(point3, union13)
        end

        def test_difference
          point1 = @factory.point(11, 12)
          point2 = @factory.point(11, 12)
          point3 = @factory.point(12, 12)
          diff12 = point1.difference(point2)
          diff13 = point1.difference(point3)
          assert_equal(RGeo::Feature::GeometryCollection, diff12.geometry_type)
          assert(diff12.is_empty?)
          assert_close_enough(point1, diff13)
        end

        def test_sym_difference
          point1 = @factory.point(11, 12)
          point2 = @factory.point(11, 12)
          point3 = @factory.point(12, 12)
          diff12 = point1.sym_difference(point2)
          diff13 = point1.sym_difference(point3)
          assert_equal(RGeo::Feature::GeometryCollection, diff12.geometry_type)
          assert(diff12.is_empty?)
          assert_equal(RGeo::Feature::MultiPoint, diff13.geometry_type)
          assert_contains_approx(point1, diff13)
          assert_contains_approx(point3, diff13)
        end

        def test_buffer
          point = @factory.point(11, 12)
          buffer = point.buffer(4)
          assert_equal(RGeo::Feature::Polygon, buffer.geometry_type)
          assert_equal(33, buffer.exterior_ring.num_points)
        end

        def test_3dz_creation
          point = @zfactory.point(11, 12, 13)
          assert_equal(11, point.x)
          assert_equal(12, point.y)
          assert_equal(13, point.z)
          point2 = @zfactory.point(21, 22)
          assert_equal(21, point2.x)
          assert_equal(22, point2.y)
          assert_equal(0, point2.z)
        end

        def test_3dm_creation
          point = @mfactory.point(11, 12, 13)
          assert_equal(11, point.x)
          assert_equal(12, point.y)
          assert_equal(13, point.m)
          point2 = @mfactory.point(21, 22)
          assert_equal(21, point2.x)
          assert_equal(22, point2.y)
          assert_equal(0, point2.m)
        end

        def test_4d_creation
          point = @zmfactory.point(11, 12, 13, 14)
          assert_equal(11, point.x)
          assert_equal(12, point.y)
          assert_equal(13, point.z)
          assert_equal(14, point.m)
          point2 = @zmfactory.point(21, 22)
          assert_equal(21, point2.x)
          assert_equal(22, point2.y)
          assert_equal(0, point2.z)
          assert_equal(0, point2.m)
        end

        def test_wkt_creation_3d
          point2 = @zfactory.parse_wkt("POINT(11 12 13)")
          assert_equal(11, point2.x)
          assert_equal(12, point2.y)
          assert_equal(13, point2.z)
          point1 = @zfactory.parse_wkt("POINT(21 22)")
          assert_equal(21, point1.x)
          assert_equal(22, point1.y)
          # Z is undefined in this case.
          # We'd like to define it to be 0, but the GEOS
          # parser doesn't behave that way.
        end

        def test_marshal_roundtrip
          point = @factory.point(11, 12)
          data = Marshal.dump(point)
          point2 = Marshal.load(data)
          assert_equal(point, point2)
        end

        def test_marshal_roundtrip_3d
          point = @zfactory.point(11, 12, 13)
          data = Marshal.dump(point)
          point2 = Marshal.load(data)
          assert_equal(point, point2)
        end

        def test_marshal_roundtrip_4d
          point = @zmfactory.point(11, 12, 13, 14)
          data = Marshal.dump(point)
          point2 = Marshal.load(data)
          assert_equal(point, point2)
        end

        def test_coordinates
          point = @factory.point(11.0, 12.0)
          assert_equal([11.0, 12.0], point.coordinates)
        end

        def test_coordinates_3dz
          point = @zfactory.point(11, 12, 13)
          assert_equal([11.0, 12.0, 13.0], point.coordinates)
          point2 = @zfactory.point(21, 22)
          assert_equal([21.0, 22.0, 0.0], point2.coordinates)
        end

        def test_coordinates_3dm
          point = @mfactory.point(11, 12, 13)
          assert_equal([11.0, 12.0, 13.0], point.coordinates)
          point2 = @mfactory.point(21, 22)
          assert_equal([21.0, 22.0, 0.0], point2.coordinates)
        end

        def test_coordinates_4d
          point = @zmfactory.point(11, 12, 13, 14)
          assert_equal([11.0, 12.0, 13.0, 14.0], point.coordinates)
          point2 = @zmfactory.point(21, 22)
          assert_equal([21.0, 22.0, 0.0, 0.0], point2.coordinates)
        end

        def test_psych_roundtrip
          point = @factory.point(11, 12)
          data = Psych.dump(point)
          point2 = Psych.load(data)
          assert_equal(point, point2)
        end

        def test_psych_roundtrip_3d
          point = @zfactory.point(11, 12, 13)
          data = Psych.dump(point)
          point2 = Psych.load(data)
          assert_equal(point, point2)
        end

        def test_psych_roundtrip_4d
          point = @zmfactory.point(11, 12, 13, 14)
          data = Psych.dump(point)
          point2 = Psych.load(data)
          assert_equal(point, point2)
        end

        def test_point_on_surface
          point = @factory.point(11, 12)
          assert_equal(point.point_on_surface, point)
        end
      end
    end
  end
end
