# -----------------------------------------------------------------------------
#
# Tests for type properties
#
# -----------------------------------------------------------------------------

require "test_helper"

class TestTypes < Test::Unit::TestCase
  def test_geometry
    assert_equal "Geometry", RGeo::Feature::Geometry.type_name
    assert_nil RGeo::Feature::Geometry.supertype
    assert RGeo::Feature::Geometry.subtype_of?(RGeo::Feature::Geometry)
    refute RGeo::Feature::Geometry.subtype_of?(RGeo::Feature::Point)
  end

  def test_point
    assert_equal "Point", RGeo::Feature::Point.type_name
    assert_equal RGeo::Feature::Geometry, RGeo::Feature::Point.supertype
    assert RGeo::Feature::Point.subtype_of?(RGeo::Feature::Point)
    assert RGeo::Feature::Point.subtype_of?(RGeo::Feature::Geometry)
    refute RGeo::Feature::Point.subtype_of?(RGeo::Feature::LineString)
  end

  def test_line_string
    assert_equal "LineString", RGeo::Feature::LineString.type_name
    assert_equal RGeo::Feature::Curve, RGeo::Feature::LineString.supertype
    assert RGeo::Feature::LineString.subtype_of?(RGeo::Feature::LineString)
    assert RGeo::Feature::LineString.subtype_of?(RGeo::Feature::Curve)
    assert RGeo::Feature::LineString.subtype_of?(RGeo::Feature::Geometry)
    refute RGeo::Feature::LineString.subtype_of?(RGeo::Feature::Line)
  end

  def test_illegal_cast
    point = wkt_parser.parse("POINT(1 2)")
    assert_nil RGeo::Feature.cast(point, RGeo::Feature::Line)
  end

  def test_cast_point_to_same_type
    # geom is a RGeo::Geos::CAPIPointImpl
    geom = wkt_parser.parse("POINT(1 2)")
    point = RGeo::Feature.cast(geom, RGeo::Feature::Point)
    assert RGeo::Feature::Point.check_type(point)
    assert_equal "POINT (1.0 2.0)", point.to_s
  end

  def test_cast_linestring_to_line
    # only works with 2-point linestrings
    linestring = wkt_parser.parse("LINESTRING(1 2, 3 4)")
    line = RGeo::Feature.cast(linestring, RGeo::Feature::Line)
    assert RGeo::Feature::Line.check_type(line)
    assert_equal "LINESTRING (1.0 2.0, 3.0 4.0)", line.to_s
  end

  def test_cast_collection_to_multipoint
    p1 = factory.point(0, 0)
    p2 = factory.point(1, 1)
    collection = factory.collection([p1, p2])
    multipoint = RGeo::Feature.cast(collection, RGeo::Feature::MultiPoint)
    assert RGeo::Feature::MultiPoint.check_type(multipoint)
    assert_equal "MULTIPOINT ((0.0 0.0), (1.0 1.0))", multipoint.to_s
  end

  private

  def wkt_parser
    RGeo::WKRep::WKTParser.new
  end

  def factory
    RGeo::Cartesian.preferred_factory
  end
end
