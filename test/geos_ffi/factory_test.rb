# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS factory
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"
require_relative "skip_ffi"

class GeosFFIFactoryTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::FactoryTests
  include SkipFFI

  def setup
    @factory = RGeo::Geos.factory(srid: 1000, native_interface: :ffi)
    @srid = 1000
  end

  def test_is_geos_factory
    assert_equal(true, RGeo::Geos.geos?(@factory))
    assert_equal(false, RGeo::Geos.capi_geos?(@factory))
    assert_equal(true, RGeo::Geos.ffi_geos?(@factory))
  end
end
