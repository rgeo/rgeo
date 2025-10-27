# frozen_string_literal: true

require 'test_helper'

class GeometryMaximumInscribledCircleTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_maximum_inscribed_circle
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:maximum_inscribed_circle)

    geom = read('POLYGON ((100 200, 200 200, 200 100, 100 100, 100 200))')
    output = geom.maximum_inscribed_circle(0.001)

    assert_equal('LINESTRING (150 150, 150 200)', write(output))
  end
end
