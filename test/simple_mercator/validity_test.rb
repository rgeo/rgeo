# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the Simple Mercator validity implementation
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"

class MercatorValidityTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::ValidityTests

  def setup
    @factory = RGeo::Geographic.simple_mercator_factory
    @invalid_point = @factory.point(Float::INFINITY, 0)
    @point1 = @factory.point(0, 0)
    @point2 = @factory.point(1, 1)
    @point3 = @factory.point(0, 1)
    @point4 = @factory.point(1, 0)

    @point5 = @factory.point(-5, -5)
    @point6 = @factory.point(5, -5)
    @point7 = @factory.point(5, 5)
    @point8 = @factory.point(-5, 5)

    @big_square = @factory.linear_ring([@point5, @point6, @point7, @point8, @point5])
    @little_square = @factory.linear_ring([@point1, @point3, @point2, @point4, @point1])
  end

  # TODO: linear rings with invalid coordinates return nil from new
  undef_method :test_invalid_linear_ring_invalid_coordinate
end
