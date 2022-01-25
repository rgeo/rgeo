# frozen_string_literal: true

require 'test_helper'

class PolygonTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_default_srid
    geom = read('POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))')
    assert_equal(0, geom.srid)
  end

  def test_setting_srid_manually
    geom = read('POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))')
    geom.srid = 4326
    assert_equal(4326, geom.srid)
  end

  def test_dimensions
    geom = read('POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))')
    assert_equal(2, geom.dimensions)

    geom = read('POLYGON ((0 0 0, 5 0 0, 5 5 0, 0 5 0, 0 0 0))')
    assert_equal(2, geom.dimensions)
  end

  def test_num_geometries
    geom = read('POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))')
    assert_equal(1, geom.num_geometries)
  end

  def test_x_max
    geom = read('POLYGON ((0 0, 5 0, 8 9, -10 5, 0 0))')
    assert_equal(8, geom.x_max)
  end

  def test_x_min
    geom = read('POLYGON ((0 0, 5 0, 8 9, -10 5, 0 0))')
    assert_equal(-10, geom.x_min)
  end

  def test_y_max
    geom = read('POLYGON ((0 0, 5 0, 8 9, -10 5, 0 0))')
    assert_equal(9, geom.y_max)
  end

  def test_y_min
    geom = read('POLYGON ((0 0, 5 0, 8 9, -10 5, 0 0))')
    assert_equal(0, geom.y_min)
  end

  def test_z_max
    geom = read('POLYGON ((0 0, 5 0, 8 9, -10 5, 0 0))')
    assert_equal(0, geom.z_min)

    geom = read('POLYGON Z ((0 0 0, 5 0 3, 8 9 4, -10 5 3, 0 0 0))')
    assert_equal(4, geom.z_max)
  end

  def test_z_min
    geom = read('POLYGON ((0 0, 5 0, 8 9, -10 5, 0 0))')
    assert_equal(0, geom.z_min)

    geom = read('POLYGON Z ((0 0 0, 5 0 3, 8 9 4, -10 5 3, 0 0 0))')
    assert_equal(0, geom.z_min)
  end

  def test_snap_to_grid
    wkt = 'POLYGON ((-10.12 0, -10.12 5, -10.12 5, -10.12 6, -10.12 6, -10.12 6, -10.12 7, -10.12 7, -10.12 7, -10.12 8, -10.12 8, -9 8, -9 9, -10.12 0))'
    expected = 'POLYGON ((-10 0, -10 5, -10 6, -10 7, -10 8, -9 8, -9 9, -10 0))'

    simple_bang_tester(:snap_to_grid, expected, wkt, 1)
  end

  def test_snap_to_grid_with_illegal_result
    assert_raises(Geos::InvalidGeometryError) do
      read('POLYGON ((1 1, 10 10, 10 10, 1 1))').
        snap_to_grid
    end
  end

  def test_snap_to_grid_empty
    assert(read('POLYGON EMPTY').snap_to_grid!.empty?, 'Expected an empty Polygon')
  end

  def test_snap_to_grid_collapse_holes
    wkt = 'POLYGON ((0 0, 0 5, 5 5, 5 0, 0 0), (2.6 2.6, 2.7 2.6, 2.7 2.7, 2.6 2.7, 2.6 2.6))'

    assert_equal('POLYGON ((0 0, 0 5, 5 5, 5 0, 0 0))', write(read(wkt).snap_to_grid(1)))
  end

  def test_snap_to_grid_with_srid
    wkt = 'POLYGON ((0.1 0.1, 0.1 5.1, 5.1 5.1, 5.1 0.1, 0.1 0.1))'
    expected = 'POLYGON ((0 0, 0 5, 5 5, 5 0, 0 0))'

    srid_copy_tester(:snap_to_grid, expected, 0, :zero, wkt, 1)
    srid_copy_tester(:snap_to_grid, expected, 4326, :lenient, wkt, 1)
    srid_copy_tester(:snap_to_grid, expected, 4326, :strict, wkt, 1)
  end

  def test_rotate
    wkt = 'POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))'

    affine_tester(:rotate,
      'POLYGON ((30 10, 30 15, 25 15, 25 10, 30 10))',
      wkt,
      Math::PI / 2,
      [ 10.0, 20.0 ])

    affine_tester(:rotate,
      'POLYGON ((-3 1, -3 -4, 2 -4, 2 1, -3 1))',
      wkt,
      -Math::PI / 2,
      [ -1.0, 2.0 ])

    affine_tester(:rotate,
      'POLYGON ((2 2, -3 2, -3 -3, 2 -3, 2 2))',
      wkt,
      Math::PI, read('POINT(1 1)'))

    affine_tester(:rotate,
      'POLYGON ((0.5 -0.5, 0.5 4.5, -4.5 4.5, -4.5 -0.5, 0.5 -0.5))',
      wkt,
      Math::PI / 2,
      read('LINESTRING(0 0, 1 0)'))
  end

  def test_rotate_x
    writer.output_dimensions = 3

    wkt = 'POLYGON Z ((0 0 0, 5 0 0, 5 5 0, 0 5 0, 0 0 0))'

    affine_tester(:rotate_x,
      'POLYGON Z ((0 0 0, 5 0 0, 5 -5 0, 0 -5 0, 0 0 0))',
      wkt,
      Math::PI)

    affine_tester(:rotate_x,
      'POLYGON Z ((0 0 0, 5 0 0, 5 0 5, 0 0 5, 0 0 0))',
      wkt,
      Math::PI / 2)

    affine_tester(:rotate_x,
      'POLYGON Z ((0 0 0, 5 0 0, 5 0 -5, 0 0 -5, 0 0 0))',
      wkt,
      Math::PI + Math::PI / 2)

    affine_tester(:rotate_x,
      wkt,
      wkt,
      Math::PI * 2)
  end

  def test_rotate_y
    writer.output_dimensions = 3

    wkt = 'POLYGON Z ((0 0 0, 5 0 0, 5 5 0, 0 5 0, 0 0 0))'

    affine_tester(:rotate_y,
      'POLYGON Z ((0 0 0, -5 0 0, -5 5 0, 0 5 0, 0 0 0))',
      wkt,
      Math::PI)

    affine_tester(:rotate_y,
      'POLYGON Z ((0 0 0, 0 0 -5, 0 5 -5, 0 5 0, 0 0 0))',
      wkt,
      Math::PI / 2)

    affine_tester(:rotate_y,
      'POLYGON Z ((0 0 0, 0 0 5, 0 5 5, 0 5 0, 0 0 0))',
      wkt,
      Math::PI + Math::PI / 2)

    affine_tester(:rotate_y,
      wkt,
      wkt,
      Math::PI * 2)
  end

  def test_rotate_z
    affine_tester(:rotate_z,
      'POLYGON ((0 0, -5 0, -5 -5, 0 -5, 0 0))',
      'POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))',
      Math::PI)

    affine_tester(:rotate_z,
      'POLYGON ((0 0, 0 5, -5 5, -5 0, 0 0))',
      'POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))',
      Math::PI / 2)

    affine_tester(:rotate_z,
      'POLYGON ((0 0, 0 -5, 5 -5, 5 0, 0 0))',
      'POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))',
      Math::PI + Math::PI / 2)

    affine_tester(:rotate_z,
      'POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))',
      'POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))',
      Math::PI * 2)
  end

  def test_scale
    affine_tester(:scale,
      'POLYGON ((0 0, 25 0, 25 25, 0 25, 0 0))',
      'POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))',
      5,
      5)

    affine_tester(:scale,
      'POLYGON ((0 0, 15 0, 15 10, 0 10, 0 0))',
      'POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))',
      3,
      2)

    writer.output_dimensions = 3

    affine_tester(:scale,
      'POLYGON Z ((0 0 0, 20 0 0, 20 10 0, 0 10 0, 0 0 0))',
      'POLYGON Z ((0 0 0, 5 0 0, 5 5 0, 0 5 0, 0 0 0))',
      4,
      2,
      -8)
  end

  def test_scale_hash
    affine_tester(:scale,
      'POLYGON ((0 0, 25 0, 25 25, 0 25, 0 0))',
      'POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))',
      x: 5,
      y: 5)

    affine_tester(:scale,
      'POLYGON ((0 0, 15 0, 15 10, 0 10, 0 0))',
      'POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))',
      x: 3,
      y: 2)

    writer.output_dimensions = 3

    affine_tester(:scale,
      'POLYGON Z ((0 0 0, 20 0 0, 20 10 0, 0 10 0, 0 0 -80))',
      'POLYGON Z ((0 0 0, 5 0 0, 5 5 0, 0 5 0, 0 0 10))',
      x: 4,
      y: 2,
      z: -8)
  end

  def test_trans_scale
    affine_tester(:trans_scale, 'POLYGON ((2 2, 11 11, 21 2, 2 2))', 'POLYGON ((1 1, 10 10, 20 1, 1 1))', 1, 1, 1, 1)
    affine_tester(:trans_scale, 'POLYGON ((3 3, 12 12, 22 3, 3 3))', 'POLYGON ((2 2, 11 11, 21 2, 2 2))', 1, 1, 1, 1)
    affine_tester(:trans_scale, 'POLYGON ((0 0, -9 -9, -19 0, 0 0))', 'POLYGON ((1 1, 10 10, 20 1, 1 1))', -1, -1, -1, -1)
    affine_tester(:trans_scale, 'POLYGON ((1 2, 10 11, 20 2, 1 2))', 'POLYGON ((1 1, 10 10, 20 1, 1 1))', 0, 1, 1, 1)
    affine_tester(:trans_scale, 'POLYGON ((2 1, 11 10, 21 1, 2 1))', 'POLYGON ((1 1, 10 10, 20 1, 1 1))', 1, 0, 1, 1)
    affine_tester(:trans_scale, 'POLYGON ((2 0, 11 0, 21 0, 2 0))', 'POLYGON ((1 1, 10 10, 20 1, 1 1))', 1, 1, 1, 0)
    affine_tester(:trans_scale, 'POLYGON ((3 2, 12 11, 22 2, 3 2))', 'POLYGON ((1 1, 10 10, 20 1, 1 1))', 2, 1, 1, 1)
    affine_tester(:trans_scale, 'POLYGON ((2 3, 11 12, 21 3, 2 3))', 'POLYGON ((1 1, 10 10, 20 1, 1 1))', 1, 2, 1, 1)
    affine_tester(:trans_scale, 'POLYGON ((4 2, 22 11, 42 2, 4 2))', 'POLYGON ((1 1, 10 10, 20 1, 1 1))', 1, 1, 2, 1)
    affine_tester(:trans_scale, 'POLYGON ((2 4, 11 22, 21 4, 2 4))', 'POLYGON ((1 1, 10 10, 20 1, 1 1))', 1, 1, 1, 2)
    affine_tester(:trans_scale, 'POLYGON ((15 28, 60 91, 110 28, 15 28))', 'POLYGON ((1 1, 10 10, 20 1, 1 1))', 2, 3, 5, 7)

    writer.output_dimensions = 3
    affine_tester(:trans_scale, 'POLYGON Z ((15 28 1, 60 91 10, 110 28 1, 15 28 1))', 'POLYGON Z ((1 1 1, 10 10 10, 20 1 1, 1 1 1))', 2, 3, 5, 7)
  end

  def test_trans_scale_hash
    affine_tester(:trans_scale,
      'POLYGON ((2 2, 11 11, 21 2, 2 2))',
      'POLYGON ((1 1, 10 10, 20 1, 1 1))',
      delta_x: 1, delta_y: 1, x_factor: 1, y_factor: 1)

    writer.output_dimensions = 3

    affine_tester(:trans_scale, 'POLYGON Z ((15 28 1, 60 91 10, 110 28 1, 15 28 1))',
      'POLYGON Z ((1 1 1, 10 10 10, 20 1 1, 1 1 1))',
      delta_x: 2, delta_y: 3, x_factor: 5, y_factor: 7)

    affine_tester(:trans_scale, 'POLYGON Z ((3 1 1, 12 10 10, 22 1 1, 3 1 1))',
      'POLYGON Z ((1 1 1, 10 10 10, 20 1 1, 1 1 1))',
      delta_x: 2, z_factor: 2)
  end

  def test_translate
    affine_tester(:translate,
      'POLYGON ((5 12, 10 12, 10 17, 5 17, 5 12))',
      'POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))',
      5,
      12)

    writer.output_dimensions = 3

    affine_tester(:translate,
      'POLYGON Z ((-3 -7 3, 2 -7 3, 2 -2 3, -3 -2 3, -3 -7 3))',
      'POLYGON Z ((0 0 0, 5 0 0, 5 5 0, 0 5 0, 0 0 0))',
      -3,
      -7,
      3)
  end

  def test_translate_hash
    affine_tester(:translate,
      'POLYGON ((5 12, 10 12, 10 17, 5 17, 5 12))',
      'POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))',
      x: 5,
      y: 12)

    writer.output_dimensions = 3

    affine_tester(:translate,
      'POLYGON Z ((-3 -7 3, 2 -7 3, 2 -2 3, -3 -2 3, -3 -7 3))',
      'POLYGON Z ((0 0 0, 5 0 0, 5 5 0, 0 5 0, 0 0 0))',
      x: -3,
      y: -7,
      z: 3)
  end
end
