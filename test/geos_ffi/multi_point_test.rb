# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS multi point implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class GeosFFIMultiPointTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::MultiPointTests

  def setup
    skip "Needs GEOS FFI." unless RGeo::Geos.ffi_supported?

    super
  end

  def create_factory(opts = {})
    RGeo::Geos.factory(opts.merge(native_interface: :ffi))
  end
end
