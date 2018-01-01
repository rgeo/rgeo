# -----------------------------------------------------------------------------
#
# Tests for the simple spherical multi point implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class SphericalMultiPointTest < Test::Unit::TestCase # :nodoc:
  include RGeo::Tests::Common::MultiPointTests

  def create_factory(opts_ = {})
    @factory = ::RGeo::Geographic.spherical_factory(opts_)
  end

  undef_method :test_fully_equal
  undef_method :test_geometrically_equal
  undef_method :test_not_equal
  undef_method :test_union
  undef_method :test_difference
  undef_method :test_intersection
end
