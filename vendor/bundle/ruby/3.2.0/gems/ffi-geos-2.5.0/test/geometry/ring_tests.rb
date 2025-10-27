# frozen_string_literal: true

require 'test_helper'

class GeometryRingTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_ring
    refute_geom_ring(read('POINT(0 0)'))
    refute_geom_ring(read('LINESTRING(0 0, 10 0, 5 5, 5 -5)'))
    assert_geom_ring(read('LINESTRING(0 0, 10 0, 5 5, 0 0)'))
  end
end
