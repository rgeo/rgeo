# frozen_string_literal: true

require 'test_helper'

class GeometryFrechetDistanceTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_frechet_distance
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:frechet_distance)

    assert_in_delta(read('LINESTRING (0 0, 100 0)').frechet_distance(read('LINESTRING (0 0, 50 50, 100 0)')), 70.7106781186548, TOLERANCE)
  end

  def test_frechet_distance_with_densify
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:frechet_distance)

    assert_in_delta(read('LINESTRING (0 0, 100 0)').frechet_distance(read('LINESTRING (0 0, 50 50, 100 0)'), 0.5), 50.0, TOLERANCE)
  end
end
