# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS point implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class GeosParsingUnparsingTest < Minitest::Test # :nodoc:
  def test_wkt_generator_default_floating_point
    # Bug report GH-4
    factory = RGeo::Geos.factory
    point = factory.point(111.99, -40.37)
    assert_equal("POINT (111.99 -40.37)", point.as_text)
  end

  def test_wkt_generator_downcase
    factory = RGeo::Geos.factory(wkt_generator: { convert_case: :lower })
    point = factory.point(1, 1)
    assert_equal("point (1.0 1.0)", point.as_text)
  end

  def test_wkt_generator_geos
    factory = RGeo::Geos.factory(wkt_generator: :geos)
    point = factory.point(1, 1)
    assert_equal("POINT (1.0000000000000000 1.0000000000000000)", point.as_text)
  end

  def test_wkt_parser_default_with_non_geosable_input
    factory = RGeo::Geos.factory
    assert(factory.parse_wkt("Point (1 1)"))
  end
end if RGeo::Geos.capi_supported?
