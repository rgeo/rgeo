# frozen_string_literal: true

require 'test_helper'

describe 'Geometry#has_z? and #has_m?' do
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def tester(geom, z: false, m: false)
    geom = read(geom)

    assert_equal(z, geom.has_z?) if Geos::Geometry.method_defined?(:has_z?)
    assert_equal(m, geom.has_m?) if Geos::Geometry.method_defined?(:has_m?)
  end

  it 'handles 2D POLYGON' do
    tester('POLYGON ((1 -2, 9 -2, 9 5, 1 5, 1 -2))', z: false, m: false)
  end

  it 'handles M POINT' do
    tester('POINT M (1 2 3)', z: false, m: true)
  end

  it 'handles an empty POINT' do
    tester('POINT EMPTY', z: false, m: false)
  end

  it 'handles an empty Z POINT' do
    tester('POINT Z EMPTY', z: true, m: false)
  end

  it 'handles an M POINT' do
    tester('POINT M EMPTY', z: false, m: true)
  end

  it 'handles an ZM POINT' do
    tester('POINT ZM EMPTY', z: true, m: true)
  end
end
