# frozen_string_literal: true

require 'test_helper'

class GeometryCentroidTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_centroid_and_center
    %w{
      centroid
      center
    }.each do |method|
      simple_tester(
        method,
        'POINT (0 0)',
        'POINT(0 0)'
      )

      simple_tester(
        method,
        'POINT (5 5)',
        'LINESTRING(0 0, 10 10)'
      )

      snapped_tester(
        method,
        'POINT (5 4)',
        'POLYGON((0 0, 0 10, 5 5, 10 10, 10 0, 0 0))'
      )
    end
  end
end
