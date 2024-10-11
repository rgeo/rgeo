# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the Simple Mercator validity implementation
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"
require_relative "../common/validity_tests"

class MercatorValidityTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::ValidityTests

  def setup
    @factory = RGeo::Geographic.simple_mercator_factory
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

  # Taken from RGeo::Tests::Common::ValidityTests, but adapted to have a
  # correct area.
  def square_polygon_expected_area
    12_392_658_216.374474
  end
end
