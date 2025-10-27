# frozen_string_literal: true

require 'test_helper'

class GeometryPrecisionTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_precision
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:precision)

    geom = read('POLYGON EMPTY')
    scale = geom.precision

    assert_in_delta(0.0, scale)

    geom_with_precision = geom.with_precision(2.0)

    assert_equal('POLYGON EMPTY', write(geom_with_precision))
    scale = geom_with_precision.precision

    assert_in_delta(2.0, scale)
  end

  def test_with_precision
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:with_precision)

    geom = read('LINESTRING(1 0, 2 0)')

    geom_with_precision = geom.with_precision(5.0)

    assert_equal('LINESTRING EMPTY', write(geom_with_precision))

    geom_with_precision = geom.with_precision(5.0, keep_collapsed: true)

    assert_equal('LINESTRING (0 0, 0 0)', write(geom_with_precision))
  end
end
