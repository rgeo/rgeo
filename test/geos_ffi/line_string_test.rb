# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS line string implementation
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"

if RGeo::Geos.ffi_supported?
  class GeosFFILineStringTest < Minitest::Test # :nodoc:
    include RGeo::Tests::Common::LineStringTests

    def setup
      @factory = RGeo::Geos.factory(native_interface: :ffi)
    end
  end
end
