# frozen_string_literal: true

require 'test_helper'

class WktReaderTests < Minitest::Test
  include TestHelper

  def wkt_tester(type_id, geom_type, klass, *geoms)
    geoms.each do |g|
      geom = read(g)

      refute_nil(geom)
      assert_equal(type_id, geom.type_id)
      assert_equal(geom_type, geom.geom_type)
      assert_kind_of(klass, geom)
    end
  end

  def test_read_point
    wkt_tester(
      Geos::GEOS_POINT,
      'Point',
      Geos::Point,
      'POINT(0 0)',
      'POINT(0 0 0)',
      'POINT Z(0 0 0)',
      'POINT EMPTY'
    )
  end

  def test_read_multi_point
    wkt_tester(
      Geos::GEOS_MULTIPOINT,
      'MultiPoint',
      Geos::MultiPoint,
      'MULTIPOINT(0 0 1, 2 3 4)',
      'MULTIPOINT Z (0 0 1, 2 3 4)',
      'MULTIPOINT((0 0), (2 3))',
      'MULTIPOINT EMPTY'
    )
  end

  def test_read_linestring
    wkt_tester(
      Geos::GEOS_LINESTRING,
      'LineString',
      Geos::LineString,
      'LINESTRING(0 0 1, 2 3 4)',
      'LINESTRING EMPTY'
    )
  end

  def test_multi_line_string
    wkt_tester(
      Geos::GEOS_MULTILINESTRING,
      'MultiLineString',
      Geos::MultiLineString,
      'MULTILINESTRING((0 0 1, 2 3 4), (10 10 2, 3 4 5))',
      'MULTILINESTRING Z ((0 0 1, 2 3 4), (10 10 2, 3 4 5))'
    )
  end

  def test_polygon
    wkt_tester(
      Geos::GEOS_POLYGON,
      'Polygon',
      Geos::Polygon,
      'POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))',
      'POLYGON EMPTY'
    )
  end

  def test_multi_polygon
    wkt_tester(
      Geos::GEOS_MULTIPOLYGON,
      'MultiPolygon',
      Geos::MultiPolygon,
      'MULTIPOLYGON(
        ((0 0, 1 0, 1 1, 0 1, 0 0)),
        ((10 10, 10 14, 14 14, 14 10, 10 10),
        (11 11, 11 12, 12 12, 12 11, 11 11))
            )',
      'MULTIPOLYGON EMPTY'
    )
  end

  def test_geometry_collection
    wkt_tester(
      Geos::GEOS_GEOMETRYCOLLECTION,
      'GeometryCollection',
      Geos::GeometryCollection,
      'GEOMETRYCOLLECTION(
        MULTIPOLYGON(
          ((0 0, 1 0, 1 1, 0 1, 0 0)),
          ((10 10, 10 14, 14 14, 14 10, 10 10),
          (11 11, 11 12, 12 12, 12 11, 11 11))
        ),
        POLYGON((0 0, 1 0, 1 1, 0 1, 0 0)),
                MULTILINESTRING((0 0, 2 3), (10 10, 3 4)),
                LINESTRING(0 0, 2 3),
                MULTIPOINT(0 0, 2 3),
                POINT(9 0)
      )',
      'GEOMETRYCOLLECTION EMPTY'
    )
  end

  def test_read_linearring
    geom = read('LINEARRING(0 0, 1 1, 2 2, 3 3, 0 0)')

    assert_equal(Geos::GEOS_LINEARRING, geom.type_id)
    assert_equal('LinearRing', geom.geom_type)
    assert_kind_of(Geos::LinearRing, geom)
  end

  def test_read_exception
    assert_raises(Geos::WktReader::ParseError) do
      read('gibberish')
    end
  end

  def test_read_with_srid
    assert_equal(0, read('POINT (0 0)').srid)
    assert_equal(4326, read('POINT (0 0)', srid: 4326).srid)
  end
end
