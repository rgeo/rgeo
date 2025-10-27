# frozen_string_literal: true

require 'test_helper'

class GeometryStartAndEndPointTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_start_and_end_points
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:start_point)

    geom = read('LINESTRING (10 10, 10 14, 14 14, 14 10)')
    simple_tester(:start_point, 'POINT (10 10)', geom)
    simple_tester(:end_point, 'POINT (14 10)', geom)

    geom = read('LINEARRING (11 11, 11 12, 12 11, 11 11)')
    simple_tester(:start_point, 'POINT (11 11)', geom)
    simple_tester(:start_point, 'POINT (11 11)', geom)
  end
end
