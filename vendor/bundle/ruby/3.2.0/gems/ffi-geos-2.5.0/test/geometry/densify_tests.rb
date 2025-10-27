# frozen_string_literal: true

require 'test_helper'

describe 'Geometry Densify Tests' do
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def tester(expected, geom, tolerence)
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:densify)

    simple_tester(
      :densify,
      expected,
      geom,
      tolerence
    )
  end

  it 'can densify with tolerance greater than or equal to length of all edges' do
    tester(
      'POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0), (1 1, 1 2, 2 2, 2 1, 1 1))',
      'POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0), (1 1, 1 2, 2 2, 2 1, 1 1))',
      10.0
    )
  end

  it 'can densify with a tolerance that evenly subdivides all outer and inner edges' do
    tester(
      'POLYGON ((0 0, 5 0, 10 0, 10 5, 10 10, 5 10, 0 10, 0 5, 0 0), (1 1, 1 4, 1 7, 4 7, 7 7, 7 4, 7 1, 4 1, 1 1))',
      'POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0), (1 1, 1 7, 7 7, 7 1, 1 1))',
      5.0
    )
  end

  it 'can densify a LINESTRING' do
    tester(
      'LINESTRING (0 0, 0 3, 0 6)',
      'LINESTRING (0 0, 0 6 )',
      3.0
    )
  end

  it 'can ensure that tolerance results in the right number of subdivisions' do
    tester(
      'LINESTRING (0 0, 0 2, 0 4, 0 6)',
      'LINESTRING (0 0, 0 6 )',
      2.9999999
    )
  end

  it 'can densify a LINEARRING' do
    tester(
      'LINEARRING (0 0, 0 3, 0 6, 3 6, 6 6, 4 4, 2 2, 0 0)',
      'LINEARRING (0 0, 0 6, 6 6, 0 0)',
      3.0
    )
  end

  it 'can densify a POINT' do
    tester(
      'POINT (0 0)',
      'POINT (0 0)',
      3.0
    )
  end

  it 'can densify a MULTIPOINT' do
    tester(
      'MULTIPOINT ((0 0), (10 10))',
      'MULTIPOINT ((0 0), (10 10))',
      3.0
    )
  end

  it 'can densify an empty polygon' do
    tester(
      'POLYGON EMPTY',
      'POLYGON EMPTY',
      3.0
    )
  end

  it 'densify with an invalid tolerances should fail' do
    geom = read('POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0))')

    assert_raises(Geos::GEOSException, 'IllegalArgumentException: Tolerance must be positive') do
      geom.densify(-1.0)
    end
  end
end
