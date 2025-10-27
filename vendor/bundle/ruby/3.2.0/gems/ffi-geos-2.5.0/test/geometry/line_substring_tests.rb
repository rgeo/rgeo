# frozen_string_literal: true

require 'test_helper'

class GeometryTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_line_substring
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:line_substring)

    simple_tester(
      :line_substring,
      'LINESTRING (0 0, 1 1)',
      'LINESTRING (0 0, 2 2)',
      0,
      0.5
    )

    simple_tester(
      :line_substring,
      'MULTILINESTRING ((0 52.5, 0 100), (0 -5, 0 0))',
      'MULTILINESTRING((0 0, 0 100),(0 -5, 0 0))',
      0.5,
      1
    )

    simple_tester(
      :line_substring,
      'LINESTRING (1 1, 1 1)',
      'LINESTRING (0 0, 2 2)',
      0.5,
      0.5
    )

    simple_tester(
      :line_substring,
      'LINESTRING (1 1, 1 1)',
      'LINESTRING (0 0, 2 2)',
      0.5,
      0.5
    )

    assert_raises(Geos::GEOSException, 'IllegalArgumentException: end fraction must be <= 1') do
      simple_tester(
        :line_substring,
        '',
        'LINESTRING (0 0, 2 2)',
        0.5,
        1.5
      )
    end

    assert_raises(Geos::GEOSException, 'IllegalArgumentException: end fraction must be <= 1') do
      simple_tester(
        :line_substring,
        '',
        'LINESTRING (0 0, 2 2)',
        0.5,
        -0.1
      )
    end

    simple_tester(
      :line_substring,
      'LINESTRING (0.5 0.5, 0 0)',
      'LINESTRING (0 0, 1 1)',
      0.5,
      0
    )
  end
end
