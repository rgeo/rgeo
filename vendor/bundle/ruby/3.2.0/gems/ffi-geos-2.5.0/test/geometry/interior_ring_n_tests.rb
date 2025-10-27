# frozen_string_literal: true

require 'test_helper'

class GeometryInteriorRingNTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_interior_ring_n
    simple_tester(
      :interior_ring_n,
      'LINEARRING (11 11, 11 12, 12 12, 12 11, 11 11)',
      'POLYGON(
        (10 10, 10 14, 14 14, 14 10, 10 10),
        (11 11, 11 12, 12 12, 12 11, 11 11)
      )',
      0
    )

    simple_tester(
      :interior_ring_n,
      'LINEARRING (11 11, 11 12, 12 12, 12 11, 11 11)',
      'POLYGON (
        (10 10, 10 14, 14 14, 14 10, 10 10),
        (11 11, 11 12, 12 12, 12 11, 11 11),
        (13 11, 13 12, 13.5 12, 13.5 11, 13 11)
      )',
      0
    )

    simple_tester(
      :interior_ring_n,
      'LINEARRING (13 11, 13 12, 13.5 12, 13.5 11, 13 11)',
      'POLYGON (
        (10 10, 10 14, 14 14, 14 10, 10 10),
        (11 11, 11 12, 12 12, 12 11, 11 11),
        (13 11, 13 12, 13.5 12, 13.5 11, 13 11)
      )',
      1
    )

    assert_raises(Geos::IndexBoundsError) do
      simple_tester(
        :interior_ring_n,
        nil,
        'POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0))',
        0
      )
    end

    assert_raises(NoMethodError) do
      simple_tester(
        :interior_ring_n,
        nil,
        'POINT (0 0)',
        0
      )
    end
  end
end
