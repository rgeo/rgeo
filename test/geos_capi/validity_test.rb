# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS validity implementation
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"
require_relative "skip_capi"

class GeosValidityTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::ValidityTests
  prepend SkipCAPI

  def setup
    @factory = RGeo::Geos.factory
  end

  def test_valid_linear_ring_invalid_reason_location
    lr = @factory.linear_ring([point1, point3, point2, point4, point1])
    assert_nil(lr.invalid_reason_location)
    assert_nil(lr.invalid_reason)
    assert(lr.valid?)
  end

  def test_invalid_polygon_self_intersecting_ring_invalid_reason_location
    hourglass = @factory.linear_ring([point1, point2, point3, point4, point1])
    poly = @factory.polygon(hourglass)
    assert_equal(@factory.point(0.5, 0.5), poly.invalid_reason_location)
    assert_equal(RGeo::Error::SELF_INTERSECTION, poly.invalid_reason)
    assert_equal(false, poly.valid?)
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
