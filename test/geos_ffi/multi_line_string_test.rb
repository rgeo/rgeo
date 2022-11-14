# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS multi line string implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class GeosFFIMultiLineStringTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::MultiLineStringTests

  def setup
    skip "Needs GEOS FFI." unless RGeo::Geos.ffi_supported?

    super
  end

  def create_factory
    RGeo::Geos.factory(native_interface: :ffi)
  end
end
