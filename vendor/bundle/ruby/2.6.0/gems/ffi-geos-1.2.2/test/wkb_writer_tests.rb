# frozen_string_literal: true

require 'test_helper'

class WkbWriterTests < Minitest::Test
  include TestHelper

  def setup
    @wkb_writer = Geos::WkbWriter.new
    @writer = Geos::WktWriter.new
    @reader = Geos::WktReader.new
  end

  def wkb_tester(expected, g, dimensions, byte_order, srid, include_srid, hex = true)
    geom = read(g)
    geom.srid = srid

    @wkb_writer.output_dimensions = dimensions
    @wkb_writer.byte_order = byte_order
    @wkb_writer.include_srid = include_srid

    result = if hex
      @wkb_writer.write_hex(geom)
    else
      @wkb_writer.write(geom)
    end

    expected = expected.dup.force_encoding('BINARY') if expected.respond_to?(:encode)

    assert_equal(Geos::Tools.symbol_for_enum(Geos::ByteOrders, byte_order), @wkb_writer.byte_order)
    assert_equal(dimensions, @wkb_writer.output_dimensions)
    assert_equal(expected, result)
  end

  def test_2d_little_endian
    wkb_tester(
      '010100000000000000000018400000000000001C40',
      'POINT(6 7)',
      2,
      :ndr,
      43,
      false
    )
  end

  def test_2d_little_endian_with_srid
    wkb_tester(
      '01010000202B00000000000000000018400000000000001C40',
      'POINT(6 7)',
      2,
      :ndr,
      43,
      true
    )
  end

  def test_2d_big_endian
    wkb_tester(
      '00000000014018000000000000401C000000000000',
      'POINT(6 7)',
      2,
      :xdr,
      43,
      false
    )
  end

  def test_2d_big_endian_with_srid
    wkb_tester(
      '00200000010000002B4018000000000000401C000000000000',
      'POINT(6 7)',
      2,
      :xdr,
      43,
      true
    )
  end

  def test_3d_little_endian_with_2d_output
    wkb_tester(
      '010100000000000000000018400000000000001C40',
      'POINT(6 7)',
      3,
      :ndr,
      43,
      false
    )
  end

  def test_3d_little_endian__with_2d_output_with_srid
    wkb_tester(
      '01010000202B00000000000000000018400000000000001C40',
      'POINT(6 7)',
      3,
      :ndr,
      43,
      true
    )
  end

  def test_3d_big_endian_with_2d_input
    wkb_tester(
      '00000000014018000000000000401C000000000000',
      'POINT(6 7)',
      3,
      :xdr,
      43,
      false
    )
  end

  def test_3d_big_endian_with_2d_input_with_srid
    wkb_tester(
      '00200000010000002B4018000000000000401C000000000000',
      'POINT(6 7)',
      3,
      :xdr,
      43,
      true
    )
  end

  def test_2d_little_endian_with_3d_input
    wkb_tester(
      '010100000000000000000018400000000000001C40',
      'POINT(6 7 8)',
      2,
      :ndr,
      53,
      false
    )
  end

  def test_2d_little_endian_with_3d_input_with_srid
    wkb_tester(
      '01010000203500000000000000000018400000000000001C40',
      'POINT(6 7 8)',
      2,
      :ndr,
      53,
      true
    )
  end

  def test_2d_big_endian_with_3d_input
    wkb_tester(
      '00000000014018000000000000401C000000000000',
      'POINT(6 7 8)',
      2,
      :xdr,
      53,
      false
    )
  end

  def test_2d_big_endian_with_3d_input_with_srid
    wkb_tester(
      '0020000001000000354018000000000000401C000000000000',
      'POINT(6 7 8)',
      2,
      :xdr,
      53,
      true
    )
  end

  def test_3d_little_endian_with_3d_input
    wkb_tester(
      '010100008000000000000018400000000000001C400000000000002040',
      'POINT(6 7 8)',
      3,
      :ndr,
      53,
      false
    )
  end

  def test_3d_big_endian_with_3d_input
    wkb_tester(
      '00800000014018000000000000401C0000000000004020000000000000',
      'POINT(6 7 8)',
      3,
      :xdr,
      53,
      false
    )
  end

  def test_3d_big_endian_with_3d_input_with_srid
    wkb_tester(
      '00A0000001000000354018000000000000401C0000000000004020000000000000',
      'POINT(6 7 8)',
      3,
      :xdr,
      53,
      true
    )
  end

  def test_try_bad_byte_order_value
    assert_raises(TypeError) do
      wkb_tester(
        '010100008000000000000018400000000000001C400000000000002040',
        'POINT(6 7 8)',
        3,
        'gibberish',
        53,
        false
      )
    end

    assert_raises(TypeError) do
      wkb_tester(
        '010100008000000000000018400000000000001C400000000000002040',
        'POINT(6 7 8)',
        3,
        1000,
        53,
        false
      )
    end
  end

  def test_2d_little_endian_binary
    wkb_tester(
      '010100000000000000000018400000000000001C40',
      'POINT(6 7)',
      2,
      1,
      43,
      false
    )
  end

  def test_2d_little_endian_with_srid_binary
    wkb_tester(
      '01010000202B00000000000000000018400000000000001C40',
      'POINT(6 7)',
      2,
      1,
      43,
      true
    )
  end

  def test_2d_big_endian_binary
    wkb_tester(
      '00000000014018000000000000401C000000000000',
      'POINT(6 7)',
      2,
      0,
      43,
      false
    )
  end

  def test_2d_big_endian_with_srid_binary
    wkb_tester(
      '00200000010000002B4018000000000000401C000000000000',
      'POINT(6 7)',
      2,
      0,
      43,
      true
    )
  end

  def test_3d_little_endian_with_2d_output_binary
    wkb_tester(
      '010100000000000000000018400000000000001C40',
      'POINT(6 7)',
      3,
      1,
      43,
      false
    )
  end

  def test_3d_little_endian__with_2d_output_with_srid_binary
    wkb_tester(
      '01010000202B00000000000000000018400000000000001C40',
      'POINT(6 7)',
      3,
      1,
      43,
      true
    )
  end

  def test_3d_big_endian_with_2d_input_binary
    wkb_tester(
      '00000000014018000000000000401C000000000000',
      'POINT(6 7)',
      3,
      0,
      43,
      false
    )
  end

  def test_3d_big_endian_with_2d_input_with_srid_binary
    wkb_tester(
      '00200000010000002B4018000000000000401C000000000000',
      'POINT(6 7)',
      3,
      0,
      43,
      true
    )
  end

  def test_2d_little_endian_with_3d_input_binary
    wkb_tester(
      '010100000000000000000018400000000000001C40',
      'POINT(6 7 8)',
      2,
      1,
      53,
      false
    )
  end

  def test_2d_little_endian_with_3d_input_with_srid_binary
    wkb_tester(
      '01010000203500000000000000000018400000000000001C40',
      'POINT(6 7 8)',
      2,
      1,
      53,
      true
    )
  end

  def test_2d_big_endian_with_3d_input_binary
    wkb_tester(
      "\x00\x00\x00\x00\x01\x40\x18\x00\x00\x00\x00\x00\x00\x40\x1C\x00\x00\x00\x00\x00\x00",
      'POINT(6 7 8)',
      2,
      0,
      53,
      false,
      false
    )
  end

  def test_2d_big_endian_with_3d_input_with_srid_binary
    wkb_tester(
      "\x00\x20\x00\x00\x01\x00\x00\x00\x35\x40\x18\x00\x00\x00\x00\x00\x00\x40\x1C\x00\x00\x00\x00\x00\x00",
      'POINT(6 7 8)',
      2,
      0,
      53,
      true,
      false
    )
  end

  def test_3d_little_endian_with_3d_input_binary
    wkb_tester(
      "\x01\x01\x00\x00\x80\x00\x00\x00\x00\x00\x00\x18\x40\x00\x00\x00\x00\x00\x00\x1C\x40\x00\x00\x00\x00\x00\x00\x20\x40",
      'POINT(6 7 8)',
      3,
      1,
      53,
      false,
      false
    )
  end

  def test_3d_big_endian_with_3d_input_binary
    wkb_tester(
      "\x00\x80\x00\x00\x01\x40\x18\x00\x00\x00\x00\x00\x00\x40\x1C\x00\x00\x00\x00\x00\x00\x40\x20\x00\x00\x00\x00\x00\x00",
      'POINT(6 7 8)',
      3,
      0,
      53,
      false,
      false
    )
  end

  def test_3d_big_endian_with_3d_input_with_srid_binary
    wkb_tester(
      "\x00\xA0\x00\x00\x01\x00\x00\x00\x35\x40\x18\x00\x00\x00\x00\x00\x00\x40\x1C\x00\x00\x00\x00\x00\x00\x40\x20\x00\x00\x00\x00\x00\x00",
      'POINT(6 7 8)',
      3,
      0,
      53,
      true,
      false
    )
  end

  def test_try_bad_byte_order_value_binary
    assert_raises(TypeError) do
      wkb_tester(
        "\x01\x01\x00\x00\x80\x00\x00\x00\x00\x00\x00\x18\x40\x00\x00\x00\x00\x00\x00\x1C\x40\x00\x00\x00\x00\x00\x00\x20\x40",
        'POINT(6 7 8)',
        3,
        'gibberish',
        53,
        false,
        false
      )
    end

    assert_raises(TypeError) do
      wkb_tester(
        "\x01\x01\x00\x00\x80\x00\x00\x00\x00\x00\x00\x18\x40\x00\x00\x00\x00\x00\x00\x1C\x40\x00\x00\x00\x00\x00\x00\x20\x40",
        'POINT(6 7 8)',
        3,
        1000,
        53,
        false,
        false
      )
    end
  end

  def test_write_with_options
    skip unless ENV['FORCE_TESTS'] || defined?(Geos::FFIGeos)

    geom = read('POINT(1 2 3)')
    geom.srid = 4326

    tester = lambda { |expected, *args|
      expected = expected.dup.force_encoding('BINARY') if expected.respond_to?(:force_encoding)

      assert_equal(
        expected,
        @wkb_writer.write(geom, *args)
      )
    }

    tester[
      "\x01\x01\x00\x00\x20\xE6\x10\x00\x00\x00\x00\x00\x00\x00\x00\xF0\x3F\x00\x00\x00\x00\x00\x00\x00\x40",
      include_srid: true
    ]

    tester[
      "\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\xF0\x3F\x00\x00\x00\x00\x00\x00\x00\x40"
    ]
  end

  def test_write_hex_with_options
    skip unless ENV['FORCE_TESTS'] || defined?(Geos::FFIGeos)

    geom = read('POINT(1 2 3)')
    geom.srid = 4326

    assert_equal('0101000020E6100000000000000000F03F0000000000000040', @wkb_writer.write_hex(geom,
      include_srid: true
    ))

    assert_equal('0101000000000000000000F03F0000000000000040', @wkb_writer.write_hex(geom))
  end

  def test_illegal_output_dimensions
    assert_raises(ArgumentError) do
      @wkb_writer.output_dimensions = 10
    end

    assert_raises(ArgumentError) do
      @wkb_writer.output_dimensions = 0
    end
  end
end
