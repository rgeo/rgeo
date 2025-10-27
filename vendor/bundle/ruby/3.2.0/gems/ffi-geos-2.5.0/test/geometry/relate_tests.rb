# frozen_string_literal: true

require 'test_helper'

class GeometryRelateTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_relate
    tester = lambda { |expected, geom_a, geom_b|
      assert_equal(expected, geom_a.relate(geom_b))
    }

    geom_a = read('POINT(0 0)')
    geom_b = read('POINT(0 0)')
    tester['0FFFFFFF2', geom_a, geom_b]

    geom_a = read('POINT(0 0)')
    geom_b = read('POINT(1 0)')
    tester['FF0FFF0F2', geom_a, geom_b]

    geom_a = read('POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))')
    geom_b = read('POINT(1 0)')
    tester['FF20F1FF2', geom_a, geom_b]
  end

  def test_relate_pattern
    tester = lambda { |pattern, geom_a, geom_b, expected|
      assert_equal(expected, geom_a.relate_pattern(geom_b, pattern))
    }

    geom_a = read('POINT(0 0)')
    geom_b = read('POINT(0 0)')
    tester['0FFFFFFF2', geom_a, geom_b, true]
    tester['0*******T', geom_a, geom_b, true]
    tester['0*******1', geom_a, geom_b, false]

    geom_a = read('POINT(0 0)')
    geom_b = read('POINT(1 0)')
    tester['FF0FFF0F2', geom_a, geom_b, true]
    tester['F*******2', geom_a, geom_b, true]
    tester['T*******2', geom_a, geom_b, false]

    geom_a = read('POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))')
    geom_b = read('POINT(1 0)')
    tester['FF20F1FF2', geom_a, geom_b, true]
    tester['F****T**T', geom_a, geom_b, true]
    tester['T*******2', geom_a, geom_b, false]
  end

  def test_relate_boundary_node_rule
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:relate_boundary_node_rule)

    geom_a = read('LINESTRING(0 0, 2 4, 5 5, 0 0)')
    geom_b = read('POINT(0 0)')

    ret = geom_a.relate_boundary_node_rule(geom_b, :ogc)

    assert_equal('0F1FFFFF2', ret)

    ret = geom_a.relate_boundary_node_rule(geom_b, :endpoint)

    assert_equal('FF10FFFF2', ret)

    assert_raises(TypeError) do
      geom_a.relate_boundary_node_rule(geom_b, :gibberish)
    end
  end
end
