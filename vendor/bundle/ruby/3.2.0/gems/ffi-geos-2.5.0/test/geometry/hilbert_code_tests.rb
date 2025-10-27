# frozen_string_literal: true

require 'test_helper'

describe '#hilbert_code' do
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  it 'handles various points on the Hilbert curve' do
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:hilbert_code)

    geom_a = read('POINT (0 0)')
    geom_b = read('POINT (1 1)')
    extent = read('POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))')

    assert_equal(0, geom_a.hilbert_code(extent, 1))
    assert_equal(0, geom_a.hilbert_code(extent, 16))
    assert_equal(10, geom_b.hilbert_code(extent, 2))
    assert_equal(43690, geom_b.hilbert_code(extent, 8))
    assert_equal(2863311530, geom_b.hilbert_code(extent, 16))
  end

  it 'can calculate the midpoint' do
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:hilbert_code)

    extent = read('POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))')

    assert_equal(2, extent.hilbert_code(extent, 2))
  end

  it 'handles out of bounds' do
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:hilbert_code)

    geom = read('POINT (0 0)')
    extent = read('POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))')

    assert_raises(Geos::GEOSException) do
      geom.hilbert_code(extent, 17)
    end
  end
end
