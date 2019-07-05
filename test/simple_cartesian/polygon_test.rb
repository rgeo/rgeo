# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the simple cartesian polygon implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class CartesianPolygonTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::PolygonTests

  def setup
    @factory = RGeo::Cartesian.simple_factory
  end

  undef_method :test_fully_equal
  undef_method :test_geometrically_equal_but_ordered_different
  undef_method :test_geometrically_equal_but_different_directions
  undef_method :test_point_on_surface
end
