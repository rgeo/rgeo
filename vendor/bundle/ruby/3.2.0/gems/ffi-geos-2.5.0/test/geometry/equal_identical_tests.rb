# frozen_string_literal: true

require 'test_helper'

class GeometryEqualIdenticalTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def tester(expected, geom_a, geom_b)
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:eql_identical?)

    assert_equal(expected, read(geom_a).eql_identical?(read(geom_b)))
  end

  def test_different_types
    tester(false, 'POINT EMPTY', 'LINESTRING EMPTY')
  end

  def test_different_dimensions_empty
    tester(false, 'POINT EMPTY', 'POINT Z EMPTY')
  end

  def test_different_dimensions
    tester(false, 'POINT Z (1 2 3)', 'POINT M (1 2 3)')
  end

  def test_different_dimensions_zm_versus_m
    tester(false, 'POINT ZM (1 2 3 4)', 'POINT Z (1 2 3)')
  end

  def test_different_structure
    tester(false, 'LINESTRING (1 1, 2 2)', 'MULTILINESTRING ((1 1, 2 2))')
  end

  def test_different_types_geometry_collection
    tester(false, 'GEOMETRYCOLLECTION (LINESTRING (1 1, 2 2))', 'MULTILINESTRING ((1 1, 2 2))')
  end

  def test_non_finite_values
    tester(true, 'POINT(inf inf)', 'POINT(inf inf)')
  end

  def test_equal_lines
    tester(true, 'LINESTRING M (1 1 0, 2 2 1)', 'LINESTRING M (1 1 0, 2 2 1)')
  end

  def test_different_lines
    tester(false, 'LINESTRING M (1 1 0, 2 2 1)', 'LINESTRING M (1 1 1, 2 2 1)')
  end

  def test_equal_polygons
    tester(true, 'POLYGON ((0 0, 1 0, 1 1, 0 0))', 'POLYGON ((0 0, 1 0, 1 1, 0 0))')
  end

  def test_different_polygons
    tester(false, 'POLYGON ((0 0, 1 0, 1 1, 0 0))', 'POLYGON ((1 0, 1 1, 0 0, 1 0))')
  end

  def test_equal_polygons_with_holes
    tester(false, 'POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0), (1 1, 2 1, 2 2, 1 1))', 'POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0), (1 1, 2 1, 2 2, 1 1), (3 3, 4 3, 4 4, 3 3))')
  end

  def test_identical_collections
    tester(true, 'MULTILINESTRING ((1 1, 2 2), (2 2, 3 3))', 'MULTILINESTRING ((1 1, 2 2), (2 2, 3 3))')
  end

  def test_different_collection_structure
    tester(false, 'MULTILINESTRING ((1 1, 2 2), (2 2, 3 3))', 'MULTILINESTRING ((2 2, 3 3), (1 1, 2 2))')
  end

  def test_negative_zeo_and_positive_zero
    tester(true, 'POINT(1 0)', 'POINT(1 -0)')
  end
end
