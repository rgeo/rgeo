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
    RGeo::Geos.factory
  end

  def test_polygonize_lines_forming_valid_ring
    input = @factory.parse_wkt("MULTILINESTRING((0 0, 1 1), (1 1, 1 0), (1 0, 0 0))")
    expected = @factory.parse_wkt("GEOMETRYCOLLECTION(POLYGON ((0 0, 1 1, 1 0, 0 0)))")

    assert_equal expected, input.polygonize
  end

  def test_polygonize_two_valid_rings
    input = @factory.parse_wkt("MULTILINESTRING(
      (0 0, 1 1, 1 0, 0 0),
      (2 2, 3 3, 3 2, 2 2)
    )")
    expected = @factory.parse_wkt("GEOMETRYCOLLECTION(
      POLYGON ((0 0, 1 1, 1 0, 0 0)),
      POLYGON ((2 2, 3 3, 3 2, 2 2))
    )")

    assert_equal expected, input.polygonize
  end

  def test_polygonize_one_ring_inside_other
    input = @factory.parse_wkt("MULTILINESTRING(
      (0 0, 0 3, 3 3, 3 0, 0 0),
      (1 1, 1 2, 2 2, 2 1, 1 1)
    )")
    expected = @factory.parse_wkt("GEOMETRYCOLLECTION(
      POLYGON ((0 0, 0 3, 3 3, 3 0, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1)),
      POLYGON ((1 1, 1 2, 2 2, 2 1, 1 1))
    )")

    assert_equal expected, input.polygonize
  end

  def test_polygonize_valid_ring_and_line_over_it
    input = @factory.parse_wkt("MULTILINESTRING(
      (0 0, 0 2, 2 2, 2 0, 0 0),
      (1 0, 1 2)
    )")
    expected = @factory.parse_wkt("GEOMETRYCOLLECTION(
      POLYGON ((0 0, 0 2, 2 2, 2 0, 0 0))
    )")

    assert_equal expected, input.polygonize
  end

  def test_polygonize_two_unclosed_rings_closed_with_one_common_line
    input = @factory.parse_wkt("MULTILINESTRING(
      (1 0, 0 0, 0 1, 1 1),
      (1 1, 2 1, 2 0, 1 0),
      (1 0, 1 1)
    )")
    expected = @factory.parse_wkt("GEOMETRYCOLLECTION(
      POLYGON ((1 0, 0 0, 0 1, 1 1, 1 0)),
      POLYGON ((1 1, 2 1, 2 0, 1 0, 1 1))
    )")

    assert_equal expected, input.polygonize
  end

  def test_polygonize_duplicate_edge
    input = @factory.parse_wkt("MULTILINESTRING(
      (0 0, 1 1), (1 1, 0 1), (0 1, 0 1), (0 0, 1 1)
    )")
    expected = @factory.parse_wkt("GEOMETRYCOLLECTION EMPTY")

    assert_equal expected, input.polygonize
  end
end if RGeo::Geos.capi_supported?
