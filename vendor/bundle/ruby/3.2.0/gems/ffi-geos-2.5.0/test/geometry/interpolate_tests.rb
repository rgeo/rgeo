# frozen_string_literal: true

require 'test_helper'

class GeometryInterpolateTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_interpolate
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:interpolate)

    simple_tester(:interpolate, 'POINT (0 0)', 'LINESTRING(0 0, 10 0)', 0, false)
    simple_tester(:interpolate, 'POINT (0 0)', 'LINESTRING(0 0, 10 0)', 0, true)

    simple_tester(:interpolate, 'POINT (5 0)', 'LINESTRING(0 0, 10 0)', 5, false)
    simple_tester(:interpolate, 'POINT (5 0)', 'LINESTRING(0 0, 10 0)', 0.5, true)

    simple_tester(:interpolate, 'POINT (10 0)', 'LINESTRING(0 0, 10 0)', 20, false)
    simple_tester(:interpolate, 'POINT (10 0)', 'LINESTRING(0 0, 10 0)', 2, true)

    assert_raises(Geos::GEOSException) do
      read('POINT(1 2)').interpolate(0)
    end
  end

  def test_interpolate_normalized
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:interpolate_normalized)

    tester = lambda { |expected, g, d|
      geom = read(g)

      assert_equal(expected, write(geom.interpolate_normalized(d)))
    }

    writer.trim = true

    tester['POINT (0 0)', 'LINESTRING(0 0, 10 0)', 0]
    tester['POINT (5 0)', 'LINESTRING(0 0, 10 0)', 0.5]
    tester['POINT (10 0)', 'LINESTRING(0 0, 10 0)', 2]

    assert_raises(Geos::GEOSException) do
      read('POINT(1 2)').interpolate_normalized(0)
    end
  end
end
