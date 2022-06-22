# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for miscellaneous GEOS stuff
#
# -----------------------------------------------------------------------------

require "ostruct"
require_relative "../test_helper"
require_relative "../common/validity_tests"

class GeosMiscTest < Minitest::Test # :nodoc:
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

    dump = @factory.marshal_dump
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

    @factory.encode_with(coder)
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

  def test_invalid_geometry_equal_itself
    geom = @factory.parse_wkt("MULTIPOLYGON (((0 0, 1 1, 1 0, 0 0)), ((0 0, 2 2, 2 0, 0 0)))")
    assert(geom.eql?(geom))
    assert(geom.equals?(geom))
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

  def test_geos_wkb_parser_inputs
    c_factory = RGeo::Geos::CAPIFactory.new(wkb_parser: :geos)
    binary_wkb = "\x00\x00\x00\x00\a\x00\x00\x00\a\x00\x00\x00\x00\x03\x00\x00\x00\x01\x00\x00\x00\x05\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00@V\x80\x00\x00\x00\x00\x00@V\x80\x00\x00\x00\x00\x00@V\x80\x00\x00\x00\x00\x00@V\x80\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x03\x00\x00\x00\x01\x00\x00\x00\x05@^\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00@^\x00\x00\x00\x00\x00\x00@V\x80\x00\x00\x00\x00\x00@j@\x00\x00\x00\x00\x00@V\x80\x00\x00\x00\x00\x00@j@\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00@^\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x02@D\x00\x00\x00\x00\x00\x00@I\x00\x00\x00\x00\x00\x00@D\x00\x00\x00\x00\x00\x00@a\x80\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x02@d\x00\x00\x00\x00\x00\x00@I\x00\x00\x00\x00\x00\x00@d\x00\x00\x00\x00\x00\x00@a\x80\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01@N\x00\x00\x00\x00\x00\x00@I\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01@N\x00\x00\x00\x00\x00\x00@a\x80\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01@D\x00\x00\x00\x00\x00\x00@a\x80\x00\x00\x00\x00\x00"
    wkt = @factory.parse_wkb(binary_wkb).as_text
    assert_equal(wkt, c_factory.parse_wkb(binary_wkb).as_text)

    hexidecimal_wkb = "00000000070000000700000000030000000100000005000000000000000000000000000000000000000000000000405680000000000040568000000000004056800000000000405680000000000000000000000000000000000000000000000000000000000000000000030000000100000005405e0000000000000000000000000000405e0000000000004056800000000000406a4000000000004056800000000000406a4000000000000000000000000000405e0000000000000000000000000000000000000200000002404400000000000040490000000000004044000000000000406180000000000000000000020000000240640000000000004049000000000000406400000000000040618000000000000000000001404e00000000000040490000000000000000000001404e0000000000004061800000000000000000000140440000000000004061800000000000"
    assert_equal(wkt, c_factory.parse_wkb(hexidecimal_wkb).as_text)
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
      # Note that here `.eql?` is not guaranteed on all GEOS implementation.
      assert(geom == expected)
    else
      assert_equal(nil, geom)
    end
  end

  def test_casting_dumb_objects
    assert_raises(TypeError) do
      RGeo::Geos.factory.point(1, 1).contains?(OpenStruct.new(factory: RGeo::Geos.factory))
    end
  end
end if RGeo::Geos.capi_supported?

unless RGeo::Geos.capi_supported?
  puts "WARNING: GEOS CAPI support not available. Related tests skipped."
end
