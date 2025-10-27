# frozen_string_literal: true

require 'test_helper'

class WktWriterTests < Minitest::Test
  include TestHelper

  def test_write_point
    geom = read('POINT(12.3456789 98.7654321)')
    wkt = write(geom)

    x, y = ([Regexp.last_match[1].to_f, Regexp.last_match[2].to_f] if wkt =~ /^POINT\s\((\d+\.\d+)\s*(\d+\.\d+)\)$/)

    assert_in_delta(12.3456789, x, TOLERANCE)
    assert_in_delta(98.7654321, y, TOLERANCE)
  end

  def test_trim
    skip unless ENV['FORCE_TESTS'] || Geos::WktWriter.method_defined?(:trim=)

    geom = read('POINT(6 7)')

    writer.trim = true

    assert_equal('POINT (6 7)', write(geom))

    writer.trim = false

    assert_equal('POINT (6.0000000000000000 7.0000000000000000)', write(geom))
  end

  def test_round_trip
    skip unless ENV['FORCE_TESTS'] || Geos::WktWriter.method_defined?(:trim=)

    writer.trim = true

    [
      'POINT (0 0)',
      'POINT EMPTY',
      if Geos::GEOS_NICE_VERSION >= '031200'
        'MULTIPOINT ((0 1), (2 3))'
      else
        'MULTIPOINT (0 1, 2 3)'
      end,
      'MULTIPOINT EMPTY',
      'LINESTRING (0 0, 2 3)',
      'LINESTRING EMPTY',
      'MULTILINESTRING ((0 1, 2 3), (10 10, 3 4))',
      'MULTILINESTRING EMPTY',
      'POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0))',
      'POLYGON EMPTY',
      'MULTIPOLYGON (((0 0, 1 0, 1 1, 0 1, 0 0)), ((10 10, 10 14, 14 14, 14 10, 10 10), (11 11, 11 12, 12 12, 12 11, 11 11)))',
      'MULTIPOLYGON EMPTY',
      if Geos::GEOS_NICE_VERSION >= '031200'
        'GEOMETRYCOLLECTION (MULTIPOLYGON (((0 0, 1 0, 1 1, 0 1, 0 0)), ((10 10, 10 14, 14 14, 14 10, 10 10), (11 11, 11 12, 12 12, 12 11, 11 11))), POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0)), MULTILINESTRING ((0 0, 2 3), (10 10, 3 4)), LINESTRING (0 0, 2 3), MULTIPOINT ((0 0), (2 3)), POINT (9 0))'
      else
        'GEOMETRYCOLLECTION (MULTIPOLYGON (((0 0, 1 0, 1 1, 0 1, 0 0)), ((10 10, 10 14, 14 14, 14 10, 10 10), (11 11, 11 12, 12 12, 12 11, 11 11))), POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0)), MULTILINESTRING ((0 0, 2 3), (10 10, 3 4)), LINESTRING (0 0, 2 3), MULTIPOINT (0 0, 2 3), POINT (9 0))'
      end,
      'GEOMETRYCOLLECTION EMPTY'
    ].each do |g|
      assert_equal(g, write(read(g)))
    end
  end

  def test_rounding_precision
    skip unless ENV['FORCE_TESTS'] || Geos::WktWriter.method_defined?(:rounding_precision=)

    geom = read('POINT(6.123456 7.123456)')

    tester = lambda { |expected, precision|
      writer.rounding_precision = precision if precision

      assert_equal(expected, write(geom))
    }

    tester['POINT (6.1234560000000000 7.1234560000000000)', nil]
    tester['POINT (6.12 7.12)', 2]
    tester['POINT (6.12346 7.12346)', 5]
    tester['POINT (6.1 7.1)', 1]
    tester['POINT (6 7)', 0]
  end

  def test_rounding_precision_too_high
    assert_raises(ArgumentError) do
      @writer.rounding_precision = 1000
    end
  end

  def test_output_dimensions
    skip unless ENV['FORCE_TESTS'] || Geos::WktWriter.method_defined?(:output_dimensions)

    assert_equal(2, writer.output_dimensions)
  end

  def test_output_dimensions_set
    skip unless ENV['FORCE_TESTS'] || Geos::WktWriter.method_defined?(:output_dimensions=)

    geom_3d = read('POINT(1 2 3)')
    geom_2d = read('POINT(3 2)')

    writer.trim = true

    # Only 2d by default
    assert_equal('POINT (1 2)', write(geom_3d))

    # 3d if requested _and_ available
    writer.output_dimensions = 3

    assert_equal('POINT Z (1 2 3)', write(geom_3d))
    assert_equal('POINT (3 2)', write(geom_2d))

    # 1 is invalid
    assert_raises(ArgumentError) do
      writer.output_dimensions = 1
    end

    # 4 is invalid
    assert_raises(ArgumentError) do
      writer.output_dimensions = 4
    end
  end

  def test_write_with_options
    skip unless ENV['FORCE_TESTS'] || defined?(Geos::FFIGeos)

    @writer.rounding_precision = 2

    geom = read('POINT(1 2 3)')

    assert_equal('POINT (1 2)', write(geom, trim: true))

    assert_equal('POINT (1.0000 2.0000)', write(geom, rounding_precision: 4))

    assert_equal('POINT Z (1 2 3)', write(geom,
      output_dimensions: 3,
      trim: true))

    assert_equal('POINT (1.00 2.00)', write(geom))
  end

  def test_old_3d_set
    skip unless ENV['FORCE_TESTS'] || Geos::WktWriter.method_defined?(:old_3d=)

    geom_3d = read('POINT(1 2 3)')
    writer.trim = true

    # New 3d WKT by default
    writer.output_dimensions = 3

    assert_equal('POINT Z (1 2 3)', write(geom_3d))

    # Switch to old
    writer.old_3d = true

    assert_equal('POINT (1 2 3)', write(geom_3d))

    # Old3d flag is not reset when changing dimensions
    writer.output_dimensions = 2

    assert_equal('POINT (1 2)', write(geom_3d))
    writer.output_dimensions = 3

    assert_equal('POINT (1 2 3)', write(geom_3d))

    # Likewise, dimensions spec is not reset when changing old3d flag
    writer.old_3d = false

    assert_equal('POINT Z (1 2 3)', write(geom_3d))
  end
end
