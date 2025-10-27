# frozen_string_literal: true

require 'test_helper'

describe '#polygon_hull_simplify' do
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def tester(expected, geom, *args, **options)
    skip unless ENV['FORCE_TESTS'] || !geom.respond_to?(:polygon_hull_simplify)

    simple_tester(:polygon_hull_simplify, expected, geom, *args, **options)
  end

  it 'handles a POLYGON' do
    tester(
      'POLYGON ((10 90, 50 90, 90 90, 90 10, 10 10, 10 90))',
      'POLYGON ((10 90, 40 60, 20 40, 40 20, 70 50, 40 30, 30 40, 60 70, 50 90, 90 90, 90 10, 10 10, 10 90))',
      0.5,
      outer: true
    )

    tester(
      'POLYGON ((10 90, 40 60, 30 40, 60 70, 50 90, 90 90, 90 10, 10 10, 10 90))',
      'POLYGON ((10 90, 40 60, 20 40, 40 20, 70 50, 40 30, 30 40, 60 70, 50 90, 90 90, 90 10, 10 10, 10 90))',
      0.7,
      outer: true
    )

    tester(
      'POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))',
      'POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))',
      0.7,
      outer: true
    )
  end

  it 'handles an empty POLYGON' do
    tester('POLYGON EMPTY', 'POLYGON EMPTY', 0.5, outer: true)
  end

  it 'handles a mode' do
    tester(
      'POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))',
      'POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))',
      0.7,
      mode: :area_ratio,
      outer: true
    )
  end
end
