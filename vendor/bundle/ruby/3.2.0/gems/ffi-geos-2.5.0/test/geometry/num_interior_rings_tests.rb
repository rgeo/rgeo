# frozen_string_literal: true

require 'test_helper'

class GeometryNumInteriorRingsTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_num_interior_rings
    simple_tester(:num_interior_rings, 0, 'POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0))')
    simple_tester(:num_interior_rings, 1, 'POLYGON (
      (10 10, 10 14, 14 14, 14 10, 10 10),
      (11 11, 11 12, 12 12, 12 11, 11 11)
    )')
    simple_tester(:num_interior_rings, 2, 'POLYGON (
      (10 10, 10 14, 14 14, 14 10, 10 10),
      (11 11, 11 12, 12 12, 12 11, 11 11),
      (13 11, 13 12, 13.5 12, 13.5 11, 13 11))')

    assert_raises(NoMethodError) do
      read('POINT (0 0)').num_interior_rings
    end
  end
end
