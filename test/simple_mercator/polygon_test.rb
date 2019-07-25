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

  # These tests suffer from floating point issues
  undef_method :test_point_on_surface
  undef_method :test_boundary_one_hole
end
