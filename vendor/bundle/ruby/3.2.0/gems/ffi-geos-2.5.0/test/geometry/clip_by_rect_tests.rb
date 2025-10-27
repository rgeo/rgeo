# frozen_string_literal: true

require 'test_helper'

class GeometryClipByRectTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_clip_by_rect
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:clip_by_rect)

    %w{
      clip_by_rect
      clip_by_rectangle
    }.each do |method|
      simple_tester(
        method,
        'POINT (0 0)',
        'POINT (0 0)',
        -1, -1, 1, 1
      )

      simple_tester(
        method,
        'GEOMETRYCOLLECTION EMPTY',
        'POINT (0 0)',
        0, 0, 2, 2
      )

      simple_tester(
        method,
        'LINESTRING (1 0, 2 0)',
        'LINESTRING (0 0, 10 0)',
        1, -1, 2, 1
      )

      simple_tester(
        method,
        'POLYGON ((1 1, 1 5, 5 5, 5 1, 1 1))',
        'POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0))',
        1, 1, 5, 5
      )

      simple_tester(
        method,
        'POLYGON ((0 0, 0 5, 5 5, 5 0, 0 0))',
        'POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0))',
        -1, -1, 5, 5
      )
    end
  end
end
