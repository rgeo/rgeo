# frozen_string_literal: true

require 'test_helper'

class GeometryEmptyTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_empty
    refute_geom_empty(read('POINT(0 0)'))
    assert_geom_empty(read('POINT EMPTY'))
    refute_geom_empty(read('LINESTRING(0 0, 10 0)'))
    assert_geom_empty(read('LINESTRING EMPTY'))
    refute_geom_empty(read('POLYGON((0 0, 10 0, 10 10, 0 0))'))
    assert_geom_empty(read('POLYGON EMPTY'))
    refute_geom_empty(read('GEOMETRYCOLLECTION(POINT(0 0))'))
    assert_geom_empty(read('GEOMETRYCOLLECTION EMPTY'))
  end
end
