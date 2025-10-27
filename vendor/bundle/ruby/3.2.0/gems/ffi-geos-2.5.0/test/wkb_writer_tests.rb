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
      [0, 0, 0, 0, 1, 64, 24, 0, 0, 0, 0, 0, 0, 64, 28, 0, 0, 0, 0, 0, 0].pack('C*'),
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
      [0, 32, 0, 0, 1, 0, 0, 0, 53, 64, 24, 0, 0, 0, 0, 0, 0, 64, 28, 0, 0, 0, 0, 0, 0].pack('C*'),
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
      [1, 1, 0, 0, 128, 0, 0, 0, 0, 0, 0, 24, 64, 0, 0, 0, 0, 0, 0, 28, 64, 0, 0, 0, 0, 0, 0, 32, 64].pack('C*'),
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
      [0, 128, 0, 0, 1, 64, 24, 0, 0, 0, 0, 0, 0, 64, 28, 0, 0, 0, 0, 0, 0, 64, 32, 0, 0, 0, 0, 0, 0].pack('C*'),
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
      [0, 160, 0, 0, 1, 0, 0, 0, 53, 64, 24, 0, 0, 0, 0, 0, 0, 64, 28, 0, 0, 0, 0, 0, 0, 64, 32, 0, 0, 0, 0, 0, 0].pack('C*'),
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
        [1, 1, 0, 0, 128, 0, 0, 0, 0, 0, 0, 24, 64, 0, 0, 0, 0, 0, 0, 28, 64, 0, 0, 0, 0, 0, 0, 32, 64].pack('C*'),
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
        [1, 1, 0, 0, 128, 0, 0, 0, 0, 0, 0, 24, 64, 0, 0, 0, 0, 0, 0, 28, 64, 0, 0, 0, 0, 0, 0, 32, 64].pack('C*'),
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
      if Geos::GEOS_NICE_VERSION >= '031200'
        [1, 1, 0, 0, 160, 230, 16, 0, 0, 0, 0, 0, 0, 0, 0, 240, 63, 0, 0, 0, 0, 0, 0, 0, 64, 0, 0, 0, 0, 0, 0, 8, 64].pack('C*')
      else
        [1, 1, 0, 0, 32, 230, 16, 0, 0, 0, 0, 0, 0, 0, 0, 240, 63, 0, 0, 0, 0, 0, 0, 0, 64].pack('C*')
      end,
      include_srid: true
    ]

    tester[
      if Geos::GEOS_NICE_VERSION >= '031200'
        [1, 1, 0, 0, 128, 0, 0, 0, 0, 0, 0, 240, 63, 0, 0, 0, 0, 0, 0, 0, 64, 0, 0, 0, 0, 0, 0, 8, 64].pack('C*')
      else
        [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 240, 63, 0, 0, 0, 0, 0, 0, 0, 64].pack('C*')
      end
    ]
  end

  def test_write_hex_with_options
    skip unless ENV['FORCE_TESTS'] || defined?(Geos::FFIGeos)

    geom = read('POINT(1 2 3)')
    geom.srid = 4326

    assert_equal(
      if Geos::GEOS_NICE_VERSION >= '031200'
        '01010000A0E6100000000000000000F03F00000000000000400000000000000840'
      else
        '0101000020E6100000000000000000F03F0000000000000040'
      end,
      @wkb_writer.write_hex(
        geom,
        include_srid: true
      )
    )

    assert_equal(
      if Geos::GEOS_NICE_VERSION >= '031200'
        '0101000080000000000000F03F00000000000000400000000000000840'
      else
        '0101000000000000000000F03F0000000000000040'
      end,
      @wkb_writer.write_hex(geom)
    )
  end

  def test_illegal_output_dimensions
    assert_raises(ArgumentError) do
      @wkb_writer.output_dimensions = 10
    end

    assert_raises(ArgumentError) do
      @wkb_writer.output_dimensions = 0
    end
  end

  def test_wkb_flavor_extended
    skip unless ENV['FORCE_TESTS'] || Geos::FFIGeos.respond_to?(:GEOSWKBWriter_setFlavor_r)

    @wkb_writer.output_dimensions = 3
    @wkb_writer.flavor = :extended

    assert_equal('010200008003000000000000000000F03F000000000000004000000000000008400000000000001040000000000000144000000000000018400000000000001C4000000000000020400000000000002240',
      @wkb_writer.write_hex(read('LINESTRING Z (1 2 3, 4 5 6, 7 8 9)')))
  end

  def test_wkb_flavor_iso
    skip unless ENV['FORCE_TESTS'] || Geos::FFIGeos.respond_to?(:GEOSWKBWriter_setFlavor_r)

    @wkb_writer.output_dimensions = 3
    @wkb_writer.flavor = :iso

    assert_equal('01EA03000003000000000000000000F03F000000000000004000000000000008400000000000001040000000000000144000000000000018400000000000001C4000000000000020400000000000002240',
      @wkb_writer.write_hex(read('LINESTRING Z (1 2 3, 4 5 6, 7 8 9)')))
  end
end
