# frozen_string_literal: true

require 'test_helper'

class GeometryLargestEmptyCircleTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_largest_empty_circle
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:largest_empty_circle)

    geom = read('MULTIPOINT ((100 100), (100 200), (200 200), (200 100))')
    output = geom.largest_empty_circle(0.001)

    assert_equal('LINESTRING (150 150, 100 100)', write(output))

    geom = read('MULTIPOINT ((100 100), (100 200), (200 200), (200 100))')
    output = geom.largest_empty_circle(0.001, boundary: read('MULTIPOINT ((100 100), (100 200), (200 200), (200 100))'))

    assert_equal('LINESTRING (100 100, 100 100)', write(output))
  end
end
