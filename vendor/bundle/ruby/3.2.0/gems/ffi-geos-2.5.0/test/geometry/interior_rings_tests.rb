# frozen_string_literal: true

require 'test_helper'

class GeometryInteriorRingsTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_interior_rings
    array_tester(
      :interior_rings,
      ['LINEARRING (11 11, 11 12, 12 12, 12 11, 11 11)'],
      'POLYGON(
        (10 10, 10 14, 14 14, 14 10, 10 10),
        (11 11, 11 12, 12 12, 12 11, 11 11)
      )'
    )

    array_tester(
      :interior_rings,
      [
        'LINEARRING (11 11, 11 12, 12 12, 12 11, 11 11)',
        'LINEARRING (13 11, 13 12, 13.5 12, 13.5 11, 13 11)'
      ],
      'POLYGON (
        (10 10, 10 14, 14 14, 14 10, 10 10),
        (11 11, 11 12, 12 12, 12 11, 11 11),
        (13 11, 13 12, 13.5 12, 13.5 11, 13 11)
      )'
    )
  end
end
