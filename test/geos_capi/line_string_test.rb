# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS line string implementation
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"
require_relative "./skip_capi"

class GeosLineStringTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::LineStringTests
  prepend SkipCAPI

  def setup
    skip "CAPI not supported" unless RGeo::Geos.capi_supported?

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

  def test_segmentize
    skip_geos_version_less_then("3.10")

    input = @factory.parse_wkt("LINESTRING(0 0, 0 10)")
    expected = @factory.parse_wkt("LINESTRING (0 0, 0 5, 0 10)")

    assert_equal expected, input.segmentize(5)

    assert_raises(TypeError, "no implicit conversion to float from string") { input.segmentize("a") }
    assert_raises(TypeError, "no implicit conversion to float from nil") { input.segmentize(nil) }
    assert_raises(RGeo::Error::InvalidGeometry, "Tolerance must be positive") { input.segmentize(0) }
  end

  # GEOS 3.14+ features

  def test_line_substring_full_line
    line = @factory.parse_wkt("LINESTRING(0 0, 10 0)")
    skip "GEOS 3.14+ required" unless line.respond_to?(:line_substring)

    result = line.line_substring(0.0, 1.0)

    assert_equal line, result
  end

  def test_line_substring_first_half
    line = @factory.parse_wkt("LINESTRING(0 0, 10 0)")
    skip "GEOS 3.14+ required" unless line.respond_to?(:line_substring)

    expected = @factory.parse_wkt("LINESTRING(0 0, 5 0)")
    result = line.line_substring(0.0, 0.5)

    assert_equal expected, result
  end

  def test_line_substring_second_half
    line = @factory.parse_wkt("LINESTRING(0 0, 10 0)")
    skip "GEOS 3.14+ required" unless line.respond_to?(:line_substring)

    expected = @factory.parse_wkt("LINESTRING(5 0, 10 0)")
    result = line.line_substring(0.5, 1.0)

    assert_equal expected, result
  end

  def test_line_substring_middle_portion
    line = @factory.parse_wkt("LINESTRING(0 0, 10 0)")
    skip "GEOS 3.14+ required" unless line.respond_to?(:line_substring)

    expected = @factory.parse_wkt("LINESTRING(2.5 0, 7.5 0)")
    result = line.line_substring(0.25, 0.75)

    assert_equal expected, result
  end

  def test_line_substring_complex_line
    line = @factory.parse_wkt("LINESTRING(0 0, 5 0, 5 5, 10 5)")
    skip "GEOS 3.14+ required" unless line.respond_to?(:line_substring)

    # Total length = 5 + 5 + 5 = 15
    # 0.0 to 0.5 = first 7.5 units = (0,0) to (5,0) to (5,2.5)
    result = line.line_substring(0.0, 0.5)

    assert_instance_of RGeo::Geos::CAPILineStringImpl, result
    assert result.length > 0
  end
end
