# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS multi line string implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class GeosMultiLineStringTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::MultiLineStringTests

  def create_factory
    @factory = RGeo::Geos.factory
  end

  def test_polygonize_two_rings
    polygon1_wkt = "POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))"
    polygon2_wkt = "POLYGON ((1 0, 1 1, 2 1, 2 0, 1 0))"

    expected = @factory.parse_wkt("GEOMETRYCOLLECTION(#{polygon1_wkt}, #{polygon2_wkt})")

    multi_line_string_wkt = "MULTILINESTRING( (1 1, 0 1, 0 0, 1 0), (1 -1, 1 0, 1 1, 1 2), (1 1, 2 1, 2 0, 1 0) )"
    multi_line_string = @factory.parse_wkt(multi_line_string_wkt)

    line_string_polygonized = multi_line_string.polygonize
    assert_equal expected, line_string_polygonized
  end
end if RGeo::Geos.capi_supported?
