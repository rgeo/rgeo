# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS FFI validity implementation
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"

class GeosFFIValidityTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::ValidityTests

  def setup
    skip "Needs GEOS FFI." unless RGeo::Geos.ffi_supported?

    @factory = RGeo::Geos.factory(native_interface: :ffi)
  end
end
