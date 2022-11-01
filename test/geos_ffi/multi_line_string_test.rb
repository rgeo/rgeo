# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS multi line string implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

if RGeo::Geos.ffi_supported?
  class GeosFFIMultiLineStringTest < Minitest::Test # :nodoc:
    include RGeo::Tests::Common::MultiLineStringTests

    def create_factory
      RGeo::Geos.factory(native_interface: :ffi)
    end
  end
end
