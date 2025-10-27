# frozen_string_literal: true

require 'test_helper'

class GeometrySimpleTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_simple
    assert_geom_simple(read('POINT(0 0)'))
    assert_geom_simple(read('LINESTRING(0 0, 10 0)'))
    refute_geom_simple(read('LINESTRING(0 0, 10 0, 5 5, 5 -5)'))
  end
end
