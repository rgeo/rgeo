# frozen_string_literal: true

require 'test_helper'

class GeometryRelationshipsTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_relationships
    tester = lambda { |geom_a, geom_b, tests|
      tests.each do |test|
        expected, method, args = test

        next unless ENV['FORCE_TESTS'] || geom_a.respond_to?(method)

        value = geom_a.send(method, *([geom_b] + Array(args)))

        assert_equal(expected, value)
      end
    }

    tester[read('POINT(0 0)'), read('POINT(0 0)'), [
      [false, :disjoint?],
      [false, :touches?],
      [true, :intersects?],
      [false, :crosses?],
      [true, :within?],
      [true, :contains?],
      [false, :overlaps?],
      [true, :eql?],
      [true, :eql_exact?, TOLERANCE],
      [true, :covers?],
      [true, :covered_by?]
    ]]

    tester[read('POINT(0 0)'), read('LINESTRING(0 0, 10 0)'), [
      [false, :disjoint?],
      [true, :touches?],
      [true, :intersects?],
      [false, :crosses?],
      [false, :within?],
      [false, :contains?],
      [false, :overlaps?],
      [false, :eql?],
      [false, :eql_exact?, TOLERANCE],
      [false, :covers?],
      [true, :covered_by?]
    ]]

    tester[read('POINT(5 0)'), read('LINESTRING(0 0, 10 0)'), [
      [false, :disjoint?],
      [false, :touches?],
      [true, :intersects?],
      [false, :crosses?],
      [true, :within?],
      [false, :contains?],
      [false, :overlaps?],
      [false, :eql?],
      [false, :eql_exact?, TOLERANCE],
      [false, :covers?],
      [true, :covered_by?]
    ]]

    tester[read('LINESTRING(5 -5, 5 5)'), read('LINESTRING(0 0, 10 0)'), [
      [false, :disjoint?],
      [false, :touches?],
      [true, :intersects?],
      [true, :crosses?],
      [false, :within?],
      [false, :contains?],
      [false, :overlaps?],
      [false, :eql?],
      [false, :eql_exact?, TOLERANCE],
      [false, :covers?],
      [false, :covered_by?]
    ]]

    tester[read('LINESTRING(5 0, 15 0)'), read('LINESTRING(0 0, 10 0)'), [
      [false, :disjoint?],
      [false, :touches?],
      [true, :intersects?],
      [false, :crosses?],
      [false, :within?],
      [false, :contains?],
      [true, :overlaps?],
      [false, :eql?],
      [false, :eql_exact?, TOLERANCE],
      [false, :covers?],
      [false, :covered_by?]
    ]]

    tester[read('LINESTRING(0 0, 5 0, 10 0)'), read('LINESTRING(0 0, 10 0)'), [
      [false, :disjoint?],
      [false, :touches?],
      [true, :intersects?],
      [false, :crosses?],
      [true, :within?],
      [true, :contains?],
      [false, :overlaps?],
      [true, :eql?],
      [false, :eql_exact?, TOLERANCE],
      [true, :covers?],
      [true, :covered_by?]
    ]]

    tester[read('POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))'), read('POLYGON((5 -5, 5 5, 15 5, 15 -5, 5 -5))'), [
      [false, :disjoint?],
      [false, :touches?],
      [true, :intersects?],
      [false, :crosses?],
      [false, :within?],
      [false, :contains?],
      [true, :overlaps?],
      [false, :eql?],
      [false, :eql_exact?, TOLERANCE],
      [false, :covers?],
      [false, :covered_by?]
    ]]

    tester[read('POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))'), read('POINT(15 15)'), [
      [true, :disjoint?],
      [false, :touches?],
      [false, :intersects?],
      [false, :crosses?],
      [false, :within?],
      [false, :contains?],
      [false, :overlaps?],
      [false, :eql?],
      [false, :eql_exact?, TOLERANCE],
      [false, :covers?],
      [false, :covered_by?]
    ]]
  end
end
