# frozen_string_literal: true

require 'test_helper'

class GeometryDupTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_dup
    geom_a = read('POINT(0 0)')
    geom_b = geom_a.dup

    assert_equal(geom_a, geom_b)
  end

  def test_dup_srid
    srid = 4326
    geom_a = read('POINT(0 0)')
    geom_a.srid = srid
    geom_b = geom_a.dup

    assert_equal(geom_a, geom_b)
    assert_equal(srid, geom_b.srid)
  end
end
