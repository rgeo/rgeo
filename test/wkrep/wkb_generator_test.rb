# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for WKT generator
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"

class WKBGeneratorTest < Minitest::Test # :nodoc:
  def setup
    @factory = RGeo::Cartesian.preferred_factory(srid: 1000)
    @factoryz = RGeo::Cartesian.preferred_factory(srid: 1000, has_z_coordinate: true)
    @factorym = RGeo::Cartesian.preferred_factory(srid: 1000, has_m_coordinate: true)
    @factoryzm = RGeo::Cartesian.preferred_factory(srid: 1000, has_z_coordinate: true, has_m_coordinate: true)
  end

  def test_point_basic_xdr
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true)
    obj = @factory.point(1, 2)
    assert_equal("00000000013ff00000000000004000000000000000", generator.generate(obj))
  end

  def test_point_basic_ndr
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true, little_endian: true)
    obj = @factory.point(1, 2)
    assert_equal("0101000000000000000000f03f0000000000000040", generator.generate(obj))
  end

  def test_point_2d_ewkb
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true, type_format: :ewkb)
    obj = @factory.point(1, 2)
    assert_equal("00000000013ff00000000000004000000000000000", generator.generate(obj))
  end

  def test_point_2d_wkb12
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true, type_format: :wkb12)
    obj = @factory.point(1, 2)
    assert_equal("00000000013ff00000000000004000000000000000", generator.generate(obj))
  end

  def test_point_2d_ewkb_with_srid
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true, type_format: :ewkb, emit_ewkb_srid: true)
    obj = @factory.point(1, 2)
    assert_equal("0020000001000003e83ff00000000000004000000000000000", generator.generate(obj))
  end

  def test_point_with_ewkb_z
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true, type_format: :ewkb)
    obj = @factoryz.point(1, 2, 3)
    assert_equal("00800000013ff000000000000040000000000000004008000000000000", generator.generate(obj))
  end

  def test_point_with_ewkb_m
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true, type_format: :ewkb)
    obj = @factorym.point(1, 2, 3)
    assert_equal("00400000013ff000000000000040000000000000004008000000000000", generator.generate(obj))
  end

  def test_point_with_ewkb_zm
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true, type_format: :ewkb)
    obj = @factoryzm.point(1, 2, 3, 4)
    assert_equal("00c00000013ff0000000000000400000000000000040080000000000004010000000000000", generator.generate(obj))
  end

  def test_point_with_wkb12_z
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true, type_format: :wkb12)
    obj = @factoryz.point(1, 2, 3)
    assert_equal("00000003e93ff000000000000040000000000000004008000000000000", generator.generate(obj))
  end

  def test_point_with_wkb12_m
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true, type_format: :wkb12)
    obj = @factorym.point(1, 2, 3)
    assert_equal("00000007d13ff000000000000040000000000000004008000000000000", generator.generate(obj))
  end

  def test_point_with_wkb12_zm
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true, type_format: :wkb12)
    obj = @factoryzm.point(1, 2, 3, 4)
    assert_equal("0000000bb93ff0000000000000400000000000000040080000000000004010000000000000", generator.generate(obj))
  end

  def test_linestring_basic
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true)
    obj = @factory.line_string([@factory.point(1, 2), @factory.point(3, 4), @factory.point(5, 6)])
    assert_equal("0000000002000000033ff000000000000040000000000000004008000000000000401000000000000040140000000000004018000000000000", generator.generate(obj))
  end

  def test_linestring_with_ewkb_z
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true, type_format: :ewkb)
    obj = @factoryz.line_string([@factoryz.point(1, 2, 3), @factoryz.point(4, 5, 6)])
    assert_equal("0080000002000000023ff000000000000040000000000000004008000000000000401000000000000040140000000000004018000000000000", generator.generate(obj))
  end

  def test_linestring_with_ewkb_z_and_srid
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true, type_format: :ewkb, emit_ewkb_srid: true)
    obj = @factoryz.line_string([@factoryz.point(1, 2, 3), @factoryz.point(4, 5, 6)])
    assert_equal("00a0000002000003e8000000023ff000000000000040000000000000004008000000000000401000000000000040140000000000004018000000000000", generator.generate(obj))
  end

  def test_linestring_with_wkb12_m
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true, type_format: :wkb12)
    obj = @factorym.line_string([@factorym.point(1, 2, 3), @factorym.point(4, 5, 6)])
    assert_equal("00000007d2000000023ff000000000000040000000000000004008000000000000401000000000000040140000000000004018000000000000", generator.generate(obj))
  end

  def test_linestring_empty
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true)
    obj = @factory.line_string([])
    assert_equal("000000000200000000", generator.generate(obj))
  end

  def test_polygon_basic
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true)
    obj = @factory.polygon(@factory.linear_ring([@factory.point(1, 2), @factory.point(3, 4), @factory.point(6, 5), @factory.point(1, 2)]))
    assert_equal("000000000300000001000000043ff0000000000000400000000000000040080000000000004010000000000000401800000000000040140000000000003ff00000000000004000000000000000", generator.generate(obj))
  end

  def test_polygon_empty
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true)
    obj = @factory.polygon(@factory.linear_ring([]))
    assert_equal("000000000300000000", generator.generate(obj))
  end

  def test_multipoint_basic
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true)
    obj = @factory.multi_point([@factory.point(1, 2), @factory.point(3, 4)])
    assert_equal("00000000040000000200000000013ff00000000000004000000000000000000000000140080000000000004010000000000000", generator.generate(obj))
  end

  def test_multipoint_with_ewkb_z
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true, type_format: :ewkb)
    obj = @factoryz.multi_point([@factoryz.point(1, 2, 5), @factoryz.point(3, 4, 6)])
    assert_equal("00800000040000000200800000013ff0000000000000400000000000000040140000000000000080000001400800000000000040100000000000004018000000000000", generator.generate(obj))
  end

  def test_multipoint_empty
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true)
    obj = @factory.multi_point([])
    assert_equal("000000000400000000", generator.generate(obj))
  end

  def test_multilinestring_basic
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true)
    obj = @factory.multi_line_string([@factory.line_string([@factory.point(1, 2), @factory.point(3, 4), @factory.point(5, 6)]), @factory.line_string([@factory.point(-1, -2), @factory.point(-3, -4)])])
    assert_equal("0000000005000000020000000002000000033ff000000000000040000000000000004008000000000000401000000000000040140000000000004018000000000000000000000200000002bff0000000000000c000000000000000c008000000000000c010000000000000", generator.generate(obj))
  end

  def test_multilinestring_empty
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true)
    obj = @factory.multi_line_string([])
    assert_equal("000000000500000000", generator.generate(obj))
  end

  def test_multipolygon_basic
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true)
    obj = @factory.multi_polygon([@factory.polygon(@factory.linear_ring([@factory.point(1, 2), @factory.point(3, 4), @factory.point(6, 5), @factory.point(1, 2)])), @factory.polygon(@factory.linear_ring([]))])
    assert_equal("000000000600000002000000000300000001000000043ff0000000000000400000000000000040080000000000004010000000000000401800000000000040140000000000003ff00000000000004000000000000000000000000300000000", generator.generate(obj))
  end

  def test_multipolygon_empty
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true)
    obj = @factory.multi_polygon([])
    assert_equal("000000000600000000", generator.generate(obj))
  end

  def test_collection_basic
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true)
    obj = @factory.collection([@factory.line_string([@factory.point(1, 2), @factory.point(3, 4), @factory.point(5, 6)]), @factory.point(-1, -2)])
    assert_equal("0000000007000000020000000002000000033ff0000000000000400000000000000040080000000000004010000000000000401400000000000040180000000000000000000001bff0000000000000c000000000000000", generator.generate(obj))
  end

  def test_collection_empty
    generator = RGeo::WKRep::WKBGenerator.new(hex_format: true)
    obj = @factory.collection([])
    assert_equal("000000000700000000", generator.generate(obj))
  end
end
