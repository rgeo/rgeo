# frozen_string_literal: true

require 'test_helper'

class GeometryPolygonizeTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_polygonize
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:polygonize)

    geom_a = read(
      'GEOMETRYCOLLECTION(
        LINESTRING(0 0, 10 10),
        LINESTRING(185 221, 100 100),
        LINESTRING(185 221, 88 275, 180 316),
        LINESTRING(185 221, 292 281, 180 316),
        LINESTRING(189 98, 83 187, 185 221),
        LINESTRING(189 98, 325 168, 185 221)
      )'
    )

    polygonized = geom_a.polygonize

    assert_equal(2, polygonized.length)
    assert_equal(
      'POLYGON ((185 221, 88 275, 180 316, 292 281, 185 221))',
      write(polygonized[0].snap_to_grid(0.1))
    )
    assert_equal(
      'POLYGON ((189 98, 83 187, 185 221, 325 168, 189 98))',
      write(polygonized[1].snap_to_grid(0.1))
    )
  end

  def test_polygonize_with_geometry_arguments
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:polygonize)

    geom_a = read('LINESTRING (100 100, 100 300, 300 300, 300 100, 100 100)')
    geom_b = read('LINESTRING (150 150, 150 250, 250 250, 250 150, 150 150)')

    polygonized = geom_a.polygonize(geom_b)

    assert_equal(2, polygonized.length)
    assert_equal(
      'POLYGON ((100 100, 100 300, 300 300, 300 100, 100 100), (150 150, 250 150, 250 250, 150 250, 150 150))',
      write(polygonized[0].snap_to_grid(0.1))
    )
    assert_equal(
      'POLYGON ((150 150, 150 250, 250 250, 250 150, 150 150))',
      write(polygonized[1].snap_to_grid(0.1))
    )
  end

  def test_polygonize_valid
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:polygonize_valid)

    geom_a = read(
      'GEOMETRYCOLLECTION(
        LINESTRING (100 100, 100 300, 300 300, 300 100, 100 100),
        LINESTRING (150 150, 150 250, 250 250, 250 150, 150 150)
      )'
    )

    polygonized = geom_a.polygonize_valid

    assert_equal(
      'POLYGON ((100 100, 100 300, 300 300, 300 100, 100 100), (150 150, 250 150, 250 250, 150 250, 150 150))',
      write(polygonized.snap_to_grid(0.1))
    )
  end

  def test_polygonize_cut_edges
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:polygonize_cut_edges)

    geom_a = read(
      'GEOMETRYCOLLECTION(
        LINESTRING(0 0, 10 10),
        LINESTRING(185 221, 100 100),
        LINESTRING(185 221, 88 275, 180 316),
        LINESTRING(185 221, 292 281, 180 316),
        LINESTRING(189 98, 83 187, 185 221),
        LINESTRING(189 98, 325 168, 185 221)
      )'
    )

    cut_edges = geom_a.polygonize_cut_edges

    assert_equal(0, cut_edges.length)
  end

  def test_polygonize_full
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:polygonize_full)

    writer.rounding_precision = if Geos::GEOS_NICE_VERSION >= '031000'
      0
    else
      3
    end

    geom_a = read(
      'GEOMETRYCOLLECTION(
        LINESTRING(0 0, 10 10),
        LINESTRING(185 221, 100 100),
        LINESTRING(185 221, 88 275, 180 316),
        LINESTRING(185 221, 292 281, 180 316),
        LINESTRING(189 98, 83 187, 185 221),
        LINESTRING(189 98, 325 168, 185 221)
      )'
    )

    polygonized = geom_a.polygonize_full

    assert_kind_of(Array, polygonized[:rings])
    assert_kind_of(Array, polygonized[:cuts])
    assert_kind_of(Array, polygonized[:dangles])
    assert_kind_of(Array, polygonized[:invalid_rings])

    assert_equal(2, polygonized[:rings].length)
    assert_equal(0, polygonized[:cuts].length)
    assert_equal(2, polygonized[:dangles].length)
    assert_equal(0, polygonized[:invalid_rings].length)

    assert_equal(
      'POLYGON ((185 221, 88 275, 180 316, 292 281, 185 221))',
      write(polygonized[:rings][0])
    )

    assert_equal(
      'POLYGON ((189 98, 83 187, 185 221, 325 168, 189 98))',
      write(polygonized[:rings][1])
    )

    assert_equal(
      'LINESTRING (185 221, 100 100)',
      write(polygonized[:dangles][0])
    )

    assert_equal(
      'LINESTRING (0 0, 10 10)',
      write(polygonized[:dangles][1])
    )

    geom_b = geom_a.union(read('POINT(0 0)'))
    polygonized = geom_b.polygonize_full

    assert_equal(2, polygonized[:dangles].length)
    assert_equal(0, polygonized[:invalid_rings].length)

    assert_equal(
      'LINESTRING (132 146, 100 100)',
      write(polygonized[:dangles][0])
    )

    assert_equal(
      'LINESTRING (0 0, 10 10)',
      write(polygonized[:dangles][1])
    )
  end

  def test_polygonize_with_bad_arguments
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:polygonize_full)

    assert_raises(ArgumentError) do
      geom = read('POINT(0 0)')
      geom.polygonize(geom, 'gibberish')
    end
  end
end
