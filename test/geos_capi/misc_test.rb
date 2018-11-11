# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for miscellaneous GEOS stuff
#
# -----------------------------------------------------------------------------

require "test_helper"

class GeosMiscTest < Test::Unit::TestCase # :nodoc:
  def setup
    @factory = RGeo::Geos.factory(srid: 4326)
  end

  def test_marshal_dump_with_geos
    @factory = RGeo::Geos.factory(
      srid: 4326,
      wkt_generator: :geos,
      wkb_generator: :geos,
      wkt_parser: :geos,
      wkb_parser: :geos
    )

    dump = nil
    assert_nothing_raised { dump = @factory.marshal_dump }
    assert_equal({}, dump["wktg"])
    assert_equal({}, dump["wkbg"])
    assert_equal({}, dump["wktp"])
    assert_equal({}, dump["wkbp"])
  end

  def test_encode_with_geos
    @factory = RGeo::Geos.factory(
      srid: 4326,
      wkt_generator: :geos,
      wkb_generator: :geos,
      wkt_parser: :geos,
      wkb_parser: :geos
    )
    coder = Psych::Coder.new("test")

    assert_nothing_raised { @factory.encode_with(coder) }
    assert_equal({}, coder["wkt_generator"])
    assert_equal({}, coder["wkb_generator"])
    assert_equal({}, coder["wkt_parser"])
    assert_equal({}, coder["wkb_parser"])
  end

  def test_uninitialized
    geom = RGeo::Geos::CAPIGeometryImpl.new
    assert_equal(false, geom.initialized?)
    assert_nil(geom.geometry_type)
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

    factory_no_auto_prepare = RGeo::Geos.factory(srid: 4326, auto_prepare: :disabled)
    polygon2 = factory_no_auto_prepare.polygon(
      factory_no_auto_prepare.linear_ring([p1, p2, p3, p1]))
    assert_equal(false, polygon2.prepared?)
    polygon2.intersects?(p1)
    assert_equal(false, polygon2.prepared?)
    polygon2.intersects?(p2)
    assert_equal(false, polygon2.prepared?)
  end

  def test_gh_21
    # Test for GH-21 (seg fault in rgeo_convert_to_geos_geometry)
    # This seemed to fail under Ruby 1.8.7 only.
    f = RGeo::Geographic.simple_mercator_factory
    loc = f.line_string([f.point(-123, 37), f.point(-122, 38)])
    f2 = f.projection_factory
    loc2 = f2.line_string([f2.point(-123, 37), f2.point(-122, 38)])
    loc2.intersection(loc)
  end

  def test_geos_version
    assert_match(/^\d+\.\d+(\.\d+)?$/, RGeo::Geos.version)
  end

  def test_unary_union_simple_points
    p1 = @factory.point(1, 1)
    p2 = @factory.point(2, 2)
    mp = @factory.multi_point([p1, p2])
    collection = @factory.collection([p1, p2])
    geom = collection.unary_union
    if RGeo::Geos::CAPIFactory._supports_unary_union?
      assert(geom.eql?(mp))
    else
      assert_equal(nil, geom)
    end
  end

  def test_unary_union_mixed_collection
    collection = @factory.parse_wkt("GEOMETRYCOLLECTION (POLYGON ((0 0, 0 90, 90 90, 90 0, 0 0)),   POLYGON ((120 0, 120 90, 210 90, 210 0, 120 0)),  LINESTRING (40 50, 40 140),  LINESTRING (160 50, 160 140),  POINT (60 50),  POINT (60 140),  POINT (40 140))")
    expected = @factory.parse_wkt("GEOMETRYCOLLECTION (POINT (60 140),   LINESTRING (40 90, 40 140), LINESTRING (160 90, 160 140), POLYGON ((0 0, 0 90, 40 90, 90 90, 90 0, 0 0)), POLYGON ((120 0, 120 90, 160 90, 210 90, 210 0, 120 0)))")
    geom = collection.unary_union
    if RGeo::Geos::CAPIFactory._supports_unary_union?
      assert(geom.eql?(expected))
    else
      assert_equal(nil, geom)
    end
  end
end if RGeo::Geos.capi_supported?

unless RGeo::Geos.capi_supported?
  puts "WARNING: GEOS CAPI support not available. Related tests skipped."
end
