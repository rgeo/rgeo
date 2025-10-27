# frozen_string_literal: true

require 'test_helper'

class GeometryProjectTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_project_and_project_normalized
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:project)

    geom_a = read('POINT(1 2)')
    geom_b = read('POINT(3 4)')

    # The method only accept lineal geometries
    assert_raises(Geos::GEOSException) do
      geom_a.project(geom_b)
    end

    geom_a = read('LINESTRING(0 0, 10 0)')
    geom_b = read('POINT(0 0)')

    assert_equal(0, geom_a.project(geom_b))
    assert_equal(0, geom_a.project(geom_b, true))
    assert_equal(0, geom_a.project_normalized(geom_b))

    geom_b = read('POINT(10 0)')

    assert_equal(10, geom_a.project(geom_b))
    assert_equal(1, geom_a.project(geom_b, true))
    assert_equal(1, geom_a.project_normalized(geom_b))

    geom_b = read('POINT(5 0)')

    assert_equal(5, geom_a.project(geom_b))
    assert_in_delta(0.5, geom_a.project(geom_b, true))
    assert_in_delta(0.5, geom_a.project_normalized(geom_b))

    geom_a = read('MULTILINESTRING((0 0, 10 0),(20 10, 20 20))')
    geom_b = read('POINT(20 0)')

    assert_equal(10, geom_a.project(geom_b))
    assert_in_delta(0.5, geom_a.project(geom_b, true))
    assert_in_delta(0.5, geom_a.project_normalized(geom_b))

    geom_b = read('POINT(20 5)')

    assert_equal(10, geom_a.project(geom_b))
    assert_in_delta(0.5, geom_a.project(geom_b, true))
    assert_in_delta(0.5, geom_a.project_normalized(geom_b))
  end
end
