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

  # GEOS 3.14+ features

  def test_simple_detail_for_simple_geometry
    line = @factory.parse_wkt("LINESTRING(0 0, 1 1, 2 2)")
    skip "GEOS 3.14+ required" unless line.respond_to?(:simple_detail)

    assert line.simple?
    assert_nil line.simple_detail
  end

  def test_simple_detail_for_non_simple_geometry
    # Self-intersecting line (figure 8 shape)
    line = @factory.parse_wkt("LINESTRING(0 0, 2 2, 0 2, 2 0)")
    skip "GEOS 3.14+ required" unless line.respond_to?(:simple_detail)

    refute line.simple?

    detail = line.simple_detail
    assert_instance_of RGeo::Geos::CAPIPointImpl, detail
    # The intersection point should be at (1, 1)
    assert_in_delta 1.0, detail.x, 0.001
    assert_in_delta 1.0, detail.y, 0.001
  end

  def test_simple_detail_for_point
    point = @factory.point(1, 2)
    skip "GEOS 3.14+ required" unless point.respond_to?(:simple_detail)

    assert point.simple?
    assert_nil point.simple_detail
  end
end
