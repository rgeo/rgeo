# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS multi point implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

if RGeo::Geos.ffi_supported?
  class GeosFFIMultiPointTest < Minitest::Test # :nodoc:
    include RGeo::Tests::Common::MultiPointTests

    def create_factory(opts = {})
      RGeo::Geos.factory(opts.merge(native_interface: :ffi))
    end
  end
end
