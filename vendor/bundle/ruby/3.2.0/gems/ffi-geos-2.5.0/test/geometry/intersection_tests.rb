# frozen_string_literal: true

require 'test_helper'

class GeometryIntersectionTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_intersection
    comparison_tester(
      :intersection,
      if Geos::GEOS_NICE_VERSION > '030900'
        'POLYGON ((10 10, 10 5, 5 5, 5 10, 10 10))'
      else
        'POLYGON ((5 10, 10 10, 10 5, 5 5, 5 10))'
      end,
      'POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0))',
      'POLYGON ((5 5, 15 5, 15 15, 5 15, 5 5))'
    )
  end

  def test_intersection_with_precision
    skip unless ENV['FORCE_TESTS'] || Geos::FFIGeos.respond_to?(:GEOSIntersectionPrec_r)

    comparison_tester(
      :intersection,
      'GEOMETRYCOLLECTION (POLYGON ((1 2, 1 1, 0.5 1, 1 2)), POLYGON ((9.5 1, 2 1, 2 2, 9 2, 9.5 1)), LINESTRING (1 1, 2 1), LINESTRING (2 2, 1 2))',
      'MULTIPOLYGON(((0 0,5 10,10 0,0 0),(1 1,1 2,2 2,2 1,1 1),(100 100,100 102,102 102,102 100,100 100)))',
      'POLYGON((0 1,0 2,10 2,10 1,0 1))',
      precision: 0
    )

    comparison_tester(
      :intersection,
      if Geos::GEOS_NICE_VERSION >= '031000'
        'GEOMETRYCOLLECTION (LINESTRING (2 0, 4 0), POINT (10 0), POINT (0 0))'
      else
        'GEOMETRYCOLLECTION (LINESTRING (2 0, 4 0), POINT (0 0), POINT (10 0))'
      end,
      'LINESTRING(0 0, 10 0)',
      'LINESTRING(9 0, 12 0, 12 20, 4 0, 2 0, 2 10, 0 10, 0 -10)',
      precision: 2
    )
  end
end
