# frozen_string_literal: true

require 'test_helper'

describe 'X, Y, Z, M' do
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  it 'can get X, Y, Z, M from a 2D POINT' do
    geom = read('POINT (1 2)')

    assert_equal(1, geom.x)
    assert_equal(2, geom.y)
    assert_predicate(geom.z, :nan?)
    assert_predicate(geom.m, :nan?) if geom.respond_to?(:m)
  end

  it 'can get Z, M from a 3D POINT' do
    geom = read('POINT Z (1 2 3)')

    assert_equal(3, geom.z)
    assert_predicate(geom.m, :nan?) if geom.respond_to?(:m)
  end

  it 'can get Z, M from an M POINT' do
    geom = read('POINT M (1 2 4)')

    assert_predicate(geom.z, :nan?)
    assert_equal(4, geom.m) if geom.respond_to?(:m)
  end

  it 'can get Z, M from a ZM POINT' do
    geom = read('POINT ZM (1 2 3 4)')

    assert_equal(3, geom.z)
    assert_equal(4, geom.m) if geom.respond_to?(:m)
  end

  it 'handles an empty POINT' do
    geom = read('POINT EMPTY')

    assert_raises(Geos::GEOSException, 'UnsupportedOperationException') { geom.x }
    assert_raises(Geos::GEOSException, 'UnsupportedOperationException') { geom.y }
    assert_raises(Geos::GEOSException, 'UnsupportedOperationException') { geom.z }
    assert_raises(Geos::GEOSException, 'UnsupportedOperationException') { geom.m } if geom.respond_to?(:m)
  end
end
