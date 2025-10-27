# frozen_string_literal: true

require 'test_helper'

class GeometryBufferTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_buffer
    simple_tester(
      :buffer,
      'POLYGON EMPTY',
      'POINT(0 0)',
      0
    )

    snapped_tester(
      :buffer,
      'POLYGON ((10 0, 10 -2, 9 -4, 8 -6, 7 -7, 6 -8, 4 -9, 2 -10, 0 -10, -2 -10, -4 -9, -6 -8, -7 -7, -8 -6, -9 -4, -10 -2, -10 0, -10 2, -9 4, -8 6, -7 7, -6 8, -4 9, -2 10, 0 10, 2 10, 4 9, 6 8, 7 7, 8 6, 9 4, 10 2, 10 0))',
      'POINT(0 0)',
      10
    )

    # One segment per quadrant
    snapped_tester(
      :buffer,
      'POLYGON ((10 0, 0 -10, -10 0, 0 10, 10 0))',
      'POINT(0 0)',
      10,
      quad_segs: 1
    )

    # End cap styles
    snapped_tester(
      :buffer,
      'POLYGON ((100 10, 110 0, 100 -10, 0 -10, -10 0, 0 10, 100 10))',
      'LINESTRING(0 0, 100 0)',
      10,
      quad_segs: 1, endcap: :round
    )

    snapped_tester(
      :buffer,
      'POLYGON ((100 10, 100 -10, 0 -10, 0 10, 100 10))',
      'LINESTRING(0 0, 100 0)',
      10,
      quad_segs: 1, endcap: :flat
    )

    snapped_tester(
      :buffer,
      'POLYGON ((100 10, 110 10, 110 -10, 0 -10, -10 -10, -10 10, 100 10))',
      'LINESTRING(0 0, 100 0)',
      10,
      quad_segs: 1, endcap: :square
    )

    # Join styles
    snapped_tester(
      :buffer,
      'POLYGON ((90 10, 90 100, 93 107, 100 110, 107 107, 110 100, 110 0, 107 -7, 100 -10, 0 -10, -7 -7, -10 0, -7 7, 0 10, 90 10))',
      'LINESTRING(0 0, 100 0, 100 100)',
      10,
      quad_segs: 2, join: :round
    )

    snapped_tester(
      :buffer,
      'POLYGON ((90 10, 90 100, 93 107, 100 110, 107 107, 110 100, 110 0, 100 -10, 0 -10, -7 -7, -10 0, -7 7, 0 10, 90 10))',
      'LINESTRING(0 0, 100 0, 100 100)',
      10,
      quad_segs: 2, join: :bevel
    )

    snapped_tester(
      :buffer,
      'POLYGON ((90 10, 90 100, 93 107, 100 110, 107 107, 110 100, 110 -10, 0 -10, -7 -7, -10 0, -7 7, 0 10, 90 10))',
      'LINESTRING(0 0, 100 0, 100 100)',
      10,
      quad_segs: 2, join: :mitre
    )

    snapped_tester(
      :buffer,
      if Geos::GEOS_NICE_VERSION >= '031100'
        'POLYGON ((90 10, 90 100, 93 107, 100 110, 107 107, 110 100, 110 -4, 104 -10, 0 -10, -7 -7, -10 0, -7 7, 0 10, 90 10))'
      else
        'POLYGON ((90 10, 90 100, 93 107, 100 110, 107 107, 110 100, 109 -5, 105 -9, 0 -10, -7 -7, -10 0, -7 7, 0 10, 90 10))'
      end,
      'LINESTRING(0 0, 100 0, 100 100)',
      10,
      quad_segs: 2, join: :mitre, mitre_limit: 1.0
    )

    # Single-sided buffering
    snapped_tester(
      :buffer,
      'POLYGON ((100 0, 0 0, 0 10, 100 10, 100 0))',
      'LINESTRING(0 0, 100 0)',
      10,
      single_sided: true
    )

    snapped_tester(
      :buffer,
      'POLYGON ((0 0, 100 0, 100 -10, 0 -10, 0 0))',
      'LINESTRING(0 0, 100 0)',
      -10,
      single_sided: true
    )
  end
end
