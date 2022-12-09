# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS point implementation
#
# -----------------------------------------------------------------------------

require "test_helper"
require_relative "skip_capi"

class GeosPointTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::PointTests
  prepend SkipCAPI

  def setup
    @factory = RGeo::Geos.factory(buffer_resolution: 8)
    @zfactory = RGeo::Geos.factory(has_z_coordinate: true)
    @mfactory = RGeo::Geos.factory(has_m_coordinate: true)
    @zmfactory = RGeo::Geos.factory(has_z_coordinate: true, has_m_coordinate: true)
  end

  def test_is_geos
    point = @factory.point(21, -22)
    assert_equal(true, RGeo::Geos.geos?(point))
    assert_equal(true, RGeo::Geos.capi_geos?(point))
    assert_equal(false, RGeo::Geos.ffi_geos?(point))
    point2 = @zmfactory.point(21, -22, 0, 0)
    assert_equal(true, RGeo::Geos.geos?(point2))
    assert_equal(true, RGeo::Geos.capi_geos?(point2))
    assert_equal(false, RGeo::Geos.ffi_geos?(point2))
  end

  def test_has_no_projection
    point = @factory.point(21, -22)
    assert(!point.respond_to?(:projection))
  end

  def test_srid
    point = @factory.point(11, 12)
    assert_equal(0, point.srid)
  end

  def test_distance
    point1 = @factory.point(11, 12)
    point2 = @factory.point(11, 12)
    point3 = @factory.point(13, 12)
    assert_equal(0, point1.distance(point2))
    assert_equal(2, point1.distance(point3))
  end

  def test_as_text_encoding
    factory = RGeo::Geos.factory(wkt_generator: :geos)
    point = factory.point(11, 12)
    assert_equal(Encoding::US_ASCII, point.as_text.encoding)
  end

  def test_as_binary_encoding
    factory = RGeo::Geos.factory(wkb_generator: :geos)
    point = factory.point(11, 12)
    assert_equal(Encoding::ASCII_8BIT, point.as_binary.encoding)
  end

  def test_polygonize
    input = @factory.parse_wkt("POINT (1 1)")
    expected = @factory.parse_wkt("GEOMETRYCOLLECTION EMPTY")

    assert_equal expected, input.polygonize
  end
end
