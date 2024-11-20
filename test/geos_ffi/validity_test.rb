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

  def test_invalid_polygon_duplicate_rings
    poly = @factory.polygon(big_square, [little_square, little_square])

    if geos_version_match(">= 3.10.0")
      assert_equal(RGeo::Error::SELF_INTERSECTION, poly.invalid_reason)
    else
      assert_equal(RGeo::Error::DUPLICATE_RINGS, poly.invalid_reason)
    end
    assert_equal(false, poly.valid?)
  end
end
