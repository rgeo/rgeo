# frozen_string_literal: true

require 'test_helper'

class GeometryPointOnSurfaceTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_point_on_surface_and_representative_point
    %w{
      point_on_surface
      representative_point
    }.each do |method|
      simple_tester(
        method,
        'POINT (0 0)',
        'POINT (0 0)'
      )

      simple_tester(
        method,
        'POINT (5 0)',
        'LINESTRING(0 0, 5 0, 10 0)'
      )

      simple_tester(
        method,
        'POINT (5 5)',
        'POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))'
      )
    end
  end
end
