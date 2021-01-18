# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the simple cartesian multi polygon implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class CartesianMultiPolygonTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::MultiPolygonTests

  def create_factories
    @factory = RGeo::Cartesian.simple_factory
    @lenient_factory = RGeo::Cartesian.simple_factory(lenient_multi_polygon_assertions: true)
  end

  def test_contains_not_point
    point1 = @factory.point(0, 0)
    point2 = @factory.point(0, 10)
    point3 = @factory.point(10, 10)
    point4 = @factory.point(10, 0)
    ring = @factory.linear_ring([point1, point2, point3, point4, point1])
    polygon = @factory.polygon(ring)

    assert_raises(RGeo::Error::UnsupportedOperation) do
      polygon.contains?(ring)
    end
  end

  undef_method :test_creation_wrong_type
  undef_method :test_creation_overlapping
  undef_method :test_creation_connected
  undef_method :test_equal
  undef_method :test_not_equal
  undef_method :test_point_on_surface
end
