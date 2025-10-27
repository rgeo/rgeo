# frozen_string_literal: true

require 'test_helper'

class GeometryBoundaryTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_boundary
    simple_tester(
      :boundary,
      'GEOMETRYCOLLECTION EMPTY',
      'POINT(0 0)'
    )

    simple_tester(
      :boundary,
      if Geos::GEOS_NICE_VERSION >= '031200'
        'MULTIPOINT ((0 0), (10 10))'
      else
        'MULTIPOINT (0 0, 10 10)'
      end,
      'LINESTRING(0 0, 10 10)'
    )

    simple_tester(
      :boundary,
      'MULTILINESTRING ((0 0, 10 0, 10 10, 0 10, 0 0), (5 5, 5 6, 6 6, 6 5, 5 5))',
      'POLYGON((0 0, 10 0, 10 10, 0 10, 0 0),( 5 5, 5 6, 6 6, 6 5, 5 5))'
    )
  end
end
