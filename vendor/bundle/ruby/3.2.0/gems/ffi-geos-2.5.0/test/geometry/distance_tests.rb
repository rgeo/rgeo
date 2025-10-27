# frozen_string_literal: true

require 'test_helper'

class GeometryDistanceTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_distance
    geom = 'POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0))'
    simple_tester(:distance, 0.0, geom, read('POINT(0.5 0.5)'))
    simple_tester(:distance, 1.0, geom, read('POINT (-1 0)'))
    simple_tester(:distance, 2.0, geom, read('LINESTRING (3 0 , 10 0)'))
  end

  def test_distance_indexed
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:distance_indexed)

    geom_a = read('POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0))')
    geom_b = read('POLYGON ((20 30, 10 10, 13 14, 7 8, 20 30))')

    assert_in_delta(9.219544457292887, geom_a.distance_indexed(geom_b), TOLERANCE)
    assert_in_delta(9.219544457292887, geom_b.distance_indexed(geom_a), TOLERANCE)
  end
end
