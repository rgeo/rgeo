# frozen_string_literal: true

require 'test_helper'

class GeometryMinimumRotatedRectangleTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_minimum_rotated_rectangle
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:minimum_rotated_rectangle)

    geom = read('POLYGON ((1 6, 6 11, 11 6, 6 1, 1 6))')
    minimum_rotated_rectangle = geom.minimum_rotated_rectangle

    assert_equal(
      if Geos::GEOS_NICE_VERSION >= '031200'
        'POLYGON ((6 1, 1 6, 6 11, 11 6, 6 1))'
      else
        'POLYGON ((6 1, 11 6, 6 11, 1 6, 6 1))'
      end,
      write(minimum_rotated_rectangle)
    )
  end
end
