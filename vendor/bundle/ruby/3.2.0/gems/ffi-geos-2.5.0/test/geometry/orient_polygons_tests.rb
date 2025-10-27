# frozen_string_literal: true

require 'test_helper'

describe '#orient_polygons' do
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  it 'does not overwrite the original geometry' do
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:orient_polygons)

    geom = read('POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1))')

    result = geom.orient_polygons(true)

    assert_equal('POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1))', write(geom))
    assert_equal('POLYGON ((0 0, 0 10, 10 10, 10 0, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1))', write(result))
    refute_same(geom, result)
  end

  it 'does overwrite the original geometry with bang method' do
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:orient_polygons!)

    geom = read('POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1))')

    result = geom.orient_polygons!(true)

    assert_equal('POLYGON ((0 0, 0 10, 10 10, 10 0, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1))', write(geom))
    assert_equal('POLYGON ((0 0, 0 10, 10 10, 10 0, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1))', write(result))
    assert_same(geom, result)
  end

  it 'handles empty polygons' do
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:orient_polygons)

    simple_tester(
      :orient_polygons,
      'POLYGON EMPTY',
      'POLYGON EMPTY'
    )
  end

  it 'hole orientation is opposite to shell' do
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:orient_polygons)

    simple_tester(
      :orient_polygons,
      'POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0), (1 1, 1 2, 2 2, 2 1, 1 1))',
      'POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1))'
    )

    simple_tester(
      :orient_polygons,
      'POLYGON ((0 0, 0 10, 10 10, 10 0, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1))',
      'POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1))',
      true
    )
  end

  it 'ensures all polygons in collection are processed' do
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:orient_polygons)

    simple_tester(
      :orient_polygons,
      'MULTIPOLYGON (((0 0, 10 0, 10 10, 0 10, 0 0), (1 1, 1 2, 2 2, 2 1, 1 1)), ((100 100, 200 100, 200 200, 100 100)))',
      'MULTIPOLYGON (((0 0, 10 0, 10 10, 0 10, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1)), ((100 100, 200 100, 200 200, 100 100)))'
    )

    simple_tester(
      :orient_polygons,
      'MULTIPOLYGON (((0 0, 0 10, 10 10, 10 0, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1)), ((100 100, 200 200, 200 100, 100 100)))',
      'MULTIPOLYGON (((0 0, 10 0, 10 10, 0 10, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1)), ((100 100, 200 100, 200 200, 100 100)))',
      true
    )
  end

  it 'polygons in collection are oriented, closed linestring unchanged' do
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:orient_polygons)

    simple_tester(
      :orient_polygons,
      'GEOMETRYCOLLECTION (POLYGON ((0 0, 0 10, 10 10, 10 0, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1)), LINESTRING (100 100, 200 100, 200 200, 100 100))',
      'GEOMETRYCOLLECTION (POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1)), LINESTRING (100 100, 200 100, 200 200, 100 100))',
      true
    )
  end

  it 'nested collection handled correctly' do
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:orient_polygons)

    simple_tester(
      :orient_polygons,
      'GEOMETRYCOLLECTION (GEOMETRYCOLLECTION (MULTIPOLYGON (((0 0, 10 0, 10 10, 0 10, 0 0)))))',
      'GEOMETRYCOLLECTION (GEOMETRYCOLLECTION (MULTIPOLYGON (((0 0, 10 0, 10 10, 0 10, 0 0)))))'
    )
  end
end
