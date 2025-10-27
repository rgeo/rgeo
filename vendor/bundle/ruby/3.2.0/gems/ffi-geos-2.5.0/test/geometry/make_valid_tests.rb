# frozen_string_literal: true

require 'test_helper'

class GeometryMakeValidTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_make_valid
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:make_valid)

    geom = read('POLYGON((0 0, 1 1, 0 1, 1 0, 0 0))')

    assert_equal(
      if Geos::GEOS_NICE_VERSION > '030900'
        'MULTIPOLYGON (((1 0, 0 0, 0.5 0.5, 1 0)), ((1 1, 0.5 0.5, 0 1, 1 1)))'
      else
        'MULTIPOLYGON (((0 0, 0.5 0.5, 1 0, 0 0)), ((0.5 0.5, 0 1, 1 1, 0.5 0.5)))'
      end,
      write(geom.make_valid)
    )
  end
end
