# frozen_string_literal: true

require 'test_helper'

class GeometryDimensionsTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_dimensions
    types = {
      dontcare: -3,
      non_empty: -2,
      empty: -1,
      point: 0,
      curve: 1,
      surface: 2
    }

    simple_tester(:dimensions, types[:point], 'POINT(0 0)')
    simple_tester(:dimensions, types[:point], 'MULTIPOINT (0 1, 2 3)')
    simple_tester(:dimensions, types[:curve], 'LINESTRING (0 0, 2 3)')
    simple_tester(:dimensions, types[:curve], 'MULTILINESTRING ((0 1, 2 3), (10 10, 3 4))')
    simple_tester(:dimensions, types[:surface], 'POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0))')
    simple_tester(:dimensions, types[:surface], 'MULTIPOLYGON (
      ((0 0, 1 0, 1 1, 0 1, 0 0)),
      ((10 10, 10 14, 14 14, 14 10, 10 10),
      (11 11, 11 12, 12 12, 12 11, 11 11))
    )')
    simple_tester(:dimensions, types[:surface], 'GEOMETRYCOLLECTION (
      MULTIPOLYGON (
        ((0 0, 1 0, 1 1, 0 1, 0 0)),
        ((10 10, 10 14, 14 14, 14 10, 10 10),
        (11 11, 11 12, 12 12, 12 11, 11 11))
      ),
      POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0)),
      MULTILINESTRING ((0 0, 2 3), (10 10, 3 4)),
      LINESTRING (0 0, 2 3),
      MULTIPOINT (0 0, 2 3),
      POINT (9 0)
    )')
  end
end
