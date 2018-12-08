# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for WKT parser
#
# -----------------------------------------------------------------------------

require "test_helper"

class WKTParserTest < Minitest::Test # :nodoc:
  def test_point_2d
    parser = RGeo::WKRep::WKTParser.new
    obj = parser.parse("POINT(1 2)")
    assert_equal(RGeo::Feature::Point, obj.geometry_type)
    assert_equal(1, obj.x)
    assert_equal(2, obj.y)
  end

  def test_values_fractional
    parser = RGeo::WKRep::WKTParser.new
    obj = parser.parse("POINT(1.000 2.5)")
    assert_equal(RGeo::Feature::Point, obj.geometry_type)
    assert_equal(1.0, obj.x)
    assert_equal(2.5, obj.y)
  end

  def test_values_fractional2
    parser = RGeo::WKRep::WKTParser.new
    obj = parser.parse("POINT(1. .5)")
    assert_equal(RGeo::Feature::Point, obj.geometry_type)
    assert_equal(1.0, obj.x)
    assert_equal(0.5, obj.y)
  end

  def test_values_negative
    factory = RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory)
    obj = parser.parse("POINT(-1. -.5 -5.5)")
    assert_equal(RGeo::Feature::Point, obj.geometry_type)
    assert_equal(-1.0, obj.x)
    assert_equal(-0.5, obj.y)
    assert_equal(-5.5, obj.z)
  end

  def test_point_square_brackets
    parser = RGeo::WKRep::WKTParser.new
    obj = parser.parse("POINT[1 2]")
    assert_equal(RGeo::Feature::Point, obj.geometry_type)
    assert_equal(1, obj.x)
    assert_equal(2, obj.y)
  end

  def test_point_empty
    parser = RGeo::WKRep::WKTParser.new
    obj = parser.parse("POINT EMPTY")
    assert_equal(RGeo::Feature::MultiPoint, obj.geometry_type)
    assert_equal(0, obj.num_geometries)
  end

  def test_point_with_z
    factory = RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory)
    obj = parser.parse("POINT(1 2 3)")
    assert_equal(RGeo::Feature::Point, obj.geometry_type)
    assert_equal(3, obj.z)
    assert_nil(obj.m)
  end

  def test_point_with_m
    factory = RGeo::Cartesian.preferred_factory(has_m_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory)
    obj = parser.parse("POINT(1 2 3)")
    assert_equal(RGeo::Feature::Point, obj.geometry_type)
    assert_equal(3, obj.m)
    assert_nil(obj.z)
  end

  def test_point_with_too_many_coords
    factory = RGeo::Cartesian.preferred_factory
    parser = RGeo::WKRep::WKTParser.new(factory)
    assert_raises(RGeo::Error::ParseError) do
      parser.parse("POINT(1 2 3)")
    end
  end

  def test_point_wkt12_z
    factory = RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory, support_wkt12: true)
    obj = parser.parse("POINT Z(1 2 3)")
    assert_equal(RGeo::Feature::Point, obj.geometry_type)
    assert_equal(3, obj.z)
    assert_nil(obj.m)
  end

  def test_point_wkt12_z_unsupported_factory
    factory = RGeo::Cartesian.preferred_factory
    parser = RGeo::WKRep::WKTParser.new(factory, support_wkt12: true)
    assert_raises(RGeo::Error::ParseError) do
      parser.parse("POINT Z(1 2 3)")
    end
  end

  def test_point_wkt12_m
    factory = RGeo::Cartesian.preferred_factory(has_m_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory, support_wkt12: true)
    obj = parser.parse("POINT M(1 2 3)")
    assert_equal(RGeo::Feature::Point, obj.geometry_type)
    assert_equal(3, obj.m)
    assert_nil(obj.z)
  end

  def test_point_wkt12_m_with_factoryzm
    factory = RGeo::Cartesian.preferred_factory(has_z_coordinate: true, has_m_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory, support_wkt12: true)
    obj = parser.parse("POINT M(1 2 3)")
    assert_equal(RGeo::Feature::Point, obj.geometry_type)
    assert_equal(3, obj.m)
    assert_equal(0, obj.z)
  end

  def test_point_wkt12_m_too_many_coords
    factory = RGeo::Cartesian.preferred_factory(has_m_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory, support_wkt12: true)
    assert_raises(RGeo::Error::ParseError) do
      parser.parse("POINT M(1 2 3 4)")
    end
  end

  def test_point_wkt12_zm
    factory = RGeo::Cartesian.preferred_factory(has_z_coordinate: true, has_m_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory, support_wkt12: true)
    obj = parser.parse("POINT ZM(1 2 3 4)")
    assert_equal(RGeo::Feature::Point, obj.geometry_type)
    assert_equal(3, obj.z)
    assert_equal(4, obj.m)
  end

  def test_point_wkt12_zm_not_enough_coords
    factory = RGeo::Cartesian.preferred_factory(has_z_coordinate: true, has_m_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory, support_wkt12: true)
    assert_raises(RGeo::Error::ParseError) do
      parser.parse("POINT ZM(1 2 3)")
    end
  end

  def test_point_ewkt_z
    factory = RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory, support_ewkt: true)
    obj = parser.parse("POINT(1 2 3)")
    assert_equal(RGeo::Feature::Point, obj.geometry_type)
    assert_equal(3, obj.z)
    assert_nil(obj.m)
  end

  def test_point_ewkt_m
    factory = RGeo::Cartesian.preferred_factory(has_m_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory, support_ewkt: true)
    obj = parser.parse("POINTM(1 2 3)")
    assert_equal(RGeo::Feature::Point, obj.geometry_type)
    assert_equal(3, obj.m)
    assert_nil(obj.z)
  end

  def test_point_ewkt_with_srid
    parser = RGeo::WKRep::WKTParser.new(RGeo::Cartesian.method(:preferred_factory), support_ewkt: true)
    obj = parser.parse("SRID=1000;POINTM(1 2 3)")
    assert_equal(RGeo::Feature::Point, obj.geometry_type)
    assert_equal(3, obj.m)
    assert_nil(obj.z)
    assert_equal(1000, obj.srid)
  end

  def test_point_ewkt_m_too_many_coords
    factory = RGeo::Cartesian.preferred_factory(has_m_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory, support_ewkt: true)
    assert_raises(RGeo::Error::ParseError) do
      parser.parse("POINTM(1 2 3 4)")
    end
  end

  def test_point_strict_wkt11_with_z
    factory = RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory, strict_wkt11: true)
    assert_raises(RGeo::Error::ParseError) do
      parser.parse("POINT(1 2 3)")
    end
  end

  def test_point_non_ewkt_with_srid
    parser = RGeo::WKRep::WKTParser.new(RGeo::Cartesian.method(:preferred_factory))
    assert_raises(RGeo::Error::ParseError) do
      parser.parse("SRID=1000;POINT(1 2)")
    end
  end

  def test_linestring_basic
    factory = RGeo::Cartesian.preferred_factory
    parser = RGeo::WKRep::WKTParser.new(factory)
    obj = parser.parse("LINESTRING(1 2, 3 4, 5 6)")
    assert_equal(RGeo::Feature::LineString, obj.geometry_type)
    assert_equal(3, obj.num_points)
    assert_equal(1, obj.point_n(0).x)
    assert_equal(6, obj.point_n(2).y)
  end

  def test_linestring_with_z
    factory = RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory)
    obj = parser.parse("LINESTRING(1 2 3, 4 5 6,7 8 9)")
    assert_equal(RGeo::Feature::LineString, obj.geometry_type)
    assert_equal(3, obj.num_points)
    assert_equal(1, obj.point_n(0).x)
    assert_equal(9, obj.point_n(2).z)
  end

  def test_linestring_with_inconsistent_coords
    factory = RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory)
    assert_raises(RGeo::Error::ParseError) do
      parser.parse("LINESTRING(1 2 3, 4 5,7 8 9)")
    end
  end

  def test_linestring_wkt12_m
    factory = RGeo::Cartesian.preferred_factory(has_z_coordinate: true, has_m_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory, support_wkt12: true)
    obj = parser.parse("LINESTRING M(1 2 3,5 6 7)")
    assert_equal(RGeo::Feature::LineString, obj.geometry_type)
    assert_equal(2, obj.num_points)
    assert_equal(0, obj.point_n(0).z)
    assert_equal(3, obj.point_n(0).m)
    assert_equal(0, obj.point_n(1).z)
    assert_equal(7, obj.point_n(1).m)
  end

  def test_linestring_ewkt_with_srid
    parser = RGeo::WKRep::WKTParser.new(RGeo::Cartesian.method(:preferred_factory), support_ewkt: true)
    obj = parser.parse("SRID=1000;LINESTRINGM(1 2 3, 4 5 6)")
    assert_equal(RGeo::Feature::LineString, obj.geometry_type)
    assert_equal(3, obj.point_n(0).m)
    assert_nil(obj.point_n(0).z)
    assert_equal(1000, obj.srid)
  end

  def test_linestring_empty
    factory = RGeo::Cartesian.preferred_factory
    parser = RGeo::WKRep::WKTParser.new(factory)
    obj = parser.parse("LINESTRING EMPTY")
    assert_equal(RGeo::Feature::LineString, obj.geometry_type)
    assert_equal(0, obj.num_points)
  end

  def test_polygon_basic
    factory = RGeo::Cartesian.preferred_factory
    parser = RGeo::WKRep::WKTParser.new(factory)
    obj = parser.parse("POLYGON((1 2, 3 4, 5 7, 1 2))")
    assert_equal(RGeo::Feature::Polygon, obj.geometry_type)
    assert_equal(4, obj.exterior_ring.num_points)
    assert_equal(1, obj.exterior_ring.point_n(0).x)
    assert_equal(7, obj.exterior_ring.point_n(2).y)
  end

  def test_polygon_with_holes_and_z
    factory = RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory)
    obj = parser.parse("POLYGON((0 0 -1, 10 0 -2, 10 10 -3, 0 10 -4, 0 0 -5),(1 1 -6, 2 3 -7, 3 1 -8, 1 1 -9))")
    assert_equal(RGeo::Feature::Polygon, obj.geometry_type)
    assert_equal(5, obj.exterior_ring.num_points)
    assert_equal(0, obj.exterior_ring.point_n(0).x)
    assert_equal(10, obj.exterior_ring.point_n(2).y)
    assert_equal(1, obj.num_interior_rings)
    assert_equal(-6, obj.interior_ring_n(0).point_n(0).z)
    assert_equal(-7, obj.interior_ring_n(0).point_n(1).z)
  end

  def test_polygon_empty
    factory = RGeo::Cartesian.preferred_factory
    parser = RGeo::WKRep::WKTParser.new(factory)
    obj = parser.parse("POLYGON EMPTY")
    assert_equal(RGeo::Feature::Polygon, obj.geometry_type)
    assert_equal(0, obj.exterior_ring.num_points)
  end

  def test_multipoint_basic
    factory = RGeo::Cartesian.preferred_factory
    parser = RGeo::WKRep::WKTParser.new(factory)
    obj = parser.parse("MULTIPOINT((1 2),(0 3))")
    assert_equal(RGeo::Feature::MultiPoint, obj.geometry_type)
    assert_equal(2, obj.num_geometries)
    assert_equal(1, obj[0].x)
    assert_equal(3, obj[1].y)
  end

  def test_multipoint_without_parens
    # This syntax isn't strictly allowed by the spec, but apparently
    # it does get used occasionally, so we do support parsing it.
    factory = RGeo::Cartesian.preferred_factory
    parser = RGeo::WKRep::WKTParser.new(factory)
    obj = parser.parse("MULTIPOINT(1 2, 0 3)")
    assert_equal(RGeo::Feature::MultiPoint, obj.geometry_type)
    assert_equal(2, obj.num_geometries)
    assert_equal(1, obj[0].x)
    assert_equal(3, obj[1].y)
  end

  def test_multipoint_empty
    factory = RGeo::Cartesian.preferred_factory
    parser = RGeo::WKRep::WKTParser.new(factory)
    obj = parser.parse("MULTIPOINT EMPTY")
    assert_equal(RGeo::Feature::MultiPoint, obj.geometry_type)
    assert_equal(0, obj.num_geometries)
  end

  def test_multilinestring_basic
    factory = RGeo::Cartesian.preferred_factory
    parser = RGeo::WKRep::WKTParser.new(factory)
    obj = parser.parse("MULTILINESTRING((1 2, 3 4, 5 6),(0 -3, 0 -4, 1 -5))")
    assert_equal(RGeo::Feature::MultiLineString, obj.geometry_type)
    assert_equal(2, obj.num_geometries)
    assert_equal(1, obj[0].point_n(0).x)
    assert_equal(-5, obj[1].point_n(2).y)
  end

  def test_multilinestring_empty
    factory = RGeo::Cartesian.preferred_factory
    parser = RGeo::WKRep::WKTParser.new(factory)
    obj = parser.parse("MULTILINESTRING EMPTY")
    assert_equal(RGeo::Feature::MultiLineString, obj.geometry_type)
    assert_equal(0, obj.num_geometries)
  end

  def test_multipolygon_basic
    factory = RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory)
    obj = parser.parse("MULTIPOLYGON(((-1 -2 0, -3 -4 0, -5 -7 0, -1 -2 0)),((0 0 -1, 10 0 -2, 10 10 -3, 0 10 -4, 0 0 -5),(1 1 -6, 2 3 -7, 3 1 -8, 1 1 -9)))")
    assert_equal(RGeo::Feature::MultiPolygon, obj.geometry_type)
    assert_equal(2, obj.num_geometries)
    assert_equal(4, obj[0].exterior_ring.num_points)
    assert_equal(-1, obj[0].exterior_ring.point_n(0).x)
    assert_equal(-7, obj[0].exterior_ring.point_n(2).y)
    assert_equal(5, obj[1].exterior_ring.num_points)
    assert_equal(0, obj[1].exterior_ring.point_n(0).x)
    assert_equal(10, obj[1].exterior_ring.point_n(2).y)
    assert_equal(1, obj[1].num_interior_rings)
    assert_equal(-6, obj[1].interior_ring_n(0).point_n(0).z)
    assert_equal(-7, obj[1].interior_ring_n(0).point_n(1).z)
  end

  def test_multipolygon_empty
    factory = RGeo::Cartesian.preferred_factory
    parser = RGeo::WKRep::WKTParser.new(factory)
    obj = parser.parse("MULTIPOLYGON EMPTY")
    assert_equal(RGeo::Feature::MultiPolygon, obj.geometry_type)
    assert_equal(0, obj.num_geometries)
  end

  def test_collection_basic
    factory = RGeo::Cartesian.preferred_factory
    parser = RGeo::WKRep::WKTParser.new(factory)
    obj = parser.parse("GEOMETRYCOLLECTION(POINT(-1 -2),LINESTRING(1 2, 3 4, 5 6))")
    assert_equal(RGeo::Feature::GeometryCollection, obj.geometry_type)
    assert_equal(2, obj.num_geometries)
    assert_equal(RGeo::Feature::Point, obj[0].geometry_type)
    assert_equal(-1, obj[0].x)
    assert_equal(RGeo::Feature::LineString, obj[1].geometry_type)
    assert_equal(1, obj[1].point_n(0).x)
    assert_equal(6, obj[1].point_n(2).y)
  end

  def test_collection_z
    factory = RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory)
    obj = parser.parse("GEOMETRYCOLLECTION(POINT(-1 -2 0),LINESTRING(1 2 0, 3 4 0, 5 6 0))")
    assert_equal(RGeo::Feature::GeometryCollection, obj.geometry_type)
    assert_equal(2, obj.num_geometries)
    assert_equal(RGeo::Feature::Point, obj[0].geometry_type)
    assert_equal(-1, obj[0].x)
    assert_equal(RGeo::Feature::LineString, obj[1].geometry_type)
    assert_equal(1, obj[1].point_n(0).x)
    assert_equal(6, obj[1].point_n(2).y)
  end

  def test_collection_dimension_mismatch
    factory = RGeo::Cartesian.preferred_factory(has_z_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory)
    assert_raises(RGeo::Error::ParseError) do
      parser.parse("GEOMETRYCOLLECTION(POINT(-1 -2),LINESTRING(1 2 0, 3 4 0, 5 6 0))")
    end
  end

  def test_collection_wkt12_type_mismatch
    factory = RGeo::Cartesian.preferred_factory(has_z_coordinate: true, has_m_coordinate: true)
    parser = RGeo::WKRep::WKTParser.new(factory, support_wkt12: true)
    assert_raises(RGeo::Error::ParseError) do
      parser.parse("GEOMETRYCOLLECTION Z(POINT Z(-1 -2 0),LINESTRING M(1 2 0, 3 4 0, 5 6 0))")
    end
  end

  def test_collection_empty
    factory = RGeo::Cartesian.preferred_factory
    parser = RGeo::WKRep::WKTParser.new(factory)
    obj = parser.parse("GEOMETRYCOLLECTION EMPTY")
    assert_equal(RGeo::Feature::GeometryCollection, obj.geometry_type)
    assert_equal(0, obj.num_geometries)
  end
end
