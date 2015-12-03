# -----------------------------------------------------------------------------
#
# Tests for WKT parser
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

module RGeo
  module Tests # :nodoc:
    module WKRep # :nodoc:
      class TestWKBParser < ::Test::Unit::TestCase # :nodoc:
        def test_point_2d_xdr_hex
          parser_ = ::RGeo::WKRep::WKBParser.new
          obj_ = parser_.parse("00000000013ff00000000000004000000000000000")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(1, obj_.x)
          assert_equal(2, obj_.y)
        end

        def test_point_2d_xdr_binary
          parser_ = ::RGeo::WKRep::WKBParser.new
          obj_ = parser_.parse(["00000000013ff00000000000004000000000000000"].pack("H*"))
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(1, obj_.x)
          assert_equal(2, obj_.y)
        end

        def test_point_2d_ndr
          parser_ = ::RGeo::WKRep::WKBParser.new
          obj_ = parser_.parse("0101000000000000000000f03f0000000000000040")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(1, obj_.x)
          assert_equal(2, obj_.y)
        end

        def test_point_with_ewkb_z
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
          parser_ = ::RGeo::WKRep::WKBParser.new(factory_, support_ewkb: true)
          obj_ = parser_.parse("00800000013ff000000000000040000000000000004008000000000000")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(3, obj_.z)
          assert_nil(obj_.m)
        end

        def test_point_with_ewkb_m
          factory_ = ::RGeo::Cartesian.preferred_factory(has_m_coordinate: true)
          parser_ = ::RGeo::WKRep::WKBParser.new(factory_, support_ewkb: true)
          obj_ = parser_.parse("00400000013ff000000000000040000000000000004008000000000000")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(3, obj_.m)
          assert_nil(obj_.z)
        end

        def test_point_with_ewkb_zm
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true, has_m_coordinate: true)
          parser_ = ::RGeo::WKRep::WKBParser.new(factory_, support_ewkb: true)
          obj_ = parser_.parse("00c00000013ff0000000000000400000000000000040080000000000004010000000000000")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(3, obj_.z)
          assert_equal(4, obj_.m)
        end

        def test_point_with_wkb12_z
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
          parser_ = ::RGeo::WKRep::WKBParser.new(factory_, support_wkb12: true)
          obj_ = parser_.parse("00000003e93ff000000000000040000000000000004008000000000000")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(3, obj_.z)
          assert_nil(obj_.m)
        end

        def test_point_with_wkb12_m
          factory_ = ::RGeo::Cartesian.preferred_factory(has_m_coordinate: true)
          parser_ = ::RGeo::WKRep::WKBParser.new(factory_, support_wkb12: true)
          obj_ = parser_.parse("00000007d13ff000000000000040000000000000004008000000000000")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(3, obj_.m)
          assert_nil(obj_.z)
        end

        def test_point_with_wkb12_zm
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true, has_m_coordinate: true)
          parser_ = ::RGeo::WKRep::WKBParser.new(factory_, support_wkb12: true)
          obj_ = parser_.parse("0000000bb93ff0000000000000400000000000000040080000000000004010000000000000")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(3, obj_.z)
          assert_equal(4, obj_.m)
        end

        def test_point_with_wkb12_z_without_wkb12_support
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
          parser_ = ::RGeo::WKRep::WKBParser.new(factory_)
          assert_raise(::RGeo::Error::ParseError) do
            parser_.parse("00000003e93ff000000000000040000000000000004008000000000000")
          end
        end

        def test_point_with_wkb12_z_without_enough_data
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
          parser_ = ::RGeo::WKRep::WKBParser.new(factory_, support_wkb12: true)
          assert_raise(::RGeo::Error::ParseError) do
            parser_.parse("00000003e93ff00000000000004000000000000000")
          end
        end

        def test_point_with_ewkb_z_and_srid
          factory_generator_ = ::Proc.new do |config_|
            ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true, srid: config_[:srid])
          end
          parser_ = ::RGeo::WKRep::WKBParser.new(factory_generator_, support_ewkb: true)
          obj_ = parser_.parse("00a0000001000003e83ff000000000000040000000000000004008000000000000")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(3, obj_.z)
          assert_nil(obj_.m)
          assert_equal(1000, obj_.srid)
        end

        def test_linestring_basic
          parser_ = ::RGeo::WKRep::WKBParser.new
          obj_ = parser_.parse("0000000002000000033ff000000000000040000000000000004008000000000000401000000000000040140000000000004018000000000000")
          assert_equal(::RGeo::Feature::LineString, obj_.geometry_type)
          assert_equal(3, obj_.num_points)
          assert_equal(1, obj_.point_n(0).x)
          assert_equal(6, obj_.point_n(2).y)
        end

        def test_linestring_with_ewkb_z
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
          parser_ = ::RGeo::WKRep::WKBParser.new(factory_, support_ewkb: true)
          obj_ = parser_.parse("0080000002000000023ff000000000000040000000000000004008000000000000401000000000000040140000000000004018000000000000")
          assert_equal(::RGeo::Feature::LineString, obj_.geometry_type)
          assert_equal(2, obj_.num_points)
          assert_equal(1, obj_.point_n(0).x)
          assert_equal(6, obj_.point_n(1).z)
        end

        def test_linestring_with_ewkb_z_and_srid
          factory_generator_ = ::Proc.new do |config_|
            ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true, srid: config_[:srid])
          end
          parser_ = ::RGeo::WKRep::WKBParser.new(factory_generator_, support_ewkb: true)
          obj_ = parser_.parse("00a0000002000003e8000000023ff000000000000040000000000000004008000000000000401000000000000040140000000000004018000000000000")
          assert_equal(::RGeo::Feature::LineString, obj_.geometry_type)
          assert_equal(2, obj_.num_points)
          assert_equal(1, obj_.point_n(0).x)
          assert_equal(6, obj_.point_n(1).z)
          assert_equal(1000, obj_.srid)
        end

        def test_linestring_with_wkb12_z
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
          parser_ = ::RGeo::WKRep::WKBParser.new(factory_, support_wkb12: true)
          obj_ = parser_.parse("00000003ea000000023ff000000000000040000000000000004008000000000000401000000000000040140000000000004018000000000000")
          assert_equal(::RGeo::Feature::LineString, obj_.geometry_type)
          assert_equal(2, obj_.num_points)
          assert_equal(1, obj_.point_n(0).x)
          assert_equal(6, obj_.point_n(1).z)
        end

        def test_linestring_empty
          parser_ = ::RGeo::WKRep::WKBParser.new
          obj_ = parser_.parse("000000000200000000")
          assert_equal(::RGeo::Feature::LineString, obj_.geometry_type)
          assert_equal(0, obj_.num_points)
        end

        def test_polygon_basic
          parser_ = ::RGeo::WKRep::WKBParser.new
          obj_ = parser_.parse("000000000300000001000000043ff0000000000000400000000000000040080000000000004010000000000000401800000000000040140000000000003ff00000000000004000000000000000")
          assert_equal(::RGeo::Feature::Polygon, obj_.geometry_type)
          assert_equal(4, obj_.exterior_ring.num_points)
          assert_equal(1, obj_.exterior_ring.point_n(0).x)
          assert_equal(5, obj_.exterior_ring.point_n(2).y)
        end

        def test_polygon_empty
          parser_ = ::RGeo::WKRep::WKBParser.new
          obj_ = parser_.parse("000000000300000000")
          assert_equal(::RGeo::Feature::Polygon, obj_.geometry_type)
          assert_equal(0, obj_.exterior_ring.num_points)
        end

        def test_multipoint_basic
          parser_ = ::RGeo::WKRep::WKBParser.new
          obj_ = parser_.parse("00000000040000000200000000013ff00000000000004000000000000000000000000140080000000000004010000000000000")
          assert_equal(::RGeo::Feature::MultiPoint, obj_.geometry_type)
          assert_equal(2, obj_.num_geometries)
          assert_equal(1, obj_[0].x)
          assert_equal(4, obj_[1].y)
        end

        def test_multipoint_mixed_byte_order
          parser_ = ::RGeo::WKRep::WKBParser.new
          obj_ = parser_.parse("0000000004000000020101000000000000000000f03f0000000000000040000000000140080000000000004010000000000000")
          assert_equal(::RGeo::Feature::MultiPoint, obj_.geometry_type)
          assert_equal(2, obj_.num_geometries)
          assert_equal(1, obj_[0].x)
          assert_equal(4, obj_[1].y)
        end

        def test_multipoint_with_ewkb_z
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
          parser_ = ::RGeo::WKRep::WKBParser.new(factory_, support_ewkb: true)
          obj_ = parser_.parse("00800000040000000200800000013ff0000000000000400000000000000040140000000000000080000001400800000000000040100000000000004018000000000000")
          assert_equal(::RGeo::Feature::MultiPoint, obj_.geometry_type)
          assert_equal(2, obj_.num_geometries)
          assert_equal(1, obj_[0].x)
          assert_equal(5, obj_[0].z)
          assert_equal(4, obj_[1].y)
          assert_equal(6, obj_[1].z)
          assert_nil(obj_[0].m)
        end

        def test_multipoint_ewkb_with_mixed_z
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
          parser_ = ::RGeo::WKRep::WKBParser.new(factory_, support_ewkb: true)
          assert_raise(::RGeo::Error::ParseError) do
            parser_.parse("00800000040000000200800000013ff000000000000040000000000000004014000000000000000000000140080000000000004010000000000000")
          end
        end

        def test_multipoint_empty
          parser_ = ::RGeo::WKRep::WKBParser.new
          obj_ = parser_.parse("000000000400000000")
          assert_equal(::RGeo::Feature::MultiPoint, obj_.geometry_type)
          assert_equal(0, obj_.num_geometries)
        end

        def test_multilinestring_basic
          parser_ = ::RGeo::WKRep::WKBParser.new
          obj_ = parser_.parse("0000000005000000020000000002000000033ff000000000000040000000000000004008000000000000401000000000000040140000000000004018000000000000000000000200000002bff0000000000000c000000000000000c008000000000000c010000000000000")
          assert_equal(::RGeo::Feature::MultiLineString, obj_.geometry_type)
          assert_equal(2, obj_.num_geometries)
          assert_equal(1, obj_[0].point_n(0).x)
          assert_equal(-4, obj_[1].point_n(1).y)
        end

        def test_multilinestring_wrong_element_type
          parser_ = ::RGeo::WKRep::WKBParser.new
          assert_raise(::RGeo::Error::ParseError) do
            parser_.parse("0000000005000000020000000002000000033ff00000000000004000000000000000400800000000000040100000000000004014000000000000401800000000000000000000013ff00000000000004000000000000000")
          end
        end

        def test_multilinestring_empty
          parser_ = ::RGeo::WKRep::WKBParser.new
          obj_ = parser_.parse("000000000500000000")
          assert_equal(::RGeo::Feature::MultiLineString, obj_.geometry_type)
          assert_equal(0, obj_.num_geometries)
        end

        def test_multipolygon_basic
          parser_ = ::RGeo::WKRep::WKBParser.new
          obj_ = parser_.parse("000000000600000002000000000300000001000000043ff0000000000000400000000000000040080000000000004010000000000000401800000000000040140000000000003ff00000000000004000000000000000000000000300000000")
          assert_equal(::RGeo::Feature::MultiPolygon, obj_.geometry_type)
          assert_equal(2, obj_.num_geometries)
          assert_equal(4, obj_[0].exterior_ring.num_points)
          assert_equal(1, obj_[0].exterior_ring.point_n(0).x)
          assert_equal(5, obj_[0].exterior_ring.point_n(2).y)
          assert_equal(0, obj_[1].exterior_ring.num_points)
        end

        def test_multipolygon_empty
          parser_ = ::RGeo::WKRep::WKBParser.new
          obj_ = parser_.parse("000000000600000000")
          assert_equal(::RGeo::Feature::MultiPolygon, obj_.geometry_type)
          assert_equal(0, obj_.num_geometries)
        end

        def test_collection_basic
          parser_ = ::RGeo::WKRep::WKBParser.new
          obj_ = parser_.parse("0000000007000000020000000002000000033ff0000000000000400000000000000040080000000000004010000000000000401400000000000040180000000000000000000001bff0000000000000c000000000000000")
          assert_equal(::RGeo::Feature::GeometryCollection, obj_.geometry_type)
          assert_equal(2, obj_.num_geometries)
          assert_equal(::RGeo::Feature::LineString, obj_[0].geometry_type)
          assert_equal(1, obj_[0].point_n(0).x)
          assert_equal(6, obj_[0].point_n(2).y)
          assert_equal(::RGeo::Feature::Point, obj_[1].geometry_type)
          assert_equal(-1, obj_[1].x)
        end

        def test_collection_empty
          parser_ = ::RGeo::WKRep::WKBParser.new
          obj_ = parser_.parse("000000000700000000")
          assert_equal(::RGeo::Feature::GeometryCollection, obj_.geometry_type)
          assert_equal(0, obj_.num_geometries)
        end
      end
    end
  end
end
