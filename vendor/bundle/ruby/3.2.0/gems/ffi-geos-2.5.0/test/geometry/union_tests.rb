# frozen_string_literal: true

require 'test_helper'

class GeometryUnionTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_union
    comparison_tester(
      :union,
      'POINT (0 0)',
      'POINT(0 0)',
      'POINT(0 0)'
    )

    comparison_tester(
      :union,
      if Geos::GEOS_NICE_VERSION >= '031200'
        'MULTIPOINT ((0 0), (1 0))'
      else
        'MULTIPOINT (0 0, 1 0)'
      end,
      'POINT(0 0)',
      'POINT(1 0)'
    )

    comparison_tester(
      :union,
      'LINESTRING (0 0, 10 0)',
      'LINESTRING(0 0, 10 0)',
      'POINT(5 0)'
    )

    comparison_tester(
      :union,
      'LINESTRING (0 0, 10 0)',
      'POINT(5 0)',
      'LINESTRING(0 0, 10 0)'
    )

    comparison_tester(
      :union,
      'GEOMETRYCOLLECTION (POINT (5 0), LINESTRING (0 1, 10 1))',
      'POINT(5 0)',
      'LINESTRING(0 1, 10 1)'
    )

    comparison_tester(
      :union,
      'MULTILINESTRING ((0 0, 5 0), (5 0, 10 0), (5 -10, 5 0), (5 0, 5 10))',
      'LINESTRING(0 0, 10 0)',
      'LINESTRING(5 -10, 5 10)'
    )

    comparison_tester(
      :union,
      'MULTILINESTRING ((0 0, 5 0), (5 0, 10 0), (10 0, 20 0))',
      'LINESTRING(0 0, 10 0)',
      'LINESTRING(5 0, 20 0)'
    )

    comparison_tester(
      :union,
      if Geos::GEOS_NICE_VERSION > '030900'
        'GEOMETRYCOLLECTION (POLYGON ((0 10, 5 10, 10 10, 10 0, 5 0, 0 0, 0 10)), LINESTRING (5 -10, 5 0))'
      else
        'GEOMETRYCOLLECTION (LINESTRING (5 -10, 5 0), POLYGON ((0 0, 0 10, 5 10, 10 10, 10 0, 5 0, 0 0)))'
      end,
      'POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))',
      'LINESTRING(5 -10, 5 10)'
    )

    comparison_tester(
      :union,
      if Geos::GEOS_NICE_VERSION > '030900'
        'GEOMETRYCOLLECTION (POLYGON ((0 10, 10 10, 10 0, 0 0, 0 10)), LINESTRING (10 0, 20 0))'
      else
        'GEOMETRYCOLLECTION (LINESTRING (10 0, 20 0), POLYGON ((0 0, 0 10, 10 10, 10 0, 0 0)))'
      end,
      'POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))',
      'LINESTRING(10 0, 20 0)'
    )

    comparison_tester(
      :union,
      if Geos::GEOS_NICE_VERSION > '030900'
        'POLYGON ((0 10, 10 10, 10 5, 15 5, 15 -5, 5 -5, 5 0, 0 0, 0 10))'
      else
        'POLYGON ((0 0, 0 10, 10 10, 10 5, 15 5, 15 -5, 5 -5, 5 0, 0 0))'
      end,
      'POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))',
      'POLYGON((5 -5, 5 5, 15 5, 15 -5, 5 -5))'
    )
  end

  def test_union_with_precision
    skip unless ENV['FORCE_TESTS'] || Geos::FFIGeos.respond_to?(:GEOSUnionPrec_r)

    geom_a = read('POINT (1.9 8.2)')
    geom_b = read('POINT (4.1 9.8)')

    result = geom_a.union(geom_b, precision: 2)

    assert_equal(
      if Geos::GEOS_NICE_VERSION >= '031200'
        'MULTIPOINT ((2 8), (4 10))'
      else
        'MULTIPOINT (2 8, 4 10)'
      end,
      write(result)
    )
  end

  def test_union_cascaded
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:union_cascaded)

    simple_tester(
      :union_cascaded,
      if Geos::GEOS_NICE_VERSION > '030900'
        'POLYGON ((0 0, 0 1, 0 11, 10 11, 10 14, 14 14, 14 10, 11 10, 11 0, 1 0, 0 0), (12 12, 11 12, 11 11, 12 11, 12 12))'
      else
        'POLYGON ((1 0, 0 0, 0 1, 0 11, 10 11, 10 14, 14 14, 14 10, 11 10, 11 0, 1 0), (11 11, 12 11, 12 12, 11 12, 11 11))'
      end,
      'MULTIPOLYGON(
        ((0 0, 1 0, 1 1, 0 1, 0 0)),
        ((10 10, 10 14, 14 14, 14 10, 10 10),
        (11 11, 11 12, 12 12, 12 11, 11 11)),
        ((0 0, 11 0, 11 11, 0 11, 0 0))
      )'
    )
  end

  def test_coverage_union
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:coverage_union)

    simple_tester(
      :union_cascaded,
      if Geos::GEOS_NICE_VERSION > '030900'
        'POLYGON ((0 1, 1 1, 2 1, 2 0, 1 0, 0 0, 0 1))'
      else
        'POLYGON ((0 0, 0 1, 1 1, 2 1, 2 0, 1 0, 0 0))'
      end,
      'MULTIPOLYGON(
        ((0 0, 0 1, 1 1, 1 0, 0 0)),
        ((1 0, 1 1, 2 1, 2 0, 1 0))
      )'
    )
  end

  def test_unary_union
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:unary_union)

    simple_tester(
      :unary_union,
      if Geos::GEOS_NICE_VERSION > '030900'
        'POLYGON ((0 0, 0 1, 0 11, 10 11, 10 14, 14 14, 14 10, 11 10, 11 0, 1 0, 0 0), (12 12, 11 12, 11 11, 12 11, 12 12))'
      else
        'POLYGON ((1 0, 0 0, 0 1, 0 11, 10 11, 10 14, 14 14, 14 10, 11 10, 11 0, 1 0), (11 11, 12 11, 12 12, 11 12, 11 11))'
      end,
      'MULTIPOLYGON(
        ((0 0, 1 0, 1 1, 0 1, 0 0)),
        ((10 10, 10 14, 14 14, 14 10, 10 10),
        (11 11, 11 12, 12 12, 12 11, 11 11)),
        ((0 0, 11 0, 11 11, 0 11, 0 0))
      )'
    )
  end

  def test_unary_union_with_precision
    skip unless ENV['FORCE_TESTS'] || Geos::FFIGeos.respond_to?(:GEOSUnaryUnionPrec_r)

    simple_tester(
      :unary_union,
      'POLYGON ((0 0, 0 12, 9 12, 9 15, 15 15, 15 9, 12 9, 12 0, 0 0))',
      'MULTIPOLYGON(
        ((0 0, 1 0, 1 1, 0 1, 0 0)),
        ((10 10, 10 14, 14 14, 14 10, 10 10),
        (11 11, 11 12, 12 12, 12 11, 11 11)),
        ((0 0, 11 0, 11 11, 0 11, 0 0))
      )',
      3
    )
  end

  def test_disjoint_subset_union
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:disjoint_subset_union)

    simple_tester(
      :disjoint_subset_union,
      'MULTIPOLYGON (((0 0, 0 1, 1 1, 2 1, 2 0, 1 0, 0 0)), ((3 3, 4 3, 4 4, 3 3)))',
      'MULTIPOLYGON (((0 0, 1 0, 1 1, 0 1, 0 0)), ((1 0, 2 0, 2 1, 1 1, 1 0)), ((3 3, 4 3, 4 4, 3 3)))'
    )
  end

  def test_union_without_arguments
    simple_tester(
      :union,
      if Geos::GEOS_NICE_VERSION > '030900'
        'POLYGON ((0 0, 0 1, 0 11, 10 11, 10 14, 14 14, 14 10, 11 10, 11 0, 1 0, 0 0), (12 12, 11 12, 11 11, 12 11, 12 12))'
      else
        'POLYGON ((1 0, 0 0, 0 1, 0 11, 10 11, 10 14, 14 14, 14 10, 11 10, 11 0, 1 0), (11 11, 12 11, 12 12, 11 12, 11 11))'
      end,
      'MULTIPOLYGON(
        ((0 0, 1 0, 1 1, 0 1, 0 0)),
        ((10 10, 10 14, 14 14, 14 10, 10 10),
        (11 11, 11 12, 12 12, 12 11, 11 11)),
        ((0 0, 11 0, 11 11, 0 11, 0 0))
      )'
    )
  end
end
