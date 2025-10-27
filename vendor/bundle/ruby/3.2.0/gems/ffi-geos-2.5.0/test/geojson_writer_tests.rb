# frozen_string_literal: true

require 'test_helper'

class GeoJSONWriterTests < Minitest::Test
  include TestHelper

  attr_reader :json_writer

  def setup
    super

    skip unless ENV['FORCE_TESTS'] || Geos::FFIGeos.respond_to?(:GEOSGeoJSONWriter_create_r)

    @json_writer = Geos::GeoJSONWriter.new
  end

  def json_write(*args, **options)
    json_writer.write(*args, **options)
  end

  def geojson_tester(expected, geom, **options)
    assert_equal(expected, json_write(read(geom), **options))
  end

  def test_point
    geojson_tester('{"type":"Point","coordinates":[-117.0,33.0]}', 'POINT(-117 33)')
  end

  def test_line_string
    geojson_tester('{"type":"LineString","coordinates":[[102.0,0.0],[103.0,1.0],[104.0,0.0],[105.0,1.0]]}', 'LINESTRING(102.0 0.0, 103.0 1.0, 104.0 0.0, 105.0 1.0)')
  end

  def test_polygon
    geojson_tester('{"type":"Polygon","coordinates":[[[30.0,10.0],[40.0,40.0],[20.0,40.0],[10.0,20.0],[30.0,10.0]]]}', 'POLYGON((30 10, 40 40, 20 40, 10 20, 30 10))')
  end

  def test_polygon_with_inner_ring
    geojson_tester('{"type":"Polygon","coordinates":[[[35.0,10.0],[45.0,45.0],[15.0,40.0],[10.0,20.0],[35.0,10.0]],[[20.0,30.0],[35.0,35.0],[30.0,20.0],[20.0,30.0]]]}', 'POLYGON((35 10, 45 45, 15 40, 10 20, 35 10), (20 30, 35 35, 30 20, 20 30))')
  end

  def test_multi_point
    geojson_tester('{"type":"MultiPoint","coordinates":[[10.0,40.0],[40.0,30.0],[20.0,20.0],[30.0,10.0]]}', 'MULTIPOINT ((10 40), (40 30), (20 20), (30 10))')
  end

  def test_multi_line_string
    geojson_tester('{"type":"MultiLineString","coordinates":[[[10.0,10.0],[20.0,20.0],[10.0,40.0]],[[40.0,40.0],[30.0,30.0],[40.0,20.0],[30.0,10.0]]]}', 'MULTILINESTRING ((10 10, 20 20, 10 40),(40 40, 30 30, 40 20, 30 10))')
  end

  def test_multi_polygon
    geojson_tester('{"type":"MultiPolygon","coordinates":[[[[30.0,20.0],[45.0,40.0],[10.0,40.0],[30.0,20.0]]],[[[15.0,5.0],[40.0,10.0],[10.0,20.0],[5.0,10.0],[15.0,5.0]]]]}', 'MULTIPOLYGON (((30 20, 45 40, 10 40, 30 20)),((15 5, 40 10, 10 20, 5 10, 15 5)))')
  end

  def test_geometry_collection
    geojson_tester('{"type":"GeometryCollection","geometries":[{"type":"Point","coordinates":[1.0,1.0]},{"type":"Point","coordinates":[2.0,2.0]}]}', 'GEOMETRYCOLLECTION(POINT(1 1),POINT(2 2))')
  end

  def test_write_with_indentation
    geojson_tester(<<~JSON.strip, 'LINESTRING(102.0 0.0, 103.0 1.0, 104.0 0.0, 105.0 1.0)', indentation: 2)
      {
        "type": "LineString",
        "coordinates": [
          [
            102.0,
            0.0
          ],
          [
            103.0,
            1.0
          ],
          [
            104.0,
            0.0
          ],
          [
            105.0,
            1.0
          ]
        ]
      }
    JSON
  end

  def test_empty_point
    geojson_tester('{"type":"Point","coordinates":[]}', 'POINT EMPTY')
  end

  def test_empty_line_string
    geojson_tester('{"type":"LineString","coordinates":[]}', 'LINESTRING EMPTY')
  end

  def test_empty_polygon
    geojson_tester('{"type":"Polygon","coordinates":[[]]}', 'POLYGON EMPTY')
  end

  def test_empty_geometry_collection
    geojson_tester('{"type":"GeometryCollection","geometries":[]}', 'GEOMETRYCOLLECTION EMPTY')
  end

  def test_linear_ring
    geojson_tester('{"type":"LineString","coordinates":[[0.0,0.0],[1.0,1.0],[1.0,0.0],[0.0,0.0]]}', 'LINEARRING (0 0, 1 1, 1 0, 0 0)')
  end
end
