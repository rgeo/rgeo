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

  def test_contains_not_point
    ml1 = @factory.multi_line_string([])
    ml2 = @factory.multi_line_string([])

    assert_raises(RGeo::Error::UnsupportedOperation) do
      ml1.contains?(ml2)
    end
  end

  undef_method :test_fully_equal
  undef_method :test_geometrically_equal
  undef_method :test_not_equal
  undef_method :test_point_on_surface
end
