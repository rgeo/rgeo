# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for type properties
#
# -----------------------------------------------------------------------------

require_relative "test_helper"

class TypesTest < Minitest::Test
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

  def test_cast_with_unimplemented_coordinate_transform
    fac1 = RGeo::Cartesian.preferred_factory(srid: 4326)
    fac2 = RGeo::Cartesian.preferred_factory(srid: 4055)

    point = fac1.point(1, 2)
    assert_raises(NotImplementedError) do
      RGeo::Feature.cast(point, factory: fac2, project: true)
    end
  end

  def test_cast_with_implemented_coordinate_transform
    cs1 = TestAffineCoordinateSystem.create(0)
    cs2 = TestAffineCoordinateSystem.create(10)

    fac1 = RGeo::Cartesian.preferred_factory(coord_sys: cs1)
    fac2 = RGeo::Cartesian.preferred_factory(coord_sys: cs2)

    point1 = fac1.point(1, 2)
    point2 = RGeo::Feature.cast(point1, factory: fac2, project: true)

    assert_equal(point2.x, 11)
    assert_equal(point2.y, 12)
  end

  def test_geometry_transform
    cs1 = TestAffineCoordinateSystem.create(0)
    cs2 = TestAffineCoordinateSystem.create(10)

    fac1 = RGeo::Cartesian.preferred_factory(coord_sys: cs1)
    fac2 = RGeo::Cartesian.preferred_factory(coord_sys: cs2)

    point1 = fac1.point(1, 2)
    point2 = point1.transform(fac2)

    assert_equal(point2.x, 11)
    assert_equal(point2.y, 12)
  end

  def test_cast_point_to_same_type
    # geom is a RGeo::Geos::CAPIPointImpl
    geom = wkt_parser.parse("POINT(1 2)")
    point = RGeo::Feature.cast(geom, RGeo::Feature::Point)
    assert RGeo::Feature::Point.check_type(point)
    assert_wkt_similar "POINT (1.0 2.0)", point.to_s
  end

  def test_cast_linestring_to_line
    # only works with 2-point linestrings
    linestring = wkt_parser.parse("LINESTRING(1 2, 3 4)")
    line = RGeo::Feature.cast(linestring, RGeo::Feature::Line)
    assert RGeo::Feature::Line.check_type(line)
    assert_wkt_similar "LINESTRING (1.0 2.0, 3.0 4.0)", line.to_s
  end

  def test_cast_collection_to_multipoint
    p1 = factory.point(0, 0)
    p2 = factory.point(1, 1)
    collection = factory.collection([p1, p2])
    multipoint = RGeo::Feature.cast(collection, RGeo::Feature::MultiPoint)
    assert RGeo::Feature::MultiPoint.check_type(multipoint)
    assert_wkt_similar "MULTIPOINT ((0.0 0.0), (1.0 1.0))", multipoint.to_s
  end

  private

  def wkt_parser
    RGeo::WKRep::WKTParser.new
  end

  def factory
    RGeo::Cartesian.preferred_factory
  end
end

# Basic test class where transformations will translate
# based on difference between "value" attribute
class TestAffineCoordinateSystem < RGeo::CoordSys::CS::CoordinateSystem
  def initialize(value, dimension, *optional)
    super(value, dimension, *optional)
    @value = value
  end
  attr_accessor :value

  def transform_coords(target_cs, x, y, z = nil)
    ct = TestAffineCoordinateTransform.create(self, target_cs)
    ct.transform_coords(x, y, z)
  end

  class << self
    def create(value, dimension = 2)
      new(value, dimension)
    end
  end
end

class TestAffineCoordinateTransform < RGeo::CoordSys::CS::CoordinateTransform
  def transform_coords(x, y, z = nil)
    diff = target_cs.value - source_cs.value
    coords = [x + diff, y + diff]
    coords << (z + diff) if z
    coords
  end
end
