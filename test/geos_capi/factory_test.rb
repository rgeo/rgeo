# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS factory
#
# -----------------------------------------------------------------------------

require "test_helper"

if RGeo::Geos.capi_supported?
  class GeosFactoryTest < Minitest::Test # :nodoc:
    include RGeo::Tests::Common::FactoryTests

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
end
