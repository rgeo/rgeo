# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for WKT generator
#
# -----------------------------------------------------------------------------

require "test_helper"

class WKTGeneratorTest < Minitest::Test # :nodoc:
  def setup
    @factory = RGeo::Cartesian.preferred_factory(srid: 1000)
    @factoryz = RGeo::Cartesian.preferred_factory(srid: 1000, has_z_coordinate: true)
    @factorym = RGeo::Cartesian.preferred_factory(srid: 1000, has_m_coordinate: true)
    @factoryzm = RGeo::Cartesian.preferred_factory(srid: 1000, has_z_coordinate: true, has_m_coordinate: true)
  end

  def test_point_2d
    generator = RGeo::WKRep::WKTGenerator.new
    obj = @factory.point(1, 2)
    assert_equal("Point (1.0 2.0)", generator.generate(obj))
  end

  def test_point_z
    generator = RGeo::WKRep::WKTGenerator.new
    obj = @factoryz.point(1, 2, 3)
    assert_equal("Point (1.0 2.0 3.0)", generator.generate(obj))
  end

  def test_point_z_wkt11strict
    generator = RGeo::WKRep::WKTGenerator.new(tag_format: :wkt11_strict)
    obj = @factoryz.point(1, 2, 3)
    assert_equal("Point (1.0 2.0)", generator.generate(obj))
  end

  def test_point_m
    generator = RGeo::WKRep::WKTGenerator.new
    obj = @factorym.point(1, 2, 3)
    assert_equal("Point (1.0 2.0 3.0)", generator.generate(obj))
  end

  def test_point_zm
    generator = RGeo::WKRep::WKTGenerator.new
    obj = @factoryzm.point(1, 2, 3, 4)
    assert_equal("Point (1.0 2.0 3.0 4.0)", generator.generate(obj))
  end

  def test_point_squarebrackets
    generator = RGeo::WKRep::WKTGenerator.new(square_brackets: true)
    obj = @factory.point(1, 2)
    assert_equal("Point [1.0 2.0]", generator.generate(obj))
  end

  def test_point_uppercase
    generator = RGeo::WKRep::WKTGenerator.new(convert_case: :upper)
    obj = @factory.point(1, 2)
    assert_equal("POINT (1.0 2.0)", generator.generate(obj))
  end

  def test_point_lowercase
    generator = RGeo::WKRep::WKTGenerator.new(convert_case: :lower)
    obj = @factory.point(1, 2)
    assert_equal("point (1.0 2.0)", generator.generate(obj))
  end

  def test_point_wkt12
    generator = RGeo::WKRep::WKTGenerator.new(tag_format: :wkt12)
    obj = @factory.point(1, 2)
    assert_equal("Point (1.0 2.0)", generator.generate(obj))
  end

  def test_point_wkt12_z
    generator = RGeo::WKRep::WKTGenerator.new(tag_format: :wkt12)
    obj = @factoryz.point(1, 2, 3)
    assert_equal("Point Z (1.0 2.0 3.0)", generator.generate(obj))
  end

  def test_point_wkt12_m
    generator = RGeo::WKRep::WKTGenerator.new(tag_format: :wkt12)
    obj = @factorym.point(1, 2, 3)
    assert_equal("Point M (1.0 2.0 3.0)", generator.generate(obj))
  end

  def test_point_wkt12_zm
    generator = RGeo::WKRep::WKTGenerator.new(tag_format: :wkt12)
    obj = @factoryzm.point(1, 2, 3, 4)
    assert_equal("Point ZM (1.0 2.0 3.0 4.0)", generator.generate(obj))
  end

  def test_point_ewkt
    generator = RGeo::WKRep::WKTGenerator.new(tag_format: :ewkt)
    obj = @factory.point(1, 2)
    assert_equal("Point (1.0 2.0)", generator.generate(obj))
  end

  def test_point_ewkt_z
    generator = RGeo::WKRep::WKTGenerator.new(tag_format: :ewkt)
    obj = @factoryz.point(1, 2, 3)
    assert_equal("Point (1.0 2.0 3.0)", generator.generate(obj))
  end

  def test_point_ewkt_m
    generator = RGeo::WKRep::WKTGenerator.new(tag_format: :ewkt)
    obj = @factorym.point(1, 2, 3)
    assert_equal("PointM (1.0 2.0 3.0)", generator.generate(obj))
  end

  def test_point_ewkt_zm
    generator = RGeo::WKRep::WKTGenerator.new(tag_format: :ewkt)
    obj = @factoryzm.point(1, 2, 3, 4)
    assert_equal("Point (1.0 2.0 3.0 4.0)", generator.generate(obj))
  end

  def test_point_ewkt_with_srid
    generator = RGeo::WKRep::WKTGenerator.new(tag_format: :ewkt, emit_ewkt_srid: true)
    obj = @factory.point(1, 2)
    assert_equal("SRID=1000;Point (1.0 2.0)", generator.generate(obj))
  end

  def test_linestring_basic
    generator = RGeo::WKRep::WKTGenerator.new
    p1 = @factory.point(1, 2)
    p2 = @factory.point(2, 2)
    p3 = @factory.point(1, 1)
    obj = @factory.line_string([p1, p2, p3])
    assert_equal("LineString (1.0 2.0, 2.0 2.0, 1.0 1.0)", generator.generate(obj))
  end

  def test_linestring_empty
    generator = RGeo::WKRep::WKTGenerator.new
    obj = @factory.line_string([])
    assert_equal("LineString EMPTY", generator.generate(obj))
  end

  def test_polygon_basic
    generator = RGeo::WKRep::WKTGenerator.new
    p1 = @factory.point(0, 0)
    p2 = @factory.point(10, 0)
    p3 = @factory.point(10, 10)
    p4 = @factory.point(0, 10)
    ext = @factory.line_string([p1, p2, p3, p4, p1])
    obj = @factory.polygon(ext)
    assert_equal("Polygon ((0.0 0.0, 10.0 0.0, 10.0 10.0, 0.0 10.0, 0.0 0.0))", generator.generate(obj))
  end

  def test_polygon_with_hole
    generator = RGeo::WKRep::WKTGenerator.new
    p1 = @factory.point(0, 0)
    p2 = @factory.point(10, 0)
    p3 = @factory.point(10, 10)
    p4 = @factory.point(0, 10)
    p5 = @factory.point(1, 1)
    p6 = @factory.point(2, 2)
    p7 = @factory.point(3, 1)
    ext = @factory.line_string([p1, p2, p3, p4, p1])
    int = @factory.line_string([p5, p6, p7, p5])
    obj = @factory.polygon(ext, [int])
    assert_equal("Polygon ((0.0 0.0, 10.0 0.0, 10.0 10.0, 0.0 10.0, 0.0 0.0), (1.0 1.0, 2.0 2.0, 3.0 1.0, 1.0 1.0))", generator.generate(obj))
  end

  def test_polygon_empty
    generator = RGeo::WKRep::WKTGenerator.new
    obj = @factory.polygon(@factory.line_string([]))
    assert_equal("Polygon EMPTY", generator.generate(obj))
  end

  def test_multipoint_basic
    generator = RGeo::WKRep::WKTGenerator.new
    p1 = @factory.point(1, 2)
    p2 = @factory.point(2, 2)
    p3 = @factory.point(1, 1)
    obj = @factory.multi_point([p1, p2, p3])
    assert_equal("MultiPoint ((1.0 2.0), (2.0 2.0), (1.0 1.0))", generator.generate(obj))
  end

  def test_multipoint_empty
    generator = RGeo::WKRep::WKTGenerator.new
    obj = @factory.multi_point([])
    assert_equal("MultiPoint EMPTY", generator.generate(obj))
  end

  def test_multilinestring_basic
    generator = RGeo::WKRep::WKTGenerator.new
    p1 = @factory.point(0, 0)
    p2 = @factory.point(10, 0)
    p3 = @factory.point(10, 10)
    p4 = @factory.point(0, 10)
    p5 = @factory.point(1, 1)
    p6 = @factory.point(2, 2)
    p7 = @factory.point(3, 1)
    ls1 = @factory.line_string([p1, p2, p3, p4, p1])
    ls2 = @factory.line_string([p5, p6, p7])
    ls3 = @factory.line_string([])
    obj = @factory.multi_line_string([ls1, ls2, ls3])
    assert_equal("MultiLineString ((0.0 0.0, 10.0 0.0, 10.0 10.0, 0.0 10.0, 0.0 0.0), (1.0 1.0, 2.0 2.0, 3.0 1.0), EMPTY)", generator.generate(obj))
  end

  def test_multilinestring_empty
    generator = RGeo::WKRep::WKTGenerator.new
    obj = @factory.multi_line_string([])
    assert_equal("MultiLineString EMPTY", generator.generate(obj))
  end

  def test_multipolygon_basic
    generator = RGeo::WKRep::WKTGenerator.new
    p1 = @factory.point(0, 0)
    p2 = @factory.point(10, 0)
    p3 = @factory.point(10, 10)
    p4 = @factory.point(0, 10)
    p5 = @factory.point(1, 1)
    p6 = @factory.point(2, 2)
    p7 = @factory.point(3, 1)
    p8 = @factory.point(20, 20)
    p9 = @factory.point(30, 20)
    p10 = @factory.point(30, 30)
    p11 = @factory.point(20, 30)
    ext1 = @factory.line_string([p1, p2, p3, p4, p1])
    int1 = @factory.line_string([p5, p6, p7, p5])
    ext3 = @factory.line_string([p8, p9, p10, p11, p8])
    poly1 = @factory.polygon(ext1, [int1])
    poly2 = @factory.polygon(@factory.line_string([]))
    poly3 = @factory.polygon(ext3)
    obj = @factory.multi_polygon([poly1, poly2, poly3])
    assert_equal("MultiPolygon (((0.0 0.0, 10.0 0.0, 10.0 10.0, 0.0 10.0, 0.0 0.0), (1.0 1.0, 2.0 2.0, 3.0 1.0, 1.0 1.0)), EMPTY, ((20.0 20.0, 30.0 20.0, 30.0 30.0, 20.0 30.0, 20.0 20.0)))", generator.generate(obj))
  end

  def test_multipolygon_empty
    generator = RGeo::WKRep::WKTGenerator.new
    obj = @factory.multi_polygon([])
    assert_equal("MultiPolygon EMPTY", generator.generate(obj))
  end

  def test_collection_basic
    generator = RGeo::WKRep::WKTGenerator.new
    p1 = @factory.point(0, 0)
    p2 = @factory.point(10, 0)
    p3 = @factory.point(10, 10)
    p4 = @factory.point(0, 10)
    p5 = @factory.point(1, 1)
    p6 = @factory.point(2, 2)
    p7 = @factory.point(3, 1)
    p8 = @factory.point(20, 20)
    p9 = @factory.point(30, 20)
    p10 = @factory.point(30, 30)
    p11 = @factory.point(20, 30)
    ext1 = @factory.line_string([p1, p2, p3, p4, p1])
    int1 = @factory.line_string([p5, p6, p7, p5])
    ext3 = @factory.line_string([p8, p9, p10, p11, p8])
    poly1 = @factory.polygon(ext1, [int1])
    poly2 = @factory.polygon(@factory.line_string([]))
    poly3 = @factory.polygon(ext3)
    obj1 = @factory.multi_polygon([poly1, poly2, poly3])
    obj2 = @factory.point(1, 2)
    obj = @factory.collection([obj1, obj2])
    assert_equal("GeometryCollection (MultiPolygon (((0.0 0.0, 10.0 0.0, 10.0 10.0, 0.0 10.0, 0.0 0.0), (1.0 1.0, 2.0 2.0, 3.0 1.0, 1.0 1.0)), EMPTY, ((20.0 20.0, 30.0 20.0, 30.0 30.0, 20.0 30.0, 20.0 20.0))), Point (1.0 2.0))", generator.generate(obj))
  end

  def test_collection_wkt12_z
    generator = RGeo::WKRep::WKTGenerator.new(tag_format: :wkt12)
    p1 = @factoryz.point(0, 0)
    p2 = @factoryz.point(10, 0)
    p3 = @factoryz.point(10, 10)
    p4 = @factoryz.point(0, 10)
    p5 = @factoryz.point(1, 1)
    p6 = @factoryz.point(2, 2)
    p7 = @factoryz.point(3, 1)
    p8 = @factoryz.point(20, 20)
    p9 = @factoryz.point(30, 20)
    p10 = @factoryz.point(30, 30)
    p11 = @factoryz.point(20, 30)
    ext1 = @factoryz.line_string([p1, p2, p3, p4, p1])
    int1 = @factoryz.line_string([p5, p6, p7, p5])
    ext3 = @factoryz.line_string([p8, p9, p10, p11, p8])
    poly1 = @factoryz.polygon(ext1, [int1])
    poly2 = @factoryz.polygon(@factory.line_string([]))
    poly3 = @factoryz.polygon(ext3)
    obj1 = @factoryz.multi_polygon([poly1, poly2, poly3])
    obj2 = @factoryz.point(1, 2, 3)
    obj = @factoryz.collection([obj1, obj2])
    assert_equal("GeometryCollection Z (MultiPolygon Z (((0.0 0.0 0.0, 10.0 0.0 0.0, 10.0 10.0 0.0, 0.0 10.0 0.0, 0.0 0.0 0.0), (1.0 1.0 0.0, 2.0 2.0 0.0, 3.0 1.0 0.0, 1.0 1.0 0.0)), EMPTY, ((20.0 20.0 0.0, 30.0 20.0 0.0, 30.0 30.0 0.0, 20.0 30.0 0.0, 20.0 20.0 0.0))), Point Z (1.0 2.0 3.0))", generator.generate(obj))
  end

  def test_collection_empty
    generator = RGeo::WKRep::WKTGenerator.new
    obj = @factory.collection([])
    assert_equal("GeometryCollection EMPTY", generator.generate(obj))
  end
end
