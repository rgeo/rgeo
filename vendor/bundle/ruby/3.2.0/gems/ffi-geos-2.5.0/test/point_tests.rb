# frozen_string_literal: true

require 'test_helper'

class PointTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_default_srid
    geom = read('POINT(0 0)')

    assert_equal(0, geom.srid)
  end

  def test_setting_srid_manually
    geom = read('POINT(0 0)')
    geom.srid = 4326

    assert_equal(4326, geom.srid)
  end

  def test_dimensions
    geom = read('POINT(1 2)')

    assert_equal(0, geom.dimensions)

    geom = read('POINT(1 2 3)')

    assert_equal(0, geom.dimensions)
  end

  def test_num_geometries
    geom = read('POINT(1 2)')

    assert_equal(1, geom.num_geometries)
  end

  def test_get_x
    geom = read('POINT (1 2)')

    assert_equal(1, geom.get_x)
    assert_equal(1, geom.x)

    assert_raises(NoMethodError) do
      read('LINESTRING (0 0, 1 1)').get_x
    end
  end

  def test_get_y
    geom = read('POINT (1 2)')

    assert_equal(2, geom.get_y)
    assert_equal(2, geom.y)

    assert_raises(NoMethodError) do
      read('LINESTRING (0 0, 1 1)').get_x
    end
  end

  def test_get_z
    geom = read('POINT Z (1 2 3)')

    assert_equal(3, geom.get_z)
    assert_equal(3, geom.z)
    assert_raises(NoMethodError) do
      read('LINESTRING (0 0, 1 1)').get_z
    end
  end

  def test_simplify_clone_srid_correctly
    geom = read('POINT (0 0)')
    geom.srid = 4326

    Geos.srid_copy_policy = :zero

    assert_equal(0, geom.simplify(0.1).srid)

    Geos.srid_copy_policy = :lenient

    assert_equal(4326, geom.simplify(0.1).srid)

    Geos.srid_copy_policy = :strict

    assert_equal(4326, geom.simplify(0.1).srid)
  ensure
    Geos.srid_copy_policy = :default
  end

  def test_extract_unique_points_clone_srid_correctly
    geom = read('POINT (0 0)')
    geom.srid = 4326

    Geos.srid_copy_policy = :zero

    assert_equal(0, geom.extract_unique_points.srid)

    Geos.srid_copy_policy = :lenient

    assert_equal(4326, geom.extract_unique_points.srid)

    Geos.srid_copy_policy = :strict

    assert_equal(4326, geom.extract_unique_points.srid)
  ensure
    Geos.srid_copy_policy = :default
  end

  def test_normalize
    geom = read('POINT(10 10)')

    assert_same(geom, geom.normalize)
    assert_same(geom, geom.normalize!)
  end

  def test_x_max
    geom = read('POINT (-10 -15)')

    assert_equal(-10, geom.x_max)
  end

  def test_x_min
    geom = read('POINT (-10 -15)')

    assert_equal(-10, geom.x_min)
  end

  def test_y_max
    geom = read('POINT (-10 -15)')

    assert_equal(-15, geom.y_max)
  end

  def test_y_min
    geom = read('POINT (-10 -15)')

    assert_equal(-15, geom.y_min)
  end

  def test_z_max
    geom = read('POINT (-10 -15)')

    assert_equal(0, geom.z_max)

    geom = read('POINT Z (-10 -15 -20)')

    assert_equal(-20, geom.z_max)
  end

  def test_z_min
    geom = read('POINT (-10 -15)')

    assert_equal(0, geom.z_min)

    geom = read('POINT Z (-10 -15 -20)')

    assert_equal(-20, geom.z_min)
  end

  def test_snap_to_grid
    wkt = 'POINT (10.12 10.12)'
    expected = 'POINT (10 10)'

    simple_bang_tester(:snap_to_grid, expected, wkt, 1)
  end

  def test_snap_to_grid_empty
    assert_empty(read('POINT EMPTY').snap_to_grid!, 'Expected an empty Point')
  end

  def test_snap_to_grid_with_srid
    wkt = 'POINT (10.12 10.12)'
    expected = 'POINT (10 10)'

    srid_copy_tester(:snap_to_grid, expected, 0, :zero, wkt, 1)
    srid_copy_tester(:snap_to_grid, expected, 4326, :lenient, wkt, 1)
    srid_copy_tester(:snap_to_grid, expected, 4326, :strict, wkt, 1)
  end

  def test_rotate
    writer.rounding_precision = 3

    wkt = 'POINT (1 1)'

    affine_tester(:rotate, 'POINT (29 11)', wkt, Math::PI / 2, [10.0, 20.0])
    affine_tester(:rotate, 'POINT (-2 0)', wkt, -Math::PI / 2, [-1.0, 2.0])
    affine_tester(:rotate, 'POINT (19 1)', wkt, Math::PI / 2, read('POINT(10 10)'))
    affine_tester(:rotate, 'POINT (-0.5 0.5)', wkt, Math::PI / 2, read('LINESTRING(0 0, 1 0)'))
  end

  def test_rotate_x
    writer.rounding_precision = 0
    writer.output_dimensions = 3

    wkt = 'POINT Z (1 1 1)'

    affine_tester(:rotate_x, 'POINT Z (1 -1 -1)', wkt, Math::PI)
    affine_tester(:rotate_x, 'POINT Z (1 -1 1)', wkt, Math::PI / 2)
    affine_tester(:rotate_x, 'POINT Z (1 1 -1)', wkt, Math::PI + (Math::PI / 2))
    affine_tester(:rotate_x, wkt, wkt, Math::PI * 2)
  end

  def test_rotate_y
    writer.rounding_precision = 0
    writer.output_dimensions = 3

    wkt = 'POINT Z (1 1 1)'

    affine_tester(:rotate_y, 'POINT Z (-1 1 -1)', wkt, Math::PI)
    affine_tester(:rotate_y, 'POINT Z (1 1 -1)', wkt, Math::PI / 2)
    affine_tester(:rotate_y, 'POINT Z (-1 1 1)', wkt, Math::PI + (Math::PI / 2))
    affine_tester(:rotate_y, wkt, wkt, Math::PI * 2)
  end

  def test_rotate_z
    writer.rounding_precision = 0

    wkt = 'POINT (1 1)'

    affine_tester(:rotate_z, 'POINT (-1 -1)', wkt, Math::PI)
    affine_tester(:rotate_z, 'POINT (-1 1)', wkt, Math::PI / 2)
    affine_tester(:rotate_z, 'POINT (1 -1)', wkt, Math::PI + (Math::PI / 2))
    affine_tester(:rotate_z, wkt, wkt, Math::PI * 2)
  end

  def test_scale
    affine_tester(:scale, 'POINT (5 5)', 'POINT (1 1)', 5, 5)
    affine_tester(:scale, 'POINT (3 2)', 'POINT (1 1)', 3, 2)

    writer.output_dimensions = 3
    affine_tester(:scale, 'POINT Z (40 40 40)', 'POINT Z (10 20 -5)', 4, 2, -8)
  end

  def test_scale_hash
    affine_tester(:scale, 'POINT (5 5)', 'POINT (1 1)', x: 5, y: 5)
    affine_tester(:scale, 'POINT (3 2)', 'POINT (1 1)', x: 3, y: 2)

    writer.output_dimensions = 3
    affine_tester(:scale, 'POINT Z (40 40 40)', 'POINT Z (10 20 -5)', x: 4, y: 2, z: -8)
  end

  def test_trans_scale
    affine_tester(:trans_scale, 'POINT (2 2)', 'POINT (1 1)', 1, 1, 1, 1)
    affine_tester(:trans_scale, 'POINT (3 3)', 'POINT (2 2)', 1, 1, 1, 1)
    affine_tester(:trans_scale, 'POINT (0 0)', 'POINT (1 1)', -1, -1, -1, -1)
    affine_tester(:trans_scale, 'POINT (1 2)', 'POINT (1 1)', 0, 1, 1, 1)
    affine_tester(:trans_scale, 'POINT (2 1)', 'POINT (1 1)', 1, 0, 1, 1)
    affine_tester(:trans_scale, 'POINT (0 2)', 'POINT (1 1)', 1, 1, 0, 1)
    affine_tester(:trans_scale, 'POINT (2 0)', 'POINT (1 1)', 1, 1, 1, 0)
    affine_tester(:trans_scale, 'POINT (3 2)', 'POINT (1 1)', 2, 1, 1, 1)
    affine_tester(:trans_scale, 'POINT (2 3)', 'POINT (1 1)', 1, 2, 1, 1)
    affine_tester(:trans_scale, 'POINT (4 2)', 'POINT (1 1)', 1, 1, 2, 1)
    affine_tester(:trans_scale, 'POINT (2 4)', 'POINT (1 1)', 1, 1, 1, 2)
    affine_tester(:trans_scale, 'POINT (15 28)', 'POINT (1 1)', 2, 3, 5, 7)

    writer.output_dimensions = 3
    affine_tester(:trans_scale, 'POINT Z (15 28 1)', 'POINT Z (1 1 1)', 2, 3, 5, 7)
  end

  def test_trans_scale_hash
    affine_tester(:trans_scale, 'POINT (2 2)', 'POINT (1 1)', delta_x: 1, delta_y: 1, x_factor: 1, y_factor: 1)

    writer.output_dimensions = 3
    affine_tester(:trans_scale, 'POINT Z (15 28 1)', 'POINT Z (1 1 1)', delta_x: 2, delta_y: 3, x_factor: 5, y_factor: 7)
    affine_tester(:trans_scale, 'POINT Z (3 1 1)', 'POINT Z (1 1 1)', delta_x: 2, z_factor: 2)
  end

  def test_translate
    affine_tester(:translate, 'POINT (5 12)', 'POINT (0 0)', 5, 12)

    writer.output_dimensions = 3
    affine_tester(:translate, 'POINT Z (-3 -7 3)', 'POINT Z (0 0 0)', -3, -7, 3)
  end

  def test_translate_hash
    affine_tester(:translate, 'POINT (5 12)', 'POINT (0 0)', x: 5, y: 12)

    writer.output_dimensions = 3
    affine_tester(:translate, 'POINT Z (-3 -7 3)', 'POINT Z (0 0 0)', x: -3, y: -7, z: 3)
  end
end
