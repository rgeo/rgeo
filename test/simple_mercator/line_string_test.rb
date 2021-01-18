# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the simple mercator line string implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class MercatorLineStringTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::LineStringTests

  def setup
    @factory = RGeo::Geographic.simple_mercator_factory
  end

  # These tests suffer from floating point issues
  undef_method :test_point_on_surface
  undef_method :test_contains_point
end
