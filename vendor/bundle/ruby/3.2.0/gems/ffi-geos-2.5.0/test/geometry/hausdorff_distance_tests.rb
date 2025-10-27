# frozen_string_literal: true

require 'test_helper'

class GeometryHausdorffDistanceTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_hausdorff_distance
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:hausdorff_distance)

    tester = lambda { |expected, g_1, g_2|
      geom_1 = read(g_1)
      geom_2 = read(g_2)

      assert_in_delta(expected, geom_1.hausdorff_distance(geom_2), TOLERANCE)
    }

    geom_a = 'POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0))'

    tester[10.0498756211209, geom_a, 'POINT(0 10)']
    tester[2.23606797749979, geom_a, 'POINT(-1 0)']
    tester[9.0, geom_a, 'LINESTRING (3 0 , 10 0)']
  end

  def test_hausdorff_distance_with_densify_fract
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:hausdorff_distance)

    tester = lambda { |expected, g_1, g_2|
      geom_1 = read(g_1)
      geom_2 = read(g_2)

      assert_in_delta(expected, geom_1.hausdorff_distance(geom_2, 0.001), TOLERANCE)
    }

    geom_a = 'POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0))'

    tester[10.0498756211209, geom_a, 'POINT(0 10)']
    tester[2.23606797749979, geom_a, 'POINT(-1 0)']
    tester[9.0, geom_a, 'LINESTRING (3 0 , 10 0)']
  end
end
