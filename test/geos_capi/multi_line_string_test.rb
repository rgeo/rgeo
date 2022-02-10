# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS multi line string implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class GeosMultiLineStringTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::MultiLineStringTests

  def create_factory
    @factory = RGeo::Geos.factory
  end

  def assert_polygonize_equal(expected_wkt, input_wkt)
    expected = @factory.parse_wkt(expected_wkt)
    input = @factory.parse_wkt(input_wkt)

    input_geometry_polygonized = input.polygonize

    assert_equal expected, input_geometry_polygonized
  end

  def test_polygonize
    input = "LINESTRING(0 0, 0 10, 10 10, 10 0, 0 0)"
    expected = "GEOMETRYCOLLECTION(POLYGON ((0 0, 0 10, 10 10, 10 0, 0 0)))"

    assert_polygonize_equal(expected, input)
  end

  def test_polygonize_two_rings
    expected = "GEOMETRYCOLLECTION(
      POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0)),
      POLYGON ((1 0, 1 1, 2 1, 2 0, 1 0))
    )"

    input = "MULTILINESTRING(
      (1 1, 0 1, 0 0, 1 0),
      (1 -1, 1 0, 1 1, 1 2),
      (1 1, 2 1, 2 0, 1 0)
    )"

    assert_polygonize_equal(expected, input)
  end

  def test_polygonize_two_line_strings
    input = "MULTILINESTRING(
      (10 18, 2 2, 16 2, 10 18),
      (10 18, 8 6, 12 6, 10 18)
    )"
    expected = "GEOMETRYCOLLECTION(
      POLYGON ((10 18, 12 6, 8 6, 10 18)),
      POLYGON (
        (10 18, 16 2, 2 2, 10 18),
        (10 18, 8 6, 12 6, 10 18)
      )
    )"

    assert_polygonize_equal(expected, input)
  end

  def test_polygonize_empty_geometry
    expected = "GEOMETRYCOLLECTION EMPTY"
    input = "MULTILINESTRING((0 0, 0 10, 10 10, 10 0))"

    assert_polygonize_equal(expected, input)
  end

  def test_polygonize_self_intersection
    input = "MULTILINESTRING((1 2, 4 2, 4 3, 3 3, 3 1))"
    expected = "GEOMETRYCOLLECTION EMPTY"

    assert_polygonize_equal(expected, input)
  end

  def test_polygonize_dangle
    input = "MULTILINESTRING((-10 10, 0 10, 10 10, 10 0, 0 0, 0 10))"
    expected = "GEOMETRYCOLLECTION EMPTY"

    assert_polygonize_equal(expected, input)
  end

  def test_polygonize_cut_edges
    input = "MULTILINESTRING(
        (0 0, 10 10),
        (0 0, 0 10),
        (0 10, 10 10),
        (0 0, 10 10)
      )"
    expected = "GEOMETRYCOLLECTION EMPTY"

    assert_polygonize_equal(expected, input)
  end

  def test_polygonize_two_squares
    input = "MULTILINESTRING(
      (10 10, 10 20, 20 20),
      (20 20, 20 10),
      (20 10, 10 10),
      (20 20, 30 20, 30 10, 20 10)
    )"
    expected = "GEOMETRYCOLLECTION(
      POLYGON ((20 20, 20 10, 10 10, 10 20, 20 20)),
      POLYGON ((20 10, 20 20, 30 20, 30 10, 20 10))
    )"

    assert_polygonize_equal(expected, input)
  end
end if RGeo::Geos.capi_supported?
