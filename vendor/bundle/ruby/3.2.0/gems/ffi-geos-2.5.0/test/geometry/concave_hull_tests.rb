# frozen_string_literal: true

require 'test_helper'

describe 'Geometry Concave Hull Tests' do
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def tester(expected, geom, **options)
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:concave_hull)

    simple_tester(
      :concave_hull,
      expected,
      geom,
      **options
    )
  end

  it 'returns a concave hull' do
    tester(
      'POLYGON ((30 70, 10 90, 60 72, 90 90, 90 60, 90 10, 60 30, 10 10, 40 40, 60 50, 47 66, 40 60, 30 70))',
      'MULTIPOINT ((10 90), (10 10), (90 10), (90 90), (40 40), (60 30), (30 70), (40 60), (60 50), (60 72), (47 66), (90 60))'
    )
  end

  it 'handles a concave hull by length' do
    tester(
      'POLYGON ((30 70, 10 90, 60 72, 90 90, 90 60, 90 10, 60 30, 10 10, 40 40, 30 70))',
      'MULTIPOINT ((10 90), (10 10), (90 10), (90 90), (40 40), (60 30), (30 70), (40 60), (60 50), (60 72), (47 66), (90 60))',
      length: 50
    )
  end
end
