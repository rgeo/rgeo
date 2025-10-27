# frozen_string_literal: true

require 'test_helper'

class GeometryMinimumWidthTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_minimum_width
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:minimum_width)

    geom = read('POLYGON ((0 0, 0 15, 5 10, 5 0, 0 0))')
    output = geom.minimum_width

    assert_equal('LINESTRING (0 0, 5 0)', write(output))

    geom = read('LINESTRING (0 0,0 10, 10 10)')
    output = geom.minimum_width

    assert_equal('LINESTRING (5 5, 0 10)', write(output))
  end
end
