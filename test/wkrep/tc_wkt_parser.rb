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
      class TestWKTParser < ::Test::Unit::TestCase # :nodoc:
        def test_point_2d
          parser_ = ::RGeo::WKRep::WKTParser.new
          obj_ = parser_.parse("POINT(1 2)")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(1, obj_.x)
          assert_equal(2, obj_.y)
        end

        def test_values_fractional
          parser_ = ::RGeo::WKRep::WKTParser.new
          obj_ = parser_.parse("POINT(1.000 2.5)")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(1.0, obj_.x)
          assert_equal(2.5, obj_.y)
        end

        def test_values_fractional2
          parser_ = ::RGeo::WKRep::WKTParser.new
          obj_ = parser_.parse("POINT(1. .5)")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(1.0, obj_.x)
          assert_equal(0.5, obj_.y)
        end

        def test_values_negative
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          obj_ = parser_.parse("POINT(-1. -.5 -5.5)")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(-1.0, obj_.x)
          assert_equal(-0.5, obj_.y)
          assert_equal(-5.5, obj_.z)
        end

        def test_point_square_brackets
          parser_ = ::RGeo::WKRep::WKTParser.new
          obj_ = parser_.parse("POINT[1 2]")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(1, obj_.x)
          assert_equal(2, obj_.y)
        end

        def test_point_empty
          parser_ = ::RGeo::WKRep::WKTParser.new
          obj_ = parser_.parse("POINT EMPTY")
          assert_equal(::RGeo::Feature::MultiPoint, obj_.geometry_type)
          assert_equal(0, obj_.num_geometries)
        end

        def test_point_with_z
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          obj_ = parser_.parse("POINT(1 2 3)")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(3, obj_.z)
          assert_nil(obj_.m)
        end

        def test_point_with_m
          factory_ = ::RGeo::Cartesian.preferred_factory(has_m_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          obj_ = parser_.parse("POINT(1 2 3)")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(3, obj_.m)
          assert_nil(obj_.z)
        end

        def test_point_with_too_many_coords
          factory_ = ::RGeo::Cartesian.preferred_factory
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          assert_raise(::RGeo::Error::ParseError) do
            parser_.parse("POINT(1 2 3)")
          end
        end

        def test_point_wkt12_z
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_, support_wkt12: true)
          obj_ = parser_.parse("POINT Z(1 2 3)")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(3, obj_.z)
          assert_nil(obj_.m)
        end

        def test_point_wkt12_z_unsupported_factory
          factory_ = ::RGeo::Cartesian.preferred_factory
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_, support_wkt12: true)
          assert_raise(::RGeo::Error::ParseError) do
            parser_.parse("POINT Z(1 2 3)")
          end
        end

        def test_point_wkt12_m
          factory_ = ::RGeo::Cartesian.preferred_factory(has_m_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_, support_wkt12: true)
          obj_ = parser_.parse("POINT M(1 2 3)")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(3, obj_.m)
          assert_nil(obj_.z)
        end

        def test_point_wkt12_m_with_factory_zm
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true, has_m_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_, support_wkt12: true)
          obj_ = parser_.parse("POINT M(1 2 3)")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(3, obj_.m)
          assert_equal(0, obj_.z)
        end

        def test_point_wkt12_m_too_many_coords
          factory_ = ::RGeo::Cartesian.preferred_factory(has_m_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_, support_wkt12: true)
          assert_raise(::RGeo::Error::ParseError) do
            parser_.parse("POINT M(1 2 3 4)")
          end
        end

        def test_point_wkt12_zm
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true, has_m_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_, support_wkt12: true)
          obj_ = parser_.parse("POINT ZM(1 2 3 4)")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(3, obj_.z)
          assert_equal(4, obj_.m)
        end

        def test_point_wkt12_zm_not_enough_coords
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true, has_m_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_, support_wkt12: true)
          assert_raise(::RGeo::Error::ParseError) do
            parser_.parse("POINT ZM(1 2 3)")
          end
        end

        def test_point_ewkt_z
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_, support_ewkt: true)
          obj_ = parser_.parse("POINT(1 2 3)")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(3, obj_.z)
          assert_nil(obj_.m)
        end

        def test_point_ewkt_m
          factory_ = ::RGeo::Cartesian.preferred_factory(has_m_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_, support_ewkt: true)
          obj_ = parser_.parse("POINTM(1 2 3)")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(3, obj_.m)
          assert_nil(obj_.z)
        end

        def test_point_ewkt_with_srid
          parser_ = ::RGeo::WKRep::WKTParser.new(::RGeo::Cartesian.method(:preferred_factory), support_ewkt: true)
          obj_ = parser_.parse("SRID=1000;POINTM(1 2 3)")
          assert_equal(::RGeo::Feature::Point, obj_.geometry_type)
          assert_equal(3, obj_.m)
          assert_nil(obj_.z)
          assert_equal(1000, obj_.srid)
        end

        def test_point_ewkt_m_too_many_coords
          factory_ = ::RGeo::Cartesian.preferred_factory(has_m_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_, support_ewkt: true)
          assert_raise(::RGeo::Error::ParseError) do
            parser_.parse("POINTM(1 2 3 4)")
          end
        end

        def test_point_strict_wkt11_with_z
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_, strict_wkt11: true)
          assert_raise(::RGeo::Error::ParseError) do
            parser_.parse("POINT(1 2 3)")
          end
        end

        def test_point_non_ewkt_with_srid
          parser_ = ::RGeo::WKRep::WKTParser.new(::RGeo::Cartesian.method(:preferred_factory))
          assert_raise(::RGeo::Error::ParseError) do
            parser_.parse("SRID=1000;POINT(1 2)")
          end
        end

        def test_linestring_basic
          factory_ = ::RGeo::Cartesian.preferred_factory
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          obj_ = parser_.parse("LINESTRING(1 2, 3 4, 5 6)")
          assert_equal(::RGeo::Feature::LineString, obj_.geometry_type)
          assert_equal(3, obj_.num_points)
          assert_equal(1, obj_.point_n(0).x)
          assert_equal(6, obj_.point_n(2).y)
        end

        def test_linestring_with_z
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          obj_ = parser_.parse("LINESTRING(1 2 3, 4 5 6,7 8 9)")
          assert_equal(::RGeo::Feature::LineString, obj_.geometry_type)
          assert_equal(3, obj_.num_points)
          assert_equal(1, obj_.point_n(0).x)
          assert_equal(9, obj_.point_n(2).z)
        end

        def test_linestring_with_inconsistent_coords
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          assert_raise(::RGeo::Error::ParseError) do
            parser_.parse("LINESTRING(1 2 3, 4 5,7 8 9)")
          end
        end

        def test_linestring_wkt12_m
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true, has_m_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_, support_wkt12: true)
          obj_ = parser_.parse("LINESTRING M(1 2 3,5 6 7)")
          assert_equal(::RGeo::Feature::LineString, obj_.geometry_type)
          assert_equal(2, obj_.num_points)
          assert_equal(0, obj_.point_n(0).z)
          assert_equal(3, obj_.point_n(0).m)
          assert_equal(0, obj_.point_n(1).z)
          assert_equal(7, obj_.point_n(1).m)
        end

        def test_linestring_ewkt_with_srid
          parser_ = ::RGeo::WKRep::WKTParser.new(::RGeo::Cartesian.method(:preferred_factory), support_ewkt: true)
          obj_ = parser_.parse("SRID=1000;LINESTRINGM(1 2 3, 4 5 6)")
          assert_equal(::RGeo::Feature::LineString, obj_.geometry_type)
          assert_equal(3, obj_.point_n(0).m)
          assert_nil(obj_.point_n(0).z)
          assert_equal(1000, obj_.srid)
        end

        def test_linestring_empty
          factory_ = ::RGeo::Cartesian.preferred_factory
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          obj_ = parser_.parse("LINESTRING EMPTY")
          assert_equal(::RGeo::Feature::LineString, obj_.geometry_type)
          assert_equal(0, obj_.num_points)
        end

        def test_polygon_basic
          factory_ = ::RGeo::Cartesian.preferred_factory
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          obj_ = parser_.parse("POLYGON((1 2, 3 4, 5 7, 1 2))")
          assert_equal(::RGeo::Feature::Polygon, obj_.geometry_type)
          assert_equal(4, obj_.exterior_ring.num_points)
          assert_equal(1, obj_.exterior_ring.point_n(0).x)
          assert_equal(7, obj_.exterior_ring.point_n(2).y)
        end

        def test_polygon_with_holes_and_z
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          obj_ = parser_.parse("POLYGON((0 0 -1, 10 0 -2, 10 10 -3, 0 10 -4, 0 0 -5),(1 1 -6, 2 3 -7, 3 1 -8, 1 1 -9))")
          assert_equal(::RGeo::Feature::Polygon, obj_.geometry_type)
          assert_equal(5, obj_.exterior_ring.num_points)
          assert_equal(0, obj_.exterior_ring.point_n(0).x)
          assert_equal(10, obj_.exterior_ring.point_n(2).y)
          assert_equal(1, obj_.num_interior_rings)
          assert_equal(-6, obj_.interior_ring_n(0).point_n(0).z)
          assert_equal(-7, obj_.interior_ring_n(0).point_n(1).z)
        end

        def test_polygon_empty
          factory_ = ::RGeo::Cartesian.preferred_factory
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          obj_ = parser_.parse("POLYGON EMPTY")
          assert_equal(::RGeo::Feature::Polygon, obj_.geometry_type)
          assert_equal(0, obj_.exterior_ring.num_points)
        end

        def test_multipoint_basic
          factory_ = ::RGeo::Cartesian.preferred_factory
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          obj_ = parser_.parse("MULTIPOINT((1 2),(0 3))")
          assert_equal(::RGeo::Feature::MultiPoint, obj_.geometry_type)
          assert_equal(2, obj_.num_geometries)
          assert_equal(1, obj_[0].x)
          assert_equal(3, obj_[1].y)
        end

        def test_multipoint_without_parens
          # This syntax isn't strictly allowed by the spec, but apparently
          # it does get used occasionally, so we do support parsing it.
          factory_ = ::RGeo::Cartesian.preferred_factory
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          obj_ = parser_.parse("MULTIPOINT(1 2, 0 3)")
          assert_equal(::RGeo::Feature::MultiPoint, obj_.geometry_type)
          assert_equal(2, obj_.num_geometries)
          assert_equal(1, obj_[0].x)
          assert_equal(3, obj_[1].y)
        end

        def test_multipoint_empty
          factory_ = ::RGeo::Cartesian.preferred_factory
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          obj_ = parser_.parse("MULTIPOINT EMPTY")
          assert_equal(::RGeo::Feature::MultiPoint, obj_.geometry_type)
          assert_equal(0, obj_.num_geometries)
        end

        def test_multilinestring_basic
          factory_ = ::RGeo::Cartesian.preferred_factory
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          obj_ = parser_.parse("MULTILINESTRING((1 2, 3 4, 5 6),(0 -3, 0 -4, 1 -5))")
          assert_equal(::RGeo::Feature::MultiLineString, obj_.geometry_type)
          assert_equal(2, obj_.num_geometries)
          assert_equal(1, obj_[0].point_n(0).x)
          assert_equal(-5, obj_[1].point_n(2).y)
        end

        def test_multilinestring_empty
          factory_ = ::RGeo::Cartesian.preferred_factory
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          obj_ = parser_.parse("MULTILINESTRING EMPTY")
          assert_equal(::RGeo::Feature::MultiLineString, obj_.geometry_type)
          assert_equal(0, obj_.num_geometries)
        end

        def test_multipolygon_basic
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          obj_ = parser_.parse("MULTIPOLYGON(((-1 -2 0, -3 -4 0, -5 -7 0, -1 -2 0)),((0 0 -1, 10 0 -2, 10 10 -3, 0 10 -4, 0 0 -5),(1 1 -6, 2 3 -7, 3 1 -8, 1 1 -9)))")
          assert_equal(::RGeo::Feature::MultiPolygon, obj_.geometry_type)
          assert_equal(2, obj_.num_geometries)
          assert_equal(4, obj_[0].exterior_ring.num_points)
          assert_equal(-1, obj_[0].exterior_ring.point_n(0).x)
          assert_equal(-7, obj_[0].exterior_ring.point_n(2).y)
          assert_equal(5, obj_[1].exterior_ring.num_points)
          assert_equal(0, obj_[1].exterior_ring.point_n(0).x)
          assert_equal(10, obj_[1].exterior_ring.point_n(2).y)
          assert_equal(1, obj_[1].num_interior_rings)
          assert_equal(-6, obj_[1].interior_ring_n(0).point_n(0).z)
          assert_equal(-7, obj_[1].interior_ring_n(0).point_n(1).z)
        end

        def test_multipolygon_empty
          factory_ = ::RGeo::Cartesian.preferred_factory
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          obj_ = parser_.parse("MULTIPOLYGON EMPTY")
          assert_equal(::RGeo::Feature::MultiPolygon, obj_.geometry_type)
          assert_equal(0, obj_.num_geometries)
        end

        def test_collection_basic
          factory_ = ::RGeo::Cartesian.preferred_factory
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          obj_ = parser_.parse("GEOMETRYCOLLECTION(POINT(-1 -2),LINESTRING(1 2, 3 4, 5 6))")
          assert_equal(::RGeo::Feature::GeometryCollection, obj_.geometry_type)
          assert_equal(2, obj_.num_geometries)
          assert_equal(::RGeo::Feature::Point, obj_[0].geometry_type)
          assert_equal(-1, obj_[0].x)
          assert_equal(::RGeo::Feature::LineString, obj_[1].geometry_type)
          assert_equal(1, obj_[1].point_n(0).x)
          assert_equal(6, obj_[1].point_n(2).y)
        end

        def test_collection_z
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          obj_ = parser_.parse("GEOMETRYCOLLECTION(POINT(-1 -2 0),LINESTRING(1 2 0, 3 4 0, 5 6 0))")
          assert_equal(::RGeo::Feature::GeometryCollection, obj_.geometry_type)
          assert_equal(2, obj_.num_geometries)
          assert_equal(::RGeo::Feature::Point, obj_[0].geometry_type)
          assert_equal(-1, obj_[0].x)
          assert_equal(::RGeo::Feature::LineString, obj_[1].geometry_type)
          assert_equal(1, obj_[1].point_n(0).x)
          assert_equal(6, obj_[1].point_n(2).y)
        end

        def test_collection_dimension_mismatch
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          assert_raise(::RGeo::Error::ParseError) do
            parser_.parse("GEOMETRYCOLLECTION(POINT(-1 -2),LINESTRING(1 2 0, 3 4 0, 5 6 0))")
          end
        end

        def test_collection_wkt12_type_mismatch
          factory_ = ::RGeo::Cartesian.preferred_factory(has_z_coordinate: true, has_m_coordinate: true)
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_, support_wkt12: true)
          assert_raise(::RGeo::Error::ParseError) do
            parser_.parse("GEOMETRYCOLLECTION Z(POINT Z(-1 -2 0),LINESTRING M(1 2 0, 3 4 0, 5 6 0))")
          end
        end

        def test_collection_empty
          factory_ = ::RGeo::Cartesian.preferred_factory
          parser_ = ::RGeo::WKRep::WKTParser.new(factory_)
          obj_ = parser_.parse("GEOMETRYCOLLECTION EMPTY")
          assert_equal(::RGeo::Feature::GeometryCollection, obj_.geometry_type)
          assert_equal(0, obj_.num_geometries)
        end
      end
    end
  end
end
