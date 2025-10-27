# frozen_string_literal: true

require 'test_helper'

class GeometryNormalizeTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_normalize
    geom = read('POLYGON((0 0, 5 0, 5 5, 0 5, 0 0))')
    geom.normalize

    assert_equal('POLYGON ((0 0, 0 5, 5 5, 5 0, 0 0))', write(geom))

    geom = read('POLYGON((0 0, 5 0, 5 5, 0 5, 0 0))').normalize

    assert_equal('POLYGON ((0 0, 0 5, 5 5, 5 0, 0 0))', write(geom))
  end

  def test_normalize_bang
    geom = read('POLYGON((0 0, 5 0, 5 5, 0 5, 0 0))')
    geom.normalize!

    assert_equal('POLYGON ((0 0, 0 5, 5 5, 5 0, 0 0))', write(geom))

    geom = read('POLYGON((0 0, 5 0, 5 5, 0 5, 0 0))').normalize!

    assert_equal('POLYGON ((0 0, 0 5, 5 5, 5 0, 0 0))', write(geom))
  end
end
