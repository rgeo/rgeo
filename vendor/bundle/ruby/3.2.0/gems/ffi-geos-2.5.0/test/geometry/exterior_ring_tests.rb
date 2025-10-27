# frozen_string_literal: true

require 'test_helper'

class GeometryInteriorRingTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_exterior_ring
    simple_tester(
      :exterior_ring,
      'LINEARRING (10 10, 10 14, 14 14, 14 10, 10 10)',
      'POLYGON (
        (10 10, 10 14, 14 14, 14 10, 10 10),
        (11 11, 11 12, 12 12, 12 11, 11 11)
      )'
    )

    assert_raises(NoMethodError) do
      read('POINT (0 0)').exterior_ring
    end
  end
end
