# frozen_string_literal: true

require 'test_helper'

class GeometryLengthTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_length
    simple_tester(:length, 4.0, 'POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0))')
    simple_tester(:length, 0.0, 'POINT (0 0)')
    simple_tester(:length, 10.0, 'LINESTRING (0 0 , 10 0)')
  end
end
