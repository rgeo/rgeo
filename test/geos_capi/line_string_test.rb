# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS line string implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

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

  def do_test_polygonize(expected_wkt, input_wkt)
    expected = @factory.parse_wkt(expected_wkt)
    input = @factory.parse_wkt(input_wkt)

    input_geometry_polygonized = input.polygonize

    assert_equal expected, input_geometry_polygonized
  end

  def test_polygonize
    input = "LINESTRING(0 0, 0 10, 10 10, 10 0, 0 0)"
    expected = "GEOMETRYCOLLECTION(POLYGON ((0 0, 0 10, 10 10, 10 0, 0 0)))"

    do_test_polygonize(expected, input)
  end

  def test_polygonize_not_ring
    input = "LINESTRING(0 0, 0 10, 10 10, 10 0)"
    expected = "GEOMETRYCOLLECTION EMPTY"

    do_test_polygonize(expected, input)
  end

  def test_polygonize_self_intersection
    input = "LINESTRING(1 2, 4 2, 4 3, 3 3, 3 1)"
    expected = "GEOMETRYCOLLECTION EMPTY"

    do_test_polygonize(expected, input)
  end

  def test_polygonize_dangle
    input = "LINESTRING(-10 10, 0 10, 10 10, 10 0, 0 0, 0 10)"
    expected = "GEOMETRYCOLLECTION EMPTY"

    do_test_polygonize(expected, input)
  end
end if RGeo::Geos.capi_supported?
