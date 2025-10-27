# frozen_string_literal: true

require 'test_helper'

class GeometrySymDifferenceTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_sym_difference
    %w{ sym_difference symmetric_difference }.each do |method|
      comparison_tester(
        method,
        EMPTY_GEOMETRY,
        'POINT(0 0)',
        'POINT(0 0)'
      )

      comparison_tester(
        method,
        if Geos::GEOS_NICE_VERSION >= '031200'
          'MULTIPOINT ((0 0), (1 0))'
        else
          'MULTIPOINT (0 0, 1 0)'
        end,
        'POINT(0 0)',
        'POINT(1 0)'
      )

      comparison_tester(
        method,
        'LINESTRING (0 0, 10 0)',
        'LINESTRING(0 0, 10 0)',
        'POINT(5 0)'
      )

      comparison_tester(
        method,
        'LINESTRING (0 0, 10 0)',
        'POINT(5 0)',
        'LINESTRING(0 0, 10 0)'
      )

      comparison_tester(
        method,
        'GEOMETRYCOLLECTION (POINT (5 0), LINESTRING (0 1, 10 1))',
        'POINT(5 0)',
        'LINESTRING(0 1, 10 1)'
      )

      comparison_tester(
        method,
        'MULTILINESTRING ((0 0, 5 0), (5 0, 10 0), (5 -10, 5 0), (5 0, 5 10))',
        'LINESTRING(0 0, 10 0)',
        'LINESTRING(5 -10, 5 10)'
      )

      comparison_tester(
        method,
        'MULTILINESTRING ((0 0, 5 0), (10 0, 20 0))',
        'LINESTRING(0 0, 10 0)',
        'LINESTRING(5 0, 20 0)'
      )

      comparison_tester(
        method,
        if Geos::GEOS_NICE_VERSION > '030900'
          'GEOMETRYCOLLECTION (POLYGON ((0 10, 5 10, 10 10, 10 0, 5 0, 0 0, 0 10)), LINESTRING (5 -10, 5 0))'
        else
          'GEOMETRYCOLLECTION (LINESTRING (5 -10, 5 0), POLYGON ((0 0, 0 10, 5 10, 10 10, 10 0, 5 0, 0 0)))'
        end,
        'POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))',
        'LINESTRING(5 -10, 5 10)'
      )

      comparison_tester(
        method,
        if Geos::GEOS_NICE_VERSION > '030900'
          'GEOMETRYCOLLECTION (POLYGON ((0 10, 10 10, 10 0, 0 0, 0 10)), LINESTRING (10 0, 20 0))'
        else
          'GEOMETRYCOLLECTION (LINESTRING (10 0, 20 0), POLYGON ((0 0, 0 10, 10 10, 10 0, 0 0)))'
        end,
        'POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))',
        'LINESTRING(10 0, 20 0)'
      )

      comparison_tester(
        method,
        if Geos::GEOS_NICE_VERSION > '030900'
          'MULTIPOLYGON (((0 10, 10 10, 10 5, 5 5, 5 0, 0 0, 0 10)), ((10 0, 10 5, 15 5, 15 -5, 5 -5, 5 0, 10 0)))'
        else
          'MULTIPOLYGON (((0 0, 0 10, 10 10, 10 5, 5 5, 5 0, 0 0)), ((5 0, 10 0, 10 5, 15 5, 15 -5, 5 -5, 5 0)))'
        end,
        'POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))',
        'POLYGON((5 -5, 5 5, 15 5, 15 -5, 5 -5))'
      )
    end
  end

  def test_sym_difference_with_precision
    skip unless ENV['FORCE_TESTS'] || Geos::FFIGeos.respond_to?(:GEOSSymDifferencePrec_r)

    comparison_tester(
      :sym_difference,
      'GEOMETRYCOLLECTION (POLYGON ((0 10, 6 10, 10 10, 10 0, 6 0, 0 0, 0 10)), LINESTRING (6 -10, 6 0))',
      'POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))',
      'LINESTRING(5 -10, 5 10)',
      precision: 2
    )
  end
end
