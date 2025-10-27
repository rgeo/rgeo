# frozen_string_literal: true

require 'test_helper'

class GeometrySnapTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_snap
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:snap)

    geom = read('POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0))')
    simple_tester(:snap, 'POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0))', geom, read('POINT(0.1 0)'), 0)
    simple_tester(:snap, 'POLYGON ((0.1 0, 1 0, 1 1, 0 1, 0.1 0))', geom, read('POINT(0.1 0)'), 0.5)
  end
end
