# frozen_string_literal: true

require 'test_helper'

class GeometryBuildAreaTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_build_area
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:build_area)

    geom = read('GEOMETRYCOLLECTION (LINESTRING(0 0, 0 1, 1 1), LINESTRING (1 1, 1 0, 0 0))')

    assert_equal('POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))', write(geom.build_area))
  end
end
