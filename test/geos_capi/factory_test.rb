# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS factory
#
# -----------------------------------------------------------------------------

require "test_helper"
require_relative "skip_capi"

class GeosFactoryTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::FactoryTests
  prepend SkipCAPI

  def setup
    @factory = RGeo::Geos.factory(srid: 1000)
    @srid = 1000
  end

  def test_is_geos_factory
    assert_equal(true, RGeo::Geos.geos?(@factory))
    assert_equal(true, RGeo::Geos.capi_geos?(@factory))
    assert_equal(false, RGeo::Geos.ffi_geos?(@factory))
  end
end
