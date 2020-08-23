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

  def test_polygonize
    coordinates = [
      [30.001043463959554, 49.011562641544636],
      [30.00104344258436, 49.01156262042366],
      [30.000986002945037, 49.01153728085321],
      [30.00098241341133, 49.011536807005264],
      [30.0009793658682, 49.01153814158362],
      [30.000978645524963, 49.011540502810455],
      [30.00098067434918, 49.01154250751114],
      [30.001038084302778, 49.01156783398706],
      [30.001038084303158, 49.011567833987236],
      [30.001043463959558, 49.011562641544636],
      [30.001043463959554, 49.011562641544636]
    ]

    points = coordinates.map { |x, y| @factory.point(x, y) }
    line_string = @factory.line_string(points)
    line_ring = @factory.line_string(points)
    polygon = @factory.polygon(line_ring)
    expected_result = @factory.collection([polygon])

    line_string_polygonized = line_string.polygonize
    assert_equal expected_result, line_string_polygonized
  end
    
  def test_offset_curve
    factory = RGeo::Geos.factory(buffer_resolution: 4)
    line_coordinates = [
      [164.0, 16.0], [144.0, 16.0], [124.0, 16.0], [104.0, 16.0], [84.0, 16.0],
      [64.0, 16.0], [44.0, 16.0], [24.0, 16.0], [20.0, 16.0], [18.0, 16.0],
      [17.0, 17.0], [16.0, 18.0], [16.0, 20.0], [16.0, 40.0],
      [16.0, 60.0], [16.0, 80.0], [16.0, 100.0], [16.0, 120.0],
      [16.0, 140.0], [16.0, 160.0], [16.0, 180.0], [16.0, 195.0],
    ]

    expected_line_coordinates = [
      [164.0, 1.0], [18.0, 1.0],
      [12.25974851452365, 2.1418070123306983],
      [7.393398282201787, 5.3933982822017885],
      [5.393398282201787, 7.3933982822017885],
      [2.1418070123306734, 12.259748514523698],
      [1.0, 18.0], [1.0, 195.0],
    ]

    points_array = line_coordinates.map { |v| factory.point(v[0], v[1]) }
    expected_points_array = expected_line_coordinates.map { |v| factory.point(v[0], v[1]) }

    line_string = factory.line_string(points_array)
    expected_line_string = factory.line_string(expected_points_array)

    assert_equal expected_line_string, line_string.offset_curve(15, RGeo::Geos::JOIN_ROUND, 5)
  end
end if RGeo::Geos.capi_supported?
