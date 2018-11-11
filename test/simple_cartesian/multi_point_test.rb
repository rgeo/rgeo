# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the simple cartesian multi point implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class CartesianMultiPointTest < Test::Unit::TestCase # :nodoc:
  include RGeo::Tests::Common::MultiPointTests

  def create_factory(opts = {})
    @factory = RGeo::Cartesian.simple_factory(opts)
  end

  undef_method :test_fully_equal
  undef_method :test_geometrically_equal
  undef_method :test_not_equal
  undef_method :test_union
  undef_method :test_difference
  undef_method :test_intersection
end
