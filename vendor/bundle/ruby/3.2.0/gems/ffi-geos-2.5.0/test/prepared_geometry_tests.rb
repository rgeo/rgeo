# frozen_string_literal: true

require 'test_helper'

class PreparedGeometryTests < Minitest::Test
  include TestHelper

  POINT_A = 'POINT(0 0)'
  POINT_B = 'POINT(5 0)'
  POINT_C = 'POINT(15 15)'
  LINESTRING_A = 'LINESTRING(0 0, 10 0)'
  LINESTRING_B = 'LINESTRING(5 -5, 5 5)'
  LINESTRING_C = 'LINESTRING(5 0, 15 0)'
  LINESTRING_D = 'LINESTRING(0 0, 5 0, 10 0)'
  POLYGON_A = 'POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))'
  POLYGON_B = 'POLYGON((5 -5, 5 5, 15 5, 15 -5, 5 -5))'

  def relationship_tester(method, *expected)
    [
      [POINT_A, POINT_A],
      [POINT_A, LINESTRING_A],
      [POINT_B, LINESTRING_A],
      [LINESTRING_B, LINESTRING_A],
      [LINESTRING_C, LINESTRING_A],
      [LINESTRING_D, LINESTRING_A],
      [POLYGON_A, POLYGON_B],
      [POLYGON_A, POINT_C]
    ].each_with_index do |(geom_a, geom_b), i|
      geom_a = read(geom_a).to_prepared
      geom_b = read(geom_b)

      value = geom_a.send(method, geom_b)

      assert_equal(expected[i], value)
    end
  end

  def test_disjoint
    skip unless ENV['FORCE_TESTS'] || defined?(Geos::PreparedGeometry)

    relationship_tester(:disjoint?, false, false, false, false, false, false, false, true)
  end

  def test_touches
    skip unless ENV['FORCE_TESTS'] || defined?(Geos::PreparedGeometry)

    relationship_tester(:touches?, false, true, false, false, false, false, false, false)
  end

  def test_intersects
    skip unless ENV['FORCE_TESTS'] || defined?(Geos::PreparedGeometry)

    relationship_tester(:intersects?, true, true, true, true, true, true, true, false)
  end

  def test_crosses
    skip unless ENV['FORCE_TESTS'] || defined?(Geos::PreparedGeometry)

    relationship_tester(:crosses?, false, false, false, true, false, false, false, false)
  end

  def test_within
    skip unless ENV['FORCE_TESTS'] || defined?(Geos::PreparedGeometry)

    relationship_tester(:within?, true, false, true, false, false, true, false, false)
  end

  def test_contains
    skip unless ENV['FORCE_TESTS'] || defined?(Geos::PreparedGeometry)

    relationship_tester(:contains?, true, false, false, false, false, true, false, false)
  end

  def test_contains_properly
    skip unless ENV['FORCE_TESTS'] || defined?(Geos::PreparedGeometry)

    relationship_tester(:contains_properly?, true, false, false, false, false, false, false, false)
  end

  def test_overlaps
    skip unless ENV['FORCE_TESTS'] || defined?(Geos::PreparedGeometry)

    relationship_tester(:overlaps?, false, false, false, false, true, false, true, false)
  end

  def test_covers
    skip unless ENV['FORCE_TESTS'] || defined?(Geos::PreparedGeometry)

    relationship_tester(:covers?, true, false, false, false, false, true, false, false)
  end

  def test_covered_by
    skip unless ENV['FORCE_TESTS'] || defined?(Geos::PreparedGeometry)

    relationship_tester(:covered_by?, true, true, true, false, false, true, false, false)
  end

  def test_cant_clone
    skip unless ENV['FORCE_TESTS'] || defined?(Geos::PreparedGeometry)

    assert_raises(NoMethodError) do
      read(POINT_A).to_prepared.clone
    end
  end

  def test_cant_dup
    skip unless ENV['FORCE_TESTS'] || defined?(Geos::PreparedGeometry)

    assert_raises(NoMethodError) do
      read(POINT_A).to_prepared.dup
    end
  end

  def test_initializer_type_exception
    skip unless ENV['FORCE_TESTS'] || defined?(Geos::PreparedGeometry)

    assert_raises(TypeError) do
      Geos::PreparedGeometry.new('hello world')
    end
  end

  def test_distance
    skip unless ENV['FORCE_TESTS'] || (defined?(Geos::PreparedGeometry) && Geos::FFIGeos.respond_to?(:GEOSPreparedDistance_r))

    assert_in_delta(5.0, read(POINT_A).to_prepared.distance(read(POINT_B)))
  end

  def test_distance_within
    skip unless ENV['FORCE_TESTS'] || (defined?(Geos::PreparedGeometry) && Geos::FFIGeos.respond_to?(:GEOSPreparedDistanceWithin_r))

    assert(read(POINT_A).to_prepared.distance_within?(read(POINT_B), 30.0))
    refute(read(POINT_A).to_prepared.distance_within?(read(POINT_B), 3.0))
  end

  def test_nearest_points
    skip unless ENV['FORCE_TESTS'] || (defined?(Geos::PreparedGeometry) && Geos::FFIGeos.respond_to?(:GEOSPreparedNearestPoints_r))

    coord_seq = read('POLYGON((1 1, 1 5, 5 5, 5 1, 1 1))').to_prepared.nearest_points(read('POLYGON((8 8, 9 9, 9 10, 8 8))'))

    assert_in_delta(5.0, coord_seq.x[0])
    assert_in_delta(5.0, coord_seq.y[0])
    assert_in_delta(8.0, coord_seq.x[1])
    assert_in_delta(8.0, coord_seq.y[1])
  end
end
