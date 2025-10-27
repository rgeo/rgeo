# frozen_string_literal: true

require 'test_helper'

class GeometrySimplifyTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_simplify
    simple_tester(
      :simplify,
      'LINESTRING (0 0, 5 10, 10 0, 10 9, 0 9)',
      'LINESTRING(0 0, 3 4, 5 10, 10 0, 10 9, 5 11, 0 9)',
      2
    )
  end
end
