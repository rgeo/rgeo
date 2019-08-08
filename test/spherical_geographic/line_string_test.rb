# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the simple spherical line string implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class SphericalLineStringTest < Minitest::Test # :nodoc:
  def setup
    @factory = RGeo::Geographic.spherical_factory
  end

  include RGeo::Tests::Common::LineStringTests

  undef_method :test_fully_equal
  undef_method :test_geometrically_equal_but_different_type
  undef_method :test_geometrically_equal_but_different_type2
  undef_method :test_geometrically_equal_but_different_overlap
  undef_method :test_empty_equal
  undef_method :test_not_equal
  undef_method :test_point_on_surface
end
