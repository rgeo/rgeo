# frozen_string_literal: true

require 'test_helper'

class GeometryDifferenceTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_difference
    comparison_tester(
      :difference,
      EMPTY_GEOMETRY,
      'POINT(0 0)',
      'POINT(0 0)'
    )

    comparison_tester(
      :difference,
      'POINT (0 0)',
      'POINT(0 0)',
      'POINT(1 0)'
    )

    comparison_tester(
      :difference,
      'LINESTRING (0 0, 10 0)',
      'LINESTRING(0 0, 10 0)',
      'POINT(5 0)'
    )

    comparison_tester(
      :difference,
      EMPTY_GEOMETRY,
      'POINT(5 0)',
      'LINESTRING(0 0, 10 0)'
    )

    comparison_tester(
      :difference,
      'POINT (5 0)',
      'POINT(5 0)',
      'LINESTRING(0 1, 10 1)'
    )

    comparison_tester(
      :difference,
      'MULTILINESTRING ((0 0, 5 0), (5 0, 10 0))',
      'LINESTRING(0 0, 10 0)',
      'LINESTRING(5 -10, 5 10)'
    )

    comparison_tester(
      :difference,
      'LINESTRING (0 0, 5 0)',
      'LINESTRING(0 0, 10 0)',
      'LINESTRING(5 0, 20 0)'
    )

    comparison_tester(
      :difference,
      if Geos::GEOS_NICE_VERSION > '030900'
        'POLYGON ((0 10, 5 10, 10 10, 10 0, 5 0, 0 0, 0 10))'
      else
        'POLYGON ((0 0, 0 10, 5 10, 10 10, 10 0, 5 0, 0 0))'
      end,
      'POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))',
      'LINESTRING(5 -10, 5 10)'
    )

    comparison_tester(
      :difference,
      if Geos::GEOS_NICE_VERSION > '030900'
        'POLYGON ((0 10, 10 10, 10 0, 0 0, 0 10))'
      else
        'POLYGON ((0 0, 0 10, 10 10, 10 0, 0 0))'
      end,
      'POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))',
      'LINESTRING(10 0, 20 0)'
    )

    comparison_tester(
      :difference,
      if Geos::GEOS_NICE_VERSION > '030900'
        'POLYGON ((0 10, 10 10, 10 5, 5 5, 5 0, 0 0, 0 10))'
      else
        'POLYGON ((0 0, 0 10, 10 10, 10 5, 5 5, 5 0, 0 0))'
      end,
      'POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))',
      'POLYGON((5 -5, 5 5, 15 5, 15 -5, 5 -5))'
    )
  end

  def test_difference_with_precision
    skip unless ENV['FORCE_TESTS'] || Geos::FFIGeos.respond_to?(:GEOSDifferencePrec_r)

    comparison_tester(
      :difference,
      'MULTILINESTRING ((2 8, 4 8), (6 8, 10 8))',
      'LINESTRING (2 8, 10 8)',
      'LINESTRING (3.9 8.1, 6.1 7.9)',
      precision: 2
    )
  end
end
