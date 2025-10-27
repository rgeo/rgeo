# frozen_string_literal: true

require 'test_helper'

class GeometryNearestPointsTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_nearest_points
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:nearest_points)

    tester = lambda { |expected, g_1, g_2|
      geom_1 = read(g_1)
      geom_2 = read(g_2)

      cs = geom_1.nearest_points(geom_2)
      result = cs.to_s if cs

      if expected.nil?
        assert_nil(result)
      else
        assert_equal(expected, result)
      end
    }

    tester[
      nil,
      'POINT EMPTY',
      'POINT EMPTY'
    ]

    tester[
      if Geos::GEOS_NICE_VERSION >= '030800'
        '5.0 5.0, 8.0 8.0'
      else
        '5.0 5.0 NaN, 8.0 8.0 NaN'
      end,
      'POLYGON((1 1, 1 5, 5 5, 5 1, 1 1))',
      'POLYGON((8 8, 9 9, 9 10, 8 8))'
    ]
  end
end
