# frozen_string_literal: true

require 'test_helper'

class GeometryEqualTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_eql
    geom_a = read('POINT(1.0 1.0)')
    geom_b = read('POINT(2.0 2.0)')

    %w{ eql? equals? }.each do |method|
      assert(geom_a.send(method, geom_a), "Expected geoms to be equal using #{method}")
      refute(geom_a.send(method, geom_b), "Expected geoms to not be equal using #{method}")
    end
  end

  def test_equals_operator
    geom_a = read('POINT(1.0 1.0)')
    geom_b = read('POINT(2.0 2.0)')

    refute_equal(geom_a, geom_b, 'Expected geoms to not be equal using ==')
    refute_equal(geom_a, 'test', 'Expected geoms to not be equal using ==')
  end

  def test_eql_exact
    geom_a = read('POINT(1.0 1.0)')
    geom_b = read('POINT(2.0 2.0)')

    %w{ eql_exact? equals_exact? exactly_equals? }.each do |method|
      refute(geom_a.send(method, geom_b, 0.001), "Expected geoms to not be equal using #{method}")
    end
  end

  def test_eql_almost_default
    geom = read('POINT (1 1)')
    geom_a = read('POINT (1.0000001 1.0000001)')
    geom_b = read('POINT (1.000001 1.000001)')

    %w{ eql_almost? equals_almost? almost_equals? }.each do |method|
      assert(geom.send(method, geom_a), "Expected geoms to be equal using #{method}")
      refute(geom.send(method, geom_b), "Expected geoms to not be equal using #{method}")
    end
  end

  def test_eql_almost
    geom_a = read('POINT(1.0 1.0)')
    geom_b = read('POINT(1.1 1.1)')

    refute_equal(geom_a, geom_b)

    %w{ eql_almost? equals_almost? almost_equals? }.each do |method|
      assert(geom_a.send(method, geom_b, 0), "Expected geoms to be equal using #{method}")
      refute(geom_a.send(method, geom_b, 1), "Expected geoms to not be equal using #{method}")
    end
  end
end
