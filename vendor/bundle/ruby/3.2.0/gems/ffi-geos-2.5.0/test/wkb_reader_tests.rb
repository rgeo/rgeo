# frozen_string_literal: true

require 'test_helper'

class WkbReaderTests < Minitest::Test
  include TestHelper

  def setup
    @wkb_reader = Geos::WkbReader.new
    @writer = Geos::WktWriter.new
    @reader = Geos::WktReader.new
  end

  def wkb_tester(expected, g, type_id, geom_type, klass, srid, hex = true)
    geom = if hex
      @wkb_reader.read_hex(g)
    else
      @wkb_reader.read(g)
    end

    refute_nil(geom)
    assert_equal(type_id, geom.type_id)
    assert_equal(geom_type, geom.geom_type)
    assert_kind_of(klass, geom)
    assert_geom_eql_exact(read(expected), geom)
    assert_equal(srid, geom.srid)
  end

  def test_2d_little_endian
    wkb_tester(
      'POINT(6 7)',
      '010100000000000000000018400000000000001C40',
      Geos::GEOS_POINT,
      'Point',
      Geos::Point,
      0
    )
  end

  def test_2d_big_endian
    wkb_tester(
      'POINT (6 7)',
      '00000000014018000000000000401C000000000000',
      Geos::GEOS_POINT,
      'Point',
      Geos::Point,
      0
    )
  end

  def test_2d_little_endian_srid
    wkb_tester(
      'POINT (6 7)',
      '01010000202B00000000000000000018400000000000001C40',
      Geos::GEOS_POINT,
      'Point',
      Geos::Point,
      43
    )
  end

  def test_2d_big_endian_srid
    wkb_tester(
      'POINT (6 7)',
      '00200000010000002B4018000000000000401C000000000000',
      Geos::GEOS_POINT,
      'Point',
      Geos::Point,
      43
    )
  end

  def test_3d_little_endian
    wkb_tester(
      'POINT Z (6 7 8)',
      '010100008000000000000018400000000000001C400000000000002040',
      Geos::GEOS_POINT,
      'Point',
      Geos::Point,
      0
    )
  end

  def test_3d_big_endian
    wkb_tester(
      'POINT Z (6 7 8)',
      '00800000014018000000000000401C0000000000004020000000000000',
      Geos::GEOS_POINT,
      'Point',
      Geos::Point,
      0
    )
  end

  def test_3d_big_endian_srid
    wkb_tester(
      'POINT Z (6 7 8)',
      '00A0000001000000354018000000000000401C0000000000004020000000000000',
      Geos::GEOS_POINT,
      'Point',
      Geos::Point,
      53
    )
  end

  def test_2d_little_endian_binary
    wkb_tester(
      'POINT(6 7)',
      [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 64, 0, 0, 0, 0, 0, 0, 28, 64].pack('C*'),
      Geos::GEOS_POINT,
      'Point',
      Geos::Point,
      0,
      false
    )
  end

  def test_2d_big_endian_binary
    wkb_tester(
      'POINT (6 7)',
      [0, 0, 0, 0, 1, 64, 24, 0, 0, 0, 0, 0, 0, 64, 28, 0, 0, 0, 0, 0, 0].pack('C*'),
      Geos::GEOS_POINT,
      'Point',
      Geos::Point,
      0,
      false
    )
  end

  def test_2d_little_endian_srid_binary
    wkb_tester(
      'POINT (6 7)',
      [1, 1, 0, 0, 32, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 64, 0, 0, 0, 0, 0, 0, 28, 64].pack('C*'),
      Geos::GEOS_POINT,
      'Point',
      Geos::Point,
      43,
      false
    )
  end

  def test_2d_big_endian_srid_binary
    wkb_tester(
      'POINT (6 7)',
      [0, 32, 0, 0, 1, 0, 0, 0, 43, 64, 24, 0, 0, 0, 0, 0, 0, 64, 28, 0, 0, 0, 0, 0, 0].pack('C*'),
      Geos::GEOS_POINT,
      'Point',
      Geos::Point,
      43,
      false
    )
  end

  def test_3d_little_endian_binary
    wkb_tester(
      'POINT Z (6 7 8)',
      [1, 1, 0, 0, 128, 0, 0, 0, 0, 0, 0, 24, 64, 0, 0, 0, 0, 0, 0, 28, 64, 0, 0, 0, 0, 0, 0, 32, 64].pack('C*'),
      Geos::GEOS_POINT,
      'Point',
      Geos::Point,
      0,
      false
    )
  end

  def test_3d_big_endian_binary
    wkb_tester(
      'POINT Z (6 7 8)',
      [0, 128, 0, 0, 1, 64, 24, 0, 0, 0, 0, 0, 0, 64, 28, 0, 0, 0, 0, 0, 0, 64, 32, 0, 0, 0, 0, 0, 0].pack('C*'),
      Geos::GEOS_POINT,
      'Point',
      Geos::Point,
      0,
      false
    )
  end

  def test_3d_big_endian_srid_binary
    wkb_tester(
      'POINT Z (6 7 8)',
      [0, 160, 0, 0, 1, 0, 0, 0, 53, 64, 24, 0, 0, 0, 0, 0, 0, 64, 28, 0, 0, 0, 0, 0, 0, 64, 32, 0, 0, 0, 0, 0, 0].pack('C*'),
      Geos::GEOS_POINT,
      'Point',
      Geos::Point,
      53,
      false
    )
  end

  def test_read_with_srid
    assert_equal(43,
      @wkb_reader.read([1, 1, 0, 0, 32, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 64, 0, 0, 0, 0, 0, 0, 28, 64].pack('C*')).srid)

    assert_equal(4326,
      @wkb_reader.read(
        [1, 1, 0, 0, 32, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 64, 0, 0, 0, 0, 0, 0, 28, 64].pack('C*'),
        srid: 4326
      ).srid)
  end

  def test_read_hex_srid
    assert_equal(43,
      @wkb_reader.read_hex('01010000202B00000000000000000018400000000000001C40').srid)

    assert_equal(4326,
      @wkb_reader.read_hex(
        '01010000202B00000000000000000018400000000000001C40',
        srid: 4326
      ).srid)
  end

  def test_read_parse_error
    assert_raises(Geos::WkbReader::ParseError) do
      @wkb_reader.read('FOO')
    end
  end

  def test_read_hex_parse_error
    assert_raises(Geos::WkbReader::ParseError) do
      @wkb_reader.read_hex('FOO')
    end
  end
end
