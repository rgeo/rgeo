# frozen_string_literal: true

require 'test_helper'

class GeometryMinimumBoundingCircleTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_minimum_bounding_circle
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:minimum_bounding_circle)

    geom = read('LINESTRING(0 10, 0 20)')

    assert_equal(
      'POLYGON ((5 15, 5 14, 5 13, 4 12, 4 11, 3 11, 2 10, 1 10, 0 10, -1 10, -2 10, -3 11, -4 11, -4 12, -5 13, -5 14, -5 15, -5 16, -5 17, -4 18, -4 19, -3 19, -2 20, -1 20, 0 20, 1 20, 2 20, 3 19, 4 19, 4 18, 5 17, 5 16, 5 15))',
      write(geom.minimum_bounding_circle.snap_to_grid(1))
    )
  end
end
