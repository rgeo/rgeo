# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the simple cartesian multi line string implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class CartesianMultiLineStringTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::MultiLineStringTests

  def create_factory
    @factory = RGeo::Cartesian.simple_factory
  end

  undef_method :test_fully_equal
  undef_method :test_geometrically_equal
  undef_method :test_not_equal
  undef_method :test_point_on_surface
end
