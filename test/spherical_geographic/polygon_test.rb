# -----------------------------------------------------------------------------
#
# Tests for the simple spherical polygon implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class SphericalPolygonTest < Test::Unit::TestCase # :nodoc:
  include RGeo::Tests::Common::PolygonTests

  def setup
    @factory = ::RGeo::Geographic.spherical_factory
  end

  undef_method :test_fully_equal
  undef_method :test_geometrically_equal_but_ordered_different
  undef_method :test_geometrically_equal_but_different_directions
end
