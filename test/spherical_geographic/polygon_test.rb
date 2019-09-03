# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the simple spherical polygon implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class SphericalPolygonTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::PolygonTests

  def setup
    @factory = RGeo::Geographic.spherical_factory
  end

  undef_method :test_fully_equal
  undef_method :test_geometrically_equal_but_ordered_different
  undef_method :test_geometrically_equal_but_different_directions
  undef_method :test_point_on_surface

  def test_centroid
    point1 = @factory.point(0, 0)
    point2 = @factory.point(0, 1)
    point3 = @factory.point(1, 0)
    exterior = @factory.linear_ring([point1, point2, point3, point1])
    polygon = @factory.polygon(exterior)
    assert_equal @factory.point(1.0/3.0, 1.0/3.0), polygon.centroid
  end
end
