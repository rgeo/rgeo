# frozen_string_literal: true

require 'test_helper'

class GeoJSONReaderTests < Minitest::Test
  include TestHelper

  attr_reader :json_reader

  def setup
    super

    skip unless ENV['FORCE_TESTS'] || Geos::FFIGeos.respond_to?(:GEOSGeoJSONReader_create_r)

    @json_reader = Geos::GeoJSONReader.new

    @writer.rounding_precision = 3
  end

  def json_read(*args, **options)
    json_reader.read(*args, **options)
  end

  def geojson_tester(expected, json, **options)
    assert_equal(expected, write(json_read(json, **options)))
  end

  def test_point
    geojson_tester(
      'POINT (-117.000 33.000)',
      '{"type":"Point","coordinates":[-117.0,33.0]}'
    )
  end

  def test_line_string
    geojson_tester(
      'LINESTRING (102.000 0.000, 103.000 1.000, 104.000 0.000, 105.000 1.000)',
      '{"type":"LineString","coordinates":[[102.0,0.0],[103.0,1.0],[104.0,0.0],[105.0,1.0]]}'
    )
  end

  def test_polygon
    geojson_tester(
      'POLYGON ((30.000 10.000, 40.000 40.000, 20.000 40.000, 10.000 20.000, 30.000 10.000))',
      '{"type":"Polygon","coordinates":[[[30,10],[40,40],[20,40],[10,20],[30,10]]]}'
    )
  end

  def test_polygon_with_inner_ring
    geojson_tester(
      'POLYGON ((35.000 10.000, 45.000 45.000, 15.000 40.000, 10.000 20.000, 35.000 10.000), (20.000 30.000, 35.000 35.000, 30.000 20.000, 20.000 30.000))',
      '{"type":"Polygon","coordinates":[[[35,10],[45,45],[15,40],[10,20],[35,10]],[[20,30],[35,35],[30,20],[20,30]]]}'
    )
  end

  def test_multi_point
    geojson_tester(
      if Geos::GEOS_NICE_VERSION >= '031200'
        'MULTIPOINT ((10.000 40.000), (40.000 30.000), (20.000 20.000), (30.000 10.000))'
      else
        'MULTIPOINT (10.000 40.000, 40.000 30.000, 20.000 20.000, 30.000 10.000)'
      end,
      '{"type":"MultiPoint","coordinates":[[10, 40], [40, 30], [20, 20], [30, 10]]}'
    )
  end

  def test_multi_line_string
    geojson_tester(
      'MULTILINESTRING ((10.000 10.000, 20.000 20.000, 10.000 40.000), (40.000 40.000, 30.000 30.000, 40.000 20.000, 30.000 10.000))',
      '{"type":"MultiLineString","coordinates":[[[10, 10], [20, 20], [10, 40]],[[40, 40], [30, 30], [40, 20], [30, 10]]]}'
    )
  end

  def test_multi_polygon
    geojson_tester(
      'MULTIPOLYGON (((40.000 40.000, 20.000 45.000, 45.000 30.000, 40.000 40.000)), ((20.000 35.000, 10.000 30.000, 10.000 10.000, 30.000 5.000, 45.000 20.000, 20.000 35.000), (30.000 20.000, 20.000 15.000, 20.000 25.000, 30.000 20.000)))',
      '{"type": "MultiPolygon", "coordinates": [[[[40, 40], [20, 45], [45, 30], [40, 40]]], [[[20, 35], [10, 30], [10, 10], [30, 5], [45, 20], [20, 35]], [[30, 20], [20, 15], [20, 25], [30, 20]]]]}'
    )
  end

  def test_geometry_collection
    geojson_tester(
      'GEOMETRYCOLLECTION (POINT (40.000 10.000), LINESTRING (10.000 10.000, 20.000 20.000, 10.000 40.000), POLYGON ((40.000 40.000, 20.000 45.000, 45.000 30.000, 40.000 40.000)))',
      '{"type": "GeometryCollection","geometries": [{"type": "Point","coordinates": [40, 10]},{"type": "LineString","coordinates": [[10, 10], [20, 20], [10, 40]]},{"type": "Polygon","coordinates": [[[40, 40], [20, 45], [45, 30], [40, 40]]]}]}'
    )
  end

  def test_feature_collection
    geojson_tester(
      'GEOMETRYCOLLECTION (POINT (-117.000 33.000), POINT (-122.000 45.000))',
      '{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[-117.0,33.0]}},{"type":"Feature","geometry":{"type":"Point","coordinates":[-122.0,45.0]}}]}'
    )
  end

  def test_empty_point
    geojson_tester(
      'POINT EMPTY',
      '{"type":"Point","coordinates":[]}'
    )
  end

  def test_empty_line_string
    geojson_tester(
      'LINESTRING EMPTY',
      '{"type":"LineString","coordinates":[]}'
    )
  end

  def test_empty_polygon
    geojson_tester(
      'POLYGON EMPTY',
      '{"type":"Polygon","coordinates":[]}'
    )
  end

  def test_empty_multi_point
    geojson_tester(
      'MULTIPOINT EMPTY',
      '{"type":"MultiPoint","coordinates":[]}'
    )
  end

  def test_empty_multi_line_string
    geojson_tester(
      'MULTILINESTRING EMPTY',
      '{"type":"MultiLineString","coordinates":[]}'
    )
  end

  def test_empty_multi_polygon
    geojson_tester(
      'MULTIPOLYGON EMPTY',
      '{"type": "MultiPolygon", "coordinates": []}'
    )
  end

  def test_empty_geometry_collection
    geojson_tester(
      'GEOMETRYCOLLECTION EMPTY',
      '{"type": "GeometryCollection","geometries": []}'
    )
  end

  def test_incomplete_geojson
    assert_raises(Geos::GeoJSONReader::ParseError) do
      json_reader.read('{"type":"Point","coordinates":[-117.0]}')
    end

    assert_raises(Geos::GeoJSONReader::ParseError) do
      json_reader.read('{"type":"LineString","coordinates":[[1,2],[2]]}')
    end
  end

  def test_broken_geojson
    assert_raises(Geos::GeoJSONReader::ParseError) do
      json_reader.read('<gml>NOT_GEO_JSON</gml>')
    end
  end

  def test_incompatible_type
    assert_raises(Geos::GeoJSONReader::ParseError) do
      json_reader.read('{"type":"Line","coordinates":[[1,2],[2,3]]}')
    end
  end

  def test_srid_from_options
    geom = json_reader.read(
      '{"type":"Point","coordinates":[-117.0,33.0]}',
      srid: 3857
    )

    assert_equal(3857, geom.srid)
  end
end
