# frozen_string_literal: true

require 'test_helper'

describe 'Concave Hull Of Polygons Tests' do
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  it 'handles empty polygons' do
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:concave_hull_of_polygons)

    geom = read('POLYGON EMPTY')

    assert(geom.concave_hull_of_polygons(0.7).eql?(read('POLYGON EMPTY')))
  end

  it 'handles a multipolygon' do
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:concave_hull_of_polygons)

    geom = read('MULTIPOLYGON(((0 0, 0 1, 1 1, 1 0, 0 0)))')

    assert(geom.concave_hull_of_polygons(0.7).eql?(read('MULTIPOLYGON(((0 0, 0 1, 1 1, 1 0, 0 0)))')))
  end
end
