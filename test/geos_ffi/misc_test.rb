# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for miscellaneous GEOS stuff
#
# -----------------------------------------------------------------------------

require "test_helper"

class GeosFFIMiscTest < Minitest::Test # :nodoc:
  def setup
    @factory = RGeo::Geos.factory(srid: 4326, native_interface: :ffi)
  end

  def test_empty_geometries_equal
    geom1 = @factory.collection([])
    geom2 = @factory.line_string([])
    assert(!geom1.eql?(geom2))
    assert(geom1.equals?(geom2))
  end

  def test_prepare
    p1 = @factory.point(1, 2)
    p2 = @factory.point(3, 4)
    p3 = @factory.point(5, 2)
    polygon = @factory.polygon(@factory.linear_ring([p1, p2, p3, p1]))
    assert_equal(false, polygon.prepared?)
    polygon.prepare!
    assert_equal(true, polygon.prepared?)
  end

  def test_auto_prepare
    p1 = @factory.point(1, 2)
    p2 = @factory.point(3, 4)
    p3 = @factory.point(5, 2)
    polygon = @factory.polygon(@factory.linear_ring([p1, p2, p3, p1]))
    assert_equal(false, polygon.prepared?)
    polygon.intersects?(p1)
    assert_equal(false, polygon.prepared?)
    polygon.intersects?(p2)
    assert_equal(true, polygon.prepared?)

    factory_no_auto_prepare =
      RGeo::Geos.factory(srid: 4326, native_interface: :ffi, auto_prepare: :disabled)
    polygon2 = factory_no_auto_prepare.polygon(
      factory_no_auto_prepare.linear_ring([p1, p2, p3, p1]))
    assert_equal(false, polygon2.prepared?)
    polygon2.intersects?(p1)
    assert_equal(false, polygon2.prepared?)
    polygon2.intersects?(p2)
    assert_equal(false, polygon2.prepared?)
  end

  def test_unary_union_simple_points
    p1 = @factory.point(1, 1)
    p2 = @factory.point(2, 2)
    mp = @factory.multi_point([p1, p2])
    collection = @factory.collection([p1, p2])
    geom = collection.unary_union
    if RGeo::Geos::Utils.ffi_supports_unary_union
      assert(geom.eql?(mp))
    else
      assert_equal(nil, geom)
    end
  end

  def test_unary_union_mixed_collection
    collection = @factory.parse_wkt("GEOMETRYCOLLECTION (POLYGON ((0 0, 0 90, 90 90, 90 0, 0 0)),   POLYGON ((120 0, 120 90, 210 90, 210 0, 120 0)),  LINESTRING (40 50, 40 140),  LINESTRING (160 50, 160 140),  POINT (60 50),  POINT (60 140),  POINT (40 140))")
    expected = @factory.parse_wkt("GEOMETRYCOLLECTION (POINT (60 140),   LINESTRING (40 90, 40 140), LINESTRING (160 90, 160 140), POLYGON ((0 0, 0 90, 40 90, 90 90, 90 0, 0 0)), POLYGON ((120 0, 120 90, 160 90, 210 90, 210 0, 120 0)))")
    geom = collection.unary_union
    if RGeo::Geos::Utils.ffi_supports_unary_union
      assert(geom.eql?(expected))
    else
      assert_equal(nil, geom)
    end
  end
end if RGeo::Geos.ffi_supported?

unless RGeo::Geos.ffi_supported?
  puts "WARNING: FFI-GEOS support not available. Related tests skipped."
end
