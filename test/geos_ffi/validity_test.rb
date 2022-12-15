# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS FFI validity implementation
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"
require_relative "skip_ffi"

class GeosFFIValidityTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::ValidityTests
  include SkipFFI

  def setup
    @factory = RGeo::Geos.factory(native_interface: :ffi)
  end
end
