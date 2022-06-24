# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS line string implementation
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"

class GeosLineStringTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::LineStringTests

  def setup
    @factory = RGeo::Geos.factory
  end

  def test_project_interpolate_round_trip
    point =  @factory.point(2, 2)
    line_string = @factory.line_string([[0, 0], [5, 5]].map { |x, y| @factory.point(x, y) })
    location = line_string.project_point point
    interpolated_point = line_string.interpolate_point location
    assert_equal point, interpolated_point
  end

  def test_polygonize_valid_ring
    input = @factory.parse_wkt("LINESTRING(0 0, 1 1, 1 0, 0 0)")
    expected = @factory.parse_wkt("GEOMETRYCOLLECTION(POLYGON ((0 0, 1 1, 1 0, 0 0)))")

    assert_equal expected, input.polygonize
  end

  def test_polygonize_not_closed_ring
    input = @factory.parse_wkt("LINESTRING(0 0, 1 1, 1 0)")
    expected = @factory.parse_wkt("GEOMETRYCOLLECTION EMPTY")

    assert_equal expected, input.polygonize
  end

  def test_polygonize_self_intersection
    input = @factory.parse_wkt("LINESTRING(0 0, 1 1, 1 0, 0 1, 0 0)")
    expected = @factory.parse_wkt("GEOMETRYCOLLECTION EMPTY")

    assert_equal expected, input.polygonize
  end

  def test_polygonize_dangle
    input = @factory.parse_wkt("LINESTRING(0 0, 2 2, 1 1, 1 0, 0 0)")
    expected = @factory.parse_wkt("GEOMETRYCOLLECTION EMPTY")

    assert_equal expected, input.polygonize
  end
end if RGeo::Geos.capi_supported?
