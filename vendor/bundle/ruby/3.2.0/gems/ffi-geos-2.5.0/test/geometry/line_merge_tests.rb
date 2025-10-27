# frozen_string_literal: true

require 'test_helper'

class GeometryTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_line_merge
    simple_tester(
      :line_merge,
      'LINESTRING (0 0, 10 10, 10 0, 5 0, 5 -5)',
      'MULTILINESTRING(
        (0 0, 10 10),
        (10 10, 10 0),
        (5 0, 10 0),
        (5 -5, 5 0)
      )'
    )
  end
end
