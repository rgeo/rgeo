# frozen_string_literal: true

require 'test_helper'

class GeometryConvexHullTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_convex_hull
    geom = read('POINT(0 0)')

    assert_geom_eql_exact(read('POINT(0 0)'), geom.convex_hull)

    geom = read('LINESTRING(0 0, 10 10)')

    assert_geom_eql_exact(read('LINESTRING(0 0, 10 10)'), geom.convex_hull)

    geom = read('POLYGON((0 0, 0 10, 5 5, 10 10, 10 0, 0 0))')

    assert_geom_eql_exact(read('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))'), geom.convex_hull)
  end
end
