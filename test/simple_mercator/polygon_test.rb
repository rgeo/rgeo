# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the simple mercator polygon implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class MercatorPolygonTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::PolygonTests

  def setup
    @factory = RGeo::Geographic.simple_mercator_factory
  end

  def test_is_simple_validation_behavior
    # issue 218
    assert_raises RGeo::Error::InvalidGeometry do
      wkt = "POLYGON((0 0, 1 1, 1 0, 0 1, 0 0))"
      @factory.parse_wkt(wkt)
    end
  end

  # These tests suffer from floating point issues
  undef_method :test_point_on_surface
  undef_method :test_boundary_one_hole
end
