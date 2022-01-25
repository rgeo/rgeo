# frozen_string_literal: true

require 'test_helper'

class GeometryCollectionTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_geometry_collection_enumerator
    skip unless ENV['FORCE_TESTS'] || Geos::GeometryCollection.method_defined?(:[])

    geom = read('GEOMETRYCOLLECTION(POINT(0 0))')
    assert_kind_of(Enumerable, geom.each)
    assert_kind_of(Enumerable, geom.to_enum)
    assert_equal(geom, geom.each {})
  end

  def test_geometry_collection_array
    skip unless ENV['FORCE_TESTS'] || Geos::GeometryCollection.method_defined?(:[])

    writer.trim = true
    geom = read('GEOMETRYCOLLECTION(
      LINESTRING(0 0, 1 1, 2 2, 3 3),
      POINT(10 20),
      POLYGON((0 0, 0 5, 5 5, 5 0, 0 0)),
      POINT(10 20)
    )')

    assert_equal('LINESTRING (0 0, 1 1, 2 2, 3 3)', write(geom[0]))
    assert_equal('POINT (10 20)', write(geom[-1]))

    assert_equal([
      'LINESTRING (0 0, 1 1, 2 2, 3 3)',
      'POINT (10 20)'
    ], geom[0, 2].collect { |g| write(g) })

    assert_nil(geom[0, -1])
    assert_equal([], geom[-1, 0])
    assert_equal([
      'POINT (10 20)',
      'POLYGON ((0 0, 0 5, 5 5, 5 0, 0 0))'
    ], geom[1..2].collect { |g| write(g) })
  end

  def test_geometry_collection_enumerable
    skip unless ENV['FORCE_TESTS'] || Geos::GeometryCollection.method_defined?(:detect)

    writer.trim = true
    geom = read('GEOMETRYCOLLECTION(
      LINESTRING(0 0, 1 1, 2 2, 3 3, 10 0, 2 2),
      POINT(10 20),
      POLYGON((0 0, 0 5, 5 5, 5 0, 0 0)),
      POINT(10 20)
    )')

    assert_equal(2, geom.select { |point| point == read('POINT(10 20)') }.length)
  end

  def test_default_srid
    geom = read('GEOMETRYCOLLECTION (POINT(0 0))')
    assert_equal(0, geom.srid)
  end

  def test_setting_srid_manually
    geom = read('GEOMETRYCOLLECTION (POINT(0 0))')
    geom.srid = 4326
    assert_equal(4326, geom.srid)
  end

  def test_dimensions
    geom = read('GEOMETRYCOLLECTION (POINT(0 0))')
    assert_equal(0, geom.dimensions)

    geom = read('GEOMETRYCOLLECTION (LINESTRING(1 2, 3 4))')
    assert_equal(1, geom.dimensions)
  end

  def test_num_geometries
    geom = read('GEOMETRYCOLLECTION (POINT(1 2), LINESTRING(1 2, 3 4))')
    assert_equal(2, geom.num_geometries)
  end

  def test_x_max
    geom = read('GEOMETRYCOLLECTION (
      POLYGON ((0 0, 5 0, 8 9, -10 5, 0 0)),
      LINESTRING (0 0, 5 0, 8 9, -10 5, 0 0),
      POINT(3 12)
    )')

    assert_equal(8, geom.x_max)
  end

  def test_x_min
    geom = read('GEOMETRYCOLLECTION (
      POLYGON ((0 0, 5 0, 8 9, -10 5, 0 0)),
      LINESTRING (0 0, 5 0, 8 9, -10 5, 0 0),
      POINT(3 12)
    )')

    assert_equal(-10, geom.x_min)
  end

  def test_y_max
    geom = read('GEOMETRYCOLLECTION (
      POLYGON ((0 0, 5 0, 8 9, -10 5, 0 0)),
      LINESTRING (0 0, 5 0, 8 9, -10 5, 0 0),
      POINT(3 12)
    )')

    assert_equal(12, geom.y_max)
  end

  def test_y_min
    geom = read('GEOMETRYCOLLECTION (
      POLYGON ((0 0, 5 0, 8 9, -10 5, 0 0)),
      LINESTRING (0 0, 5 0, 8 9, -10 5, 0 0),
      POINT(3 12)
    )')

    assert_equal(0, geom.y_min)
  end

  def test_z_max
    geom = read('GEOMETRYCOLLECTION (
      POLYGON ((0 0, 5 0, 8 9, -10 5, 0 0)),
      LINESTRING (0 0, 5 0, 8 9, -10 5, 0 0),
      POINT(3 12)
    )')
    assert_equal(0, geom.z_max)

    geom = read('GEOMETRYCOLLECTION Z (
      POLYGON Z ((0 0 0, 5 0 3, 8 9 4, -10 5 3, 0 0 0)),
      LINESTRING Z (0 0 0, 5 0 3, 8 9 4, -10 5 3, 0 0 0),
      POINT Z (3 12 6)
    )')
    assert_equal(6, geom.z_max)

    # GEOS lets you mix dimensionality, while PostGIS doesn't.
    geom = read('GEOMETRYCOLLECTION (
      POLYGON ((0 0, 5 0, 8 9, -10 5, 0 0)),
      LINESTRING (0 0, 5 0, 8 9, -10 5, 0 0),
      POINT(3 12 10)
    )')
    assert_equal(10, geom.z_max)
  end

  def test_z_min
    geom = read('GEOMETRYCOLLECTION (
      POLYGON ((0 0, 5 0, 8 9, -10 5, 0 0)),
      LINESTRING (0 0, 5 0, 8 9, -10 5, 0 0),
      POINT(3 12)
    )')
    assert_equal(0, geom.z_min)

    geom = read('GEOMETRYCOLLECTION Z (
      POLYGON Z ((0 0 0, 5 0 3, 8 9 4, -10 5 3, 0 0 0)),
      LINESTRING Z (0 0 0, 5 0 3, 8 9 4, -10 5 3, 0 0 0),
      POINT Z (3 12 6)
    )')
    assert_equal(0, geom.z_min)

    # GEOS lets you mix dimensionality, while PostGIS doesn't.
    geom = read('GEOMETRYCOLLECTION (
      POLYGON ((0 0, 5 0, 8 9, -10 5, 0 0)),
      LINESTRING (0 0, 5 0, 8 9, -10 5, 0 0),
      POINT(3 12 -10)
    )')
    assert_equal(-10, geom.z_min)
  end

  def test_snap_to_grid
    wkt = 'GEOMETRYCOLLECTION (LINESTRING (-10.12 0, -10.12 5, -10.12 5, -10.12 6, -10.12 6, -10.12 6, -10.12 7, -10.12 7, -10.12 7, -10.12 8, -10.12 8, -9 8, -9 9, -10.12 0), POLYGON ((-10.12 0, -10.12 5, -10.12 5, -10.12 6, -10.12 6, -10.12 6, -10.12 7, -10.12 7, -10.12 7, -10.12 8, -10.12 8, -9 8, -9 9, -10.12 0)), POINT (10.12 10.12))'

    expected = 'GEOMETRYCOLLECTION (LINESTRING (-10 0, -10 5, -10 5, -10 6, -10 6, -10 6, -10 7, -10 7, -10 7, -10 8, -10 8, -9 8, -9 9, -10 0), POLYGON ((-10 0, -10 5, -10 5, -10 6, -10 6, -10 6, -10 7, -10 7, -10 7, -10 8, -10 8, -9 8, -9 9, -10 0)), POINT (10 10))'

    simple_bang_tester(:snap_to_grid, expected, wkt, 1)
  end

  def test_snap_to_grid_empty
    assert(read('GEOMETRYCOLLECTION EMPTY').snap_to_grid!.empty?, 'Expected an empty GeometryCollection')
  end

  def test_snap_to_grid_with_srid
    wkt = 'GEOMETRYCOLLECTION (
      LINESTRING (-10.12 0, -10.12 5, -10.12 5, -10.12 6, -10.12 6, -10.12 6, -10.12 7, -10.12 7, -10.12 7, -10.12 8, -10.12 8, -9 8, -9 9, -10.12 0),
      POLYGON ((-10.12 0, -10.12 5, -10.12 5, -10.12 6, -10.12 6, -10.12 6, -10.12 7, -10.12 7, -10.12 7, -10.12 8, -10.12 8, -9 8, -9 9, -10.12 0)),
      POINT (10.12 10.12)
    )'

    expected = 'GEOMETRYCOLLECTION (LINESTRING (-10 0, -10 5, -10 5, -10 6, -10 6, -10 6, -10 7, -10 7, -10 7, -10 8, -10 8, -9 8, -9 9, -10 0), POLYGON ((-10 0, -10 5, -10 5, -10 6, -10 6, -10 6, -10 7, -10 7, -10 7, -10 8, -10 8, -9 8, -9 9, -10 0)), POINT (10 10))'

    srid_copy_tester(:snap_to_grid, expected, 0, :zero, wkt, 1)
    srid_copy_tester(:snap_to_grid, expected, 4326, :lenient, wkt, 1)
    srid_copy_tester(:snap_to_grid, expected, 4326, :strict, wkt, 1)
  end

  def test_snap_to_grid_with_illegal_result
    assert_raises(Geos::InvalidGeometryError) do
      read('GEOMETRYCOLLECTION (POINT (0 2), LINESTRING (0 1, 0 11), POLYGON ((0 1, 0 1, 0 6, 0 6, 0 1)))').
        snap_to_grid(1)
    end
  end

  def test_rotate
    writer.rounding_precision = 3

    wkt = 'GEOMETRYCOLLECTION (POINT (1 1), LINESTRING (0 0, 10 10), POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0)))'

    affine_tester(:rotate,
      'GEOMETRYCOLLECTION (POINT (29 11), LINESTRING (30 10, 20 20), POLYGON ((30 10, 30 15, 25 15, 25 10, 30 10)))',
      wkt,
      Math::PI / 2,
      [ 10.0, 20.0 ]
     )

    affine_tester(:rotate,
      'GEOMETRYCOLLECTION (POINT (-2 0), LINESTRING (-3 1, 7 -9), POLYGON ((-3 1, -3 -4, 2 -4, 2 1, -3 1)))',
      wkt,
      -Math::PI / 2,
      [ -1.0, 2.0 ]
    )

    affine_tester(:rotate,
      'GEOMETRYCOLLECTION (POINT (19 1), LINESTRING (20 0, 10 10), POLYGON ((20 0, 20 5, 15 5, 15 0, 20 0)))',
      wkt,
      Math::PI / 2,
      read('POINT(10 10)')
    )

    affine_tester(:rotate,
      'GEOMETRYCOLLECTION (POINT (-0.5 0.5), LINESTRING (0.5 -0.5, -9.5 9.5), POLYGON ((0.5 -0.5, 0.5 4.5, -4.5 4.5, -4.5 -0.5, 0.5 -0.5)))',
      wkt,
      Math::PI / 2,
      read('LINESTRING(0 0, 1 0)')
    )
  end

  def test_rotate_x
    writer.rounding_precision = 3
    writer.output_dimensions = 3

    wkt = 'GEOMETRYCOLLECTION Z (POINT Z (1 1 1), LINESTRING Z (1 1 1, 10 10 10), POLYGON Z ((0 0 0, 5 0 0, 5 5 0, 0 5 0, 0 0 0)))'

    affine_tester(:rotate_x,
      'GEOMETRYCOLLECTION Z (POINT Z (1 -1 -1), LINESTRING Z (1 -1 -1, 10 -10 -10), POLYGON Z ((0 0 0, 5 0 0, 5 -5 0, 0 -5 0, 0 0 0)))',
      wkt,
      Math::PI
    )

    affine_tester(:rotate_x,
      'GEOMETRYCOLLECTION Z (POINT Z (1 -1 1), LINESTRING Z (1 -1 1, 10 -10 10), POLYGON Z ((0 0 0, 5 0 0, 5 0 5, 0 0 5, 0 0 0)))',
      wkt,
      Math::PI / 2
    )

    affine_tester(:rotate_x,
      'GEOMETRYCOLLECTION Z (POINT Z (1 1 -1), LINESTRING Z (1 1 -1, 10 10 -10), POLYGON Z ((0 0 0, 5 0 0, 5 0 -5, 0 0 -5, 0 0 0)))',
      wkt,
      Math::PI + Math::PI / 2
    )

    affine_tester(:rotate_x,
      wkt,
      wkt,
      Math::PI * 2
    )
  end

  def test_rotate_y
    writer.rounding_precision = 6
    writer.output_dimensions = 3

    wkt = 'GEOMETRYCOLLECTION Z (POINT Z (1 1 1), LINESTRING Z (1 1 1, 10 10 10), POLYGON Z ((0 0 0, 5 0 0, 5 5 0, 0 5 0, 0 0 0)))'

    affine_tester(:rotate_y,
      'GEOMETRYCOLLECTION Z (POINT Z (-1 1 -1), LINESTRING Z (-1 1 -1, -10 10 -10), POLYGON Z ((0 0 0, -5 0 0, -5 5 0, 0 5 0, 0 0 0)))',
      wkt,
      Math::PI
    )

    affine_tester(:rotate_y,
      'GEOMETRYCOLLECTION Z (POINT Z (1 1 -1), LINESTRING Z (1 1 -1, 10 10 -10), POLYGON Z ((0 0 0, 0 0 -5, 0 5 -5, 0 5 0, 0 0 0)))',
      wkt,
      Math::PI / 2
    )

    affine_tester(:rotate_y,
      'GEOMETRYCOLLECTION Z (POINT Z (-1 1 1), LINESTRING Z (-1 1 1, -10 10 10), POLYGON Z ((0 0 0, 0 0 5, 0 5 5, 0 5 0, 0 0 0)))',
      wkt,
      Math::PI + Math::PI / 2
    )

    affine_tester(:rotate_y,
      wkt,
      wkt,
      Math::PI * 2
    )
  end

  def test_rotate_z
    writer.rounding_precision = 3

    wkt = 'GEOMETRYCOLLECTION (POINT (1 1), LINESTRING (0 0, 10 10), POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0)))'

    affine_tester(:rotate_z,
      'GEOMETRYCOLLECTION (POINT (-1 -1), LINESTRING (0 0, -10 -10), POLYGON ((0 0, -5 0, -5 -5, 0 -5, 0 0)))',
      wkt,
      Math::PI
    )

    affine_tester(:rotate_z,
      'GEOMETRYCOLLECTION (POINT (-1 1), LINESTRING (0 0, -10 10), POLYGON ((0 0, 0 5, -5 5, -5 0, 0 0)))',
      wkt,
      Math::PI / 2
    )

    affine_tester(:rotate_z,
      'GEOMETRYCOLLECTION (POINT (1 -1), LINESTRING (0 0, 10 -10), POLYGON ((0 0, 0 -5, 5 -5, 5 0, 0 0)))',
      wkt,
      Math::PI + Math::PI / 2
    )

    affine_tester(:rotate_z,
      wkt,
      wkt,
      Math::PI * 2
    )
  end

  def test_scale
    affine_tester(:scale,
      'GEOMETRYCOLLECTION (POINT (5 5), LINESTRING (0 0, 50 50), POLYGON ((0 0, 25 0, 25 25, 0 25, 0 0)))',
      'GEOMETRYCOLLECTION (POINT (1 1), LINESTRING (0 0, 10 10), POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0)))',
      5,
      5
    )

    affine_tester(:scale,
      'GEOMETRYCOLLECTION (POINT (3 2), LINESTRING (0 0, 30 20), POLYGON ((0 0, 15 0, 15 10, 0 10, 0 0)))',
      'GEOMETRYCOLLECTION (POINT (1 1), LINESTRING (0 0, 10 10), POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0)))',
      3,
      2
    )

    writer.output_dimensions = 3
    affine_tester(:scale,
      'GEOMETRYCOLLECTION Z (POINT Z (4 2 -8), LINESTRING Z (4 2 -8, 40 20 -80), POLYGON Z ((0 0 0, 20 0 0, 20 10 0, 0 10 0, 0 0 0)))',
      'GEOMETRYCOLLECTION Z (POINT Z (1 1 1), LINESTRING Z (1 1 1, 10 10 10), POLYGON Z ((0 0 0, 5 0 0, 5 5 0, 0 5 0, 0 0 0)))',
      4,
      2,
      -8
    )
  end

  def test_scale_hash
    affine_tester(:scale,
      'GEOMETRYCOLLECTION (POINT (5 5), LINESTRING (0 0, 50 50), POLYGON ((0 0, 25 0, 25 25, 0 25, 0 0)))',
      'GEOMETRYCOLLECTION (POINT (1 1), LINESTRING (0 0, 10 10), POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0)))',
      :x => 5,
      :y => 5
    )

    affine_tester(:scale,
      'GEOMETRYCOLLECTION (POINT (3 2), LINESTRING (0 0, 30 20), POLYGON ((0 0, 15 0, 15 10, 0 10, 0 0)))',
      'GEOMETRYCOLLECTION (POINT (1 1), LINESTRING (0 0, 10 10), POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0)))',
      :x => 3,
      :y => 2
    )

    writer.output_dimensions = 3
    affine_tester(:scale,
      'GEOMETRYCOLLECTION Z (POINT Z (4 2 -8), LINESTRING Z (4 2 -8, 40 20 -80), POLYGON Z ((0 0 0, 20 0 0, 20 10 0, 0 10 0, 0 0 0)))',
      'GEOMETRYCOLLECTION Z (POINT Z (1 1 1), LINESTRING Z (1 1 1, 10 10 10), POLYGON Z ((0 0 0, 5 0 0, 5 5 0, 0 5 0, 0 0 0)))',
      :x => 4,
      :y => 2,
      :z => -8
    )
  end

  def test_trans_scale
    affine_tester(:trans_scale,
      'GEOMETRYCOLLECTION (POINT (3 3), LINESTRING (2 2, 12 12), POLYGON ((2 2, 7 2, 7 7, 2 7, 2 2)))',
      'GEOMETRYCOLLECTION (POINT (2 2), LINESTRING (1 1, 11 11), POLYGON ((1 1, 6 1, 6 6, 1 6, 1 1)))',
      1, 1, 1, 1)

    wkt = 'GEOMETRYCOLLECTION (POINT (1 1), LINESTRING (0 0, 10 10), POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0)))'

    affine_tester(:trans_scale,
      'GEOMETRYCOLLECTION (POINT (2 2), LINESTRING (1 1, 11 11), POLYGON ((1 1, 6 1, 6 6, 1 6, 1 1)))',
      wkt,
      1, 1, 1, 1)

    affine_tester(:trans_scale,
      'GEOMETRYCOLLECTION (POINT (0 0), LINESTRING (1 1, -9 -9), POLYGON ((1 1, -4 1, -4 -4, 1 -4, 1 1)))',
      wkt,
      -1, -1, -1, -1)

    affine_tester(:trans_scale,
      'GEOMETRYCOLLECTION (POINT (1 2), LINESTRING (0 1, 10 11), POLYGON ((0 1, 5 1, 5 6, 0 6, 0 1)))',
      wkt,
      0, 1, 1, 1)

    affine_tester(:trans_scale,
      'GEOMETRYCOLLECTION (POINT (2 1), LINESTRING (1 0, 11 10), POLYGON ((1 0, 6 0, 6 5, 1 5, 1 0)))',
      wkt,
      1, 0, 1, 1)

    affine_tester(:trans_scale,
      'GEOMETRYCOLLECTION (POINT (3 2), LINESTRING (2 1, 12 11), POLYGON ((2 1, 7 1, 7 6, 2 6, 2 1)))',
      wkt,
      2, 1, 1, 1)

    affine_tester(:trans_scale,
      'GEOMETRYCOLLECTION (POINT (2 3), LINESTRING (1 2, 11 12), POLYGON ((1 2, 6 2, 6 7, 1 7, 1 2)))',
      wkt,
      1, 2, 1, 1)

    affine_tester(:trans_scale,
      'GEOMETRYCOLLECTION (POINT (4 2), LINESTRING (2 1, 22 11), POLYGON ((2 1, 12 1, 12 6, 2 6, 2 1)))',
      wkt,
      1, 1, 2, 1)

    affine_tester(:trans_scale,
      'GEOMETRYCOLLECTION (POINT (2 4), LINESTRING (1 2, 11 22), POLYGON ((1 2, 6 2, 6 12, 1 12, 1 2)))',
      wkt,
      1, 1, 1, 2)

    affine_tester(:trans_scale,
      'GEOMETRYCOLLECTION (POINT (15 28), LINESTRING (10 21, 60 91), POLYGON ((10 21, 35 21, 35 56, 10 56, 10 21)))',
      wkt,
      2, 3, 5, 7)

    writer.output_dimensions = 3
    affine_tester(:trans_scale,
      'GEOMETRYCOLLECTION Z (POINT Z (15 28 1), LINESTRING Z (15 28 1, 60 91 10), POLYGON Z ((10 21 0, 35 21 0, 35 56 0, 10 56 0, 10 21 0)))',
      'GEOMETRYCOLLECTION Z (POINT Z (1 1 1), LINESTRING Z (1 1 1, 10 10 10), POLYGON Z ((0 0 0, 5 0 0, 5 5 0, 0 5 0, 0 0 0)))',
      2, 3, 5, 7)
  end

  def test_trans_scale_hash
    affine_tester(:trans_scale,
      'GEOMETRYCOLLECTION (POINT (2 2), LINESTRING (1 1, 11 11), POLYGON ((1 1, 6 1, 6 6, 1 6, 1 1)))',
      'GEOMETRYCOLLECTION (POINT (1 1), LINESTRING (0 0, 10 10), POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0)))',
      :delta_x => 1, :delta_y => 1, :x_factor => 1, :y_factor => 1)

    writer.output_dimensions = 3
    affine_tester(:trans_scale,
      'GEOMETRYCOLLECTION Z (POINT Z (15 28 1), LINESTRING Z (15 28 1, 60 91 10), POLYGON Z ((10 21 0, 35 21 0, 35 56 0, 10 56 0, 10 21 0)))',
      'GEOMETRYCOLLECTION Z (POINT Z (1 1 1), LINESTRING Z (1 1 1, 10 10 10), POLYGON Z ((0 0 0, 5 0 0, 5 5 0, 0 5 0, 0 0 0)))',
      :delta_x => 2, :delta_y => 3, :x_factor => 5, :y_factor => 7)

    affine_tester(:trans_scale,
      'GEOMETRYCOLLECTION Z (POINT Z (3 1 1), LINESTRING Z (3 1 1, 12 10 10), POLYGON Z ((2 0 0, 7 0 0, 7 5 0, 2 5 0, 2 0 0)))',
      'GEOMETRYCOLLECTION Z (POINT Z (1 1 1), LINESTRING Z (1 1 1, 10 10 10), POLYGON Z ((0 0 0, 5 0 0, 5 5 0, 0 5 0, 0 0 0)))',
      :delta_x => 2, :z_factor => 2)
  end


  def test_translate
    affine_tester(:translate,
      'GEOMETRYCOLLECTION (POINT (6 13), LINESTRING (5 12, 15 22), POLYGON ((5 12, 10 12, 10 17, 5 17, 5 12)))',
      'GEOMETRYCOLLECTION (POINT (1 1), LINESTRING (0 0, 10 10), POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0)))',
      5,
      12
    )

    writer.output_dimensions = 3
    affine_tester(:translate,
      'GEOMETRYCOLLECTION Z (POINT Z (-2 -6 4), LINESTRING Z (-2 -6 4, 7 3 13), POLYGON Z ((-3 -7 3, 2 -7 3, 2 -2 3, -3 -2 3, -3 -7 3)))',
      'GEOMETRYCOLLECTION Z (POINT Z (1 1 1), LINESTRING Z (1 1 1, 10 10 10), POLYGON Z ((0 0 0, 5 0 0, 5 5 0, 0 5 0, 0 0 0)))',
      -3,
      -7,
      3
    )
  end

  def test_translate_hash
    affine_tester(:translate,
      'GEOMETRYCOLLECTION (POINT (6 13), LINESTRING (5 12, 15 22), POLYGON ((5 12, 10 12, 10 17, 5 17, 5 12)))',
      'GEOMETRYCOLLECTION (POINT (1 1), LINESTRING (0 0, 10 10), POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0)))',
      :x => 5,
      :y => 12
    )

    writer.output_dimensions = 3
    affine_tester(:translate,
      'GEOMETRYCOLLECTION Z (POINT Z (-2 -6 4), LINESTRING Z (-2 -6 4, 7 3 13), POLYGON Z ((-3 -7 3, 2 -7 3, 2 -2 3, -3 -2 3, -3 -7 3)))',
      'GEOMETRYCOLLECTION Z (POINT Z (1 1 1), LINESTRING Z (1 1 1, 10 10 10), POLYGON Z ((0 0 0, 5 0 0, 5 5 0, 0 5 0, 0 0 0)))',
      :x => -3,
      :y => -7,
      :z => 3
    )
  end
end
