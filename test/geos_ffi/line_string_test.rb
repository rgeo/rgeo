# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS line string implementation
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"

class GeosFFILineStringTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::LineStringTests

  def setup
    skip "Needs GEOS FFI." unless RGeo::Geos.ffi_supported?

    @factory = RGeo::Geos.factory(native_interface: :ffi)
  end
end
