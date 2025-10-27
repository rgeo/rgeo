# frozen_string_literal: true

require 'test_helper'

class GeometryAreaTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_area
    simple_tester(:area, 1.0, 'POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0))')
    simple_tester(:area, 0.0, 'POINT (0 0)')
    simple_tester(:area, 0.0, 'LINESTRING (0 0 , 10 0)')
  end
end
