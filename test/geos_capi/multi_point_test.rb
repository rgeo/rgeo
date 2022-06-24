# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS multi point implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class GeosMultiPointTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::MultiPointTests

  def create_factory(opts = {})
    RGeo::Geos.factory(opts)
  end

  def test_polygonize
    input = @factory.parse_wkt("MULTIPOINT ((1 1))")
    expected = @factory.parse_wkt("GEOMETRYCOLLECTION EMPTY")

    assert_equal expected, input.polygonize
  end
end if RGeo::Geos.capi_supported?
