# frozen_string_literal: true

require 'test_helper'

class CoordinateSequenceTests < Minitest::Test
  include TestHelper

  def setup
    @cs = Geos::CoordinateSequence.new(3, 0)
    super
  end

  def test_set_and_get_x
    @cs.set_x(0, 10.01)
    assert_in_delta(10.01, @cs.get_x(0), TOLERANCE)
  end

  def test_set_and_get_y
    @cs.set_y(0, 20.02)
    assert_in_delta(20.02, @cs.get_y(0), TOLERANCE)
  end

  def test_set_and_get_z
    @cs.set_z(0, 20.02)
    assert_in_delta(20.02, @cs.get_z(0), TOLERANCE)
  end

  def test_set_and_get_ordinate
    @cs.set_ordinate(0, 0, 10.01)
    @cs.set_ordinate(0, 1, 20.02)
    @cs.set_ordinate(0, 2, 30.03)

    assert_in_delta(10.01, @cs.get_ordinate(0, 0), TOLERANCE)
    assert_in_delta(20.02, @cs.get_ordinate(0, 1), TOLERANCE)
    assert_in_delta(30.03, @cs.get_ordinate(0, 2), TOLERANCE)
  end

  def test_length
    assert_equal(3, @cs.length)
  end

  def test_dimensions
    assert_equal(2, @cs.dimensions)
  end

  def test_check_bounds
    assert_raises(Geos::IndexBoundsError) { @cs.set_x(10, 0.1) }
    assert_raises(Geos::IndexBoundsError) { @cs.set_x(-1, 0.1) }

    assert_raises(Geos::IndexBoundsError) { @cs.set_y(10, 0.1) }
    assert_raises(Geos::IndexBoundsError) { @cs.set_y(-1, 0.1) }

    assert_raises(Geos::IndexBoundsError) { @cs.set_z(10, 0.1) }
    assert_raises(Geos::IndexBoundsError) { @cs.set_z(-1, 0.1) }

    assert_raises(Geos::IndexBoundsError) { @cs.set_ordinate(10, 0, 0.1) }
    assert_raises(Geos::IndexBoundsError) { @cs.set_ordinate(-1, 0, 0.1) }

    assert_raises(Geos::IndexBoundsError) { @cs.get_x(10) }
    assert_raises(Geos::IndexBoundsError) { @cs.get_x(-1) }

    assert_raises(Geos::IndexBoundsError) { @cs.get_y(10) }
    assert_raises(Geos::IndexBoundsError) { @cs.get_y(-1) }

    assert_raises(Geos::IndexBoundsError) { @cs.get_z(10) }
    assert_raises(Geos::IndexBoundsError) { @cs.get_z(-1) }

    assert_raises(Geos::IndexBoundsError) { @cs.get_ordinate(10, 0) }
    assert_raises(Geos::IndexBoundsError) { @cs.get_ordinate(-1, 0) }
  end

  def test_clone
    @cs.set_x(0, 1)
    @cs.set_y(0, 2)

    cs_b = @cs.clone

    assert_equal(@cs.get_x(0), cs_b.get_x(0))
    assert_equal(@cs.get_y(0), cs_b.get_y(0))
    assert_equal(@cs.dimensions, cs_b.dimensions)
  end

  def test_dup
    @cs.set_x(0, 1)
    @cs.set_y(0, 2)

    cs_b = @cs.dup

    assert_equal(@cs.get_x(0), cs_b.get_x(0))
    assert_equal(@cs.get_y(0), cs_b.get_y(0))
    assert_equal(@cs.dimensions, cs_b.dimensions)
  end

  def test_with_no_arguments
    cs = Geos::CoordinateSequence.new
    assert_equal(0, cs.size)
    assert_equal(3, cs.dimensions)
  end

  def test_with_all_sorts_of_arguments
    assert_raises(ArgumentError) do
      Geos::CoordinateSequence.new(0, 1, 2, 3, 4, 5)
    end
  end

  def test_read_from_array
    cs = Geos::CoordinateSequence.new([
      [ 0, 0 ],
      [ 1, 1 ],
      [ 2, 2 ],
      [ 3, 3 ],
      [ 4, 4 ]
    ])

    assert_equal(2, cs.dimensions)
    assert_equal(5, cs.length)

    assert_raises(Geos::CoordinateSequence::ParseError) do
      cs = Geos::CoordinateSequence.new([
        [ 1, 2 ],
        [ 1, 2, 3 ]
      ])
    end

    assert_raises(Geos::CoordinateSequence::ParseError) do
      cs = Geos::CoordinateSequence.new([
        [ 1, 2, 3, 4 ]
      ])
    end
  end

  def test_to_point
    cs = Geos::CoordinateSequence.new([ 5, 7 ])
    assert_equal('POINT (5 7)', write(cs.to_point, trim: true))
  end

  def test_to_to_linear_ring
    cs = Geos::CoordinateSequence.new([
      [ 0, 0 ],
      [ 0, 5 ],
      [ 5, 5 ],
      [ 5, 0 ],
      [ 0, 0 ]
    ])

    assert_equal('LINEARRING (0 0, 0 5, 5 5, 5 0, 0 0)', write(cs.to_linear_ring, trim: true))
  end

  def test_empty
    cs = Geos::CoordinateSequence.new
    assert_geom_empty(cs)

    cs = Geos::CoordinateSequence.new([ 4, 1 ])
    refute_geom_empty(cs)
  end

  def test_to_empty_linear_ring
    cs = Geos::CoordinateSequence.new

    assert_equal('LINEARRING EMPTY', write(cs.to_linear_ring, trim: true))
  end

  def test_to_line_string
    cs = Geos::CoordinateSequence.new([
      [ 0, 0 ],
      [ 0, 5 ],
      [ 5, 5 ],
      [ 5, 0 ]
    ])

    assert_equal('LINESTRING (0 0, 0 5, 5 5, 5 0)', write(cs.to_line_string, trim: true))
  end

  def test_to_empty_line_string
    cs = Geos::CoordinateSequence.new

    assert_equal('LINESTRING EMPTY', write(cs.to_line_string, trim: true))
  end

  def test_to_polygon
    cs = Geos::CoordinateSequence.new([
      [ 0, 0 ],
      [ 0, 5 ],
      [ 5, 5 ],
      [ 5, 0 ],
      [ 0, 0 ]
    ])

    assert_equal('POLYGON ((0 0, 0 5, 5 5, 5 0, 0 0))', write(cs.to_polygon, trim: true))
  end

  def test_to_empty_polygon
    cs = Geos::CoordinateSequence.new

    assert_equal('POLYGON EMPTY', write(cs.to_polygon, trim: true))
  end

  def test_to_s_2d
    cs = Geos::CoordinateSequence.new([[1, 2], [10, 11]])
    assert_equal('1.0 2.0, 10.0 11.0', cs.to_s)
  end

  def test_to_s_3d
    cs = Geos::CoordinateSequence.new([[1, 2, 3], [10, 11, 12]])
    assert_equal('1.0 2.0 3.0, 10.0 11.0 12.0', cs.to_s)
  end

  def test_get_by_proxy
    cs = Geos::CoordinateSequence.new([[1, 2], [10, 11]])

    assert_equal(1, cs.x[0])
    assert_equal(10, cs.x[1])

    assert_equal(2, cs.y[0])
    assert_equal(11, cs.y[1])

    assert_equal('NaN', cs.z[0].to_s)
    assert_equal('NaN', cs.z[1].to_s)

    assert_raises(Geos::IndexBoundsError) do
      cs.x[100]
    end

    assert_raises(Geos::IndexBoundsError) do
      cs.y[100]
    end

    assert_raises(Geos::IndexBoundsError) do
      cs.z[100]
    end
  end

  def test_set_by_proxy
    cs = Geos::CoordinateSequence.new(2)
    cs.x[0] = 1
    cs.x[1] = 10

    cs.y[0] = 2
    cs.y[1] = 11

    assert_equal(1, cs.get_x(0))
    assert_equal(10, cs.get_x(1))

    assert_equal(2, cs.get_y(0))
    assert_equal(11, cs.get_y(1))

    assert_raises(Geos::IndexBoundsError) do
      cs.x[100] = 10
    end

    assert_raises(Geos::IndexBoundsError) do
      cs.y[100] = 10
    end

    assert_raises(Geos::IndexBoundsError) do
      cs.z[100] = 10
    end
  end

  def test_proxy_enumerator
    cs = Geos::CoordinateSequence.new(10)

    assert_kind_of(Enumerable, cs.x.each)
    assert_kind_of(Enumerable, cs.x.to_enum)
    assert_equal(cs.x, cs.x.each {})
  end

  def test_options_hash
    cs = Geos::CoordinateSequence.new(size: 10, dimensions: 2)

    assert_equal(10, cs.size)
    assert_equal(2, cs.dimensions)
  end

  def test_enumerator
    cs = Geos::CoordinateSequence.new(10)

    assert_kind_of(Enumerable, cs.each)
    assert_kind_of(Enumerable, cs.to_enum)
    assert_equal(cs, cs.each {})
  end

  def test_array_like_access
    cs = Geos::CoordinateSequence.new([
      [ 0, 1 ],
      [ 2, 3 ]
    ])

    assert_equal(0, cs[0][0])
    assert_equal(1, cs[0][1])
    assert_equal(2, cs[1][0])
    assert_equal(3, cs[1][1])

    cs = Geos::CoordinateSequence.new([
      [ 4, 5, 6 ]
    ])

    assert_equal(4, cs[0][0])
    assert_equal(5, cs[0][1])
    assert_equal(6, cs[0][2])
  end

  def test_slice
    cs = Geos::CoordinateSequence.new([
      [ 0, 1 ],
      [ 2, 3 ],
      [ 4, 5 ]
    ])

    assert_equal([[0, 1], [2, 3]], cs.slice(0..1))
    assert_equal([4, 5], cs.slice(-1))
    assert_equal([[0, 1], [2, 3]], cs.slice(0, 2))
  end

  def test_proxy_clone
    cs = Geos::CoordinateSequence.new([ 10, 20 ])
    cs2 = cs.clone

    cs.x[0] = 100

    assert_equal(100, cs.x[0])
    assert_equal(10, cs2.x[0])

    refute_equal(cs.x, cs2.x)
    refute_equal(cs.y, cs2.y)
  end

  def test_has_z
    assert_geom_has_z(Geos::CoordinateSequence.new([ 0, 1, 2 ]))
    refute_geom_has_z(Geos::CoordinateSequence.new([ 0, 1 ]))
    refute_geom_has_z(Geos::CoordinateSequence.new(1, 2))
    assert_geom_has_z(Geos::CoordinateSequence.new(1, 3))
    assert_geom_has_z(read('POINT (0 0 0)').coord_seq)
    refute_geom_has_z(read('POINT (0 0)').coord_seq)
  end

  def test_x_max
    cs = Geos::CoordinateSequence.new([ -10, -15 ], [ 0, 5 ], [ 10, 20 ])
    assert_equal(10, cs.x_max)
  end

  def test_x_min
    cs = Geos::CoordinateSequence.new([ -10, -15 ], [ 0, 5 ], [ 10, 20 ])
    assert_equal(-10, cs.x_min)
  end

  def test_y_max
    cs = Geos::CoordinateSequence.new([ -10, -15 ], [ 0, 5 ], [ 10, 20 ])
    assert_equal(20, cs.y_max)
  end

  def test_y_min
    cs = Geos::CoordinateSequence.new([ -10, -15 ], [ 0, 5 ], [ 10, 20 ])
    assert_equal(-15, cs.y_min)
  end

  def test_z_max
    cs = Geos::CoordinateSequence.new([ -10, -15 ], [ 0, 5 ], [ 10, 20 ])
    assert(cs.z_max.nan?, " Expected NaN")

    cs = Geos::CoordinateSequence.new([ -10, -15, -20 ], [ 0, 5, 10 ], [ 10, 20, 30 ])
    assert_equal(30, cs.z_max)
  end

  def test_z_min
    cs = Geos::CoordinateSequence.new([ -10, -15 ], [ 0, 5 ], [ 10, 20 ])
    assert(cs.z_min.nan?, " Expected NaN")

    cs = Geos::CoordinateSequence.new([ -10, -15, -20 ], [ 0, 5, 10 ], [ 10, 20, 30 ])
    assert_equal(-20, cs.z_min)
  end

  def test_snap_to_grid_with_size
    expected = [
      [[-10.0, -15.0], [0.0, 5.0], [10.0, 20.0]],
      [[-10.1, -15.1], [0.1, 5.1], [10.1, 20.1]],
      [[-10.12, -15.12], [0.12, 5.12], [10.12, 20.12]],
      [[-10.123, -15.123], [0.123, 5.123], [10.123, 20.123]],
      [[-10.1235, -15.1235], [0.1235, 5.1235], [10.1235, 20.1235]],
      [[-10.12346, -15.12346], [0.12346, 5.12346], [10.12346, 20.12346]],
      [[-10.123457, -15.123457], [0.123457, 5.123457], [10.123457, 20.123457]],
      [[-10.1234568, -15.1234568], [0.1234568, 5.1234568], [10.1234568, 20.1234568]],
      [[-10.12345679, -15.12345679], [0.12345679, 5.12345679], [10.12345679, 20.12345679]]
    ]

    coordinates = [
      [ -10.123456789, -15.123456789 ],
      [ 0.123456789, 5.123456789 ],
      [ 10.123456789, 20.123456789 ]
    ]

    9.times do |i|
      cs = Geos::CoordinateSequence.new(*coordinates)
      cs.snap_to_grid!(10 ** -i)

      # XXX - Ruby 1.8.7 sometimes sees the the float values as differing
      # slightly, but not enough that it would matter for these tests.
      # Test equality on the inspect Strings instead of the float values.
      assert_equal(expected[i].inspect, cs.to_a.inspect)

      cs = Geos::CoordinateSequence.new(*coordinates)
      snapped = cs.snap_to_grid(10 ** -i)
      assert_equal(coordinates, cs.to_a)
      assert_equal(expected[i].inspect, snapped.to_a.inspect)
    end
  end

  def test_snap_to_grid_with_hash
    cs = Geos::CoordinateSequence.new(
      [ 10, 10 ],
      [ 20, 20 ],
      [ 30, 30 ]
    )
    cs.snap_to_grid!(:size_x => 1, :size_y => 1, :offset_x => 12.5, :offset_y => 12.5)

    assert_equal([
      [ 9.5, 9.5 ],
      [ 20.5, 20.5 ],
      [ 30.5, 30.5 ]
    ], cs.to_a)
  end

  def test_snap_to_grid_with_geometry_origin
    cs = Geos::CoordinateSequence.new(
      [ 10, 10 ],
      [ 20, 20 ],
      [ 30, 30 ]
    )
    cs.snap_to_grid!(:size => 1, :offset => read('LINESTRING (0 0, 25 25)'))

    assert_equal([
      [ 9.5, 9.5 ],
      [ 20.5, 20.5 ],
      [ 30.5, 30.5 ]
    ], cs.to_a)
  end

  def test_snap_to_grid_with_z
    cs = Geos::CoordinateSequence.new(
      [ 10, 10, 10 ],
      [ 20, 20, 20 ],
      [ 30, 30, 30 ]
    )
    cs.snap_to_grid!(
      :size_x => 1,
      :size_y => 1,
      :size_z => 1,

      :offset_x => 12.5,
      :offset_y => 12.5,
      :offset_z => 12.5
    )

    assert_equal([
      [ 9.5, 9.5, 9.5 ],
      [ 20.5, 20.5, 20.5 ],
      [ 30.5, 30.5, 30.5 ]
    ], cs.to_a)
  end

  def test_snap_to_grid_remove_duplicate_points
    coords = [
      [-10.0, 0.0],
      [-10.0, 5.0], [-10.0, 5.0],
      [-10.0, 6.0], [-10.0, 6.0], [-10.0, 6.0],
      [-10.0, 7.0], [-10.0, 7.0], [-10.0, 7.0],
      [-10.0, 8.0], [-10.0, 8.0],
      [-9.0, 8.0], [-9.0, 9.0],
      [-10.0, 0.0]
    ]

    expected = [
      [-10.0, 0.0],
      [-10.0, 5.0],
      [-10.0, 6.0],
      [-10.0, 7.0],
      [-10.0, 8.0],
      [-9.0, 8.0],
      [-9.0, 9.0],
      [-10.0, 0.0]
    ]

    cs = Geos::CoordinateSequence.new(coords)
    cs.snap_to_grid!

    assert_equal(expected, cs.to_a)

    cs = Geos::CoordinateSequence.new(coords)
    cs2 = cs.snap_to_grid

    assert_equal(coords, cs.to_a)
    assert_equal(expected, cs2.to_a)
  end

  undef :affine_tester
  def affine_tester(method, expected, coords, *args)
    cs = Geos::CoordinateSequence.new(coords)
    cs.send("#{method}!", *args)

    expected.length.times do |i|
      assert_in_delta(expected[i], cs.get_ordinate(0, i), TOLERANCE)
    end

    cs = Geos::CoordinateSequence.new(coords)
    cs2 = cs.send(method, *args)

    expected.length.times do |i|
      assert_in_delta(coords[i], cs.get_ordinate(0, i), TOLERANCE)
      assert_in_delta(expected[i], cs2.get_ordinate(0, i), TOLERANCE)
    end
  end

  def test_rotate
    affine_tester(:rotate, [ 29.0, 11.0 ], [ 1, 1 ], Math::PI / 2, [ 10.0, 20.0 ])
    affine_tester(:rotate, [ -2.0, 0.0 ], [ 1, 1 ], -Math::PI / 2, [ -1.0, 2.0 ])
    affine_tester(:rotate, [ 19.0, 1.0 ], [ 1, 1 ], Math::PI / 2, read('POINT(10 10)'))
    affine_tester(:rotate, [ -0.5, 0.5 ], [ 1, 1 ], Math::PI / 2, read('LINESTRING(0 0, 1 0)'))
  end

  def test_rotate_x
    affine_tester(:rotate_x, [ 1, -1, -1 ], [ 1, 1, 1 ], Math::PI)
    affine_tester(:rotate_x, [ 1, -1, 1 ], [ 1, 1, 1 ], Math::PI / 2)
    affine_tester(:rotate_x, [ 1, 1, -1 ], [ 1, 1, 1 ], Math::PI + Math::PI / 2)
    affine_tester(:rotate_x, [ 1, 1, 1 ], [ 1, 1, 1 ], Math::PI * 2)
  end

  def test_rotate_y
    affine_tester(:rotate_y, [ -1, 1, -1 ], [ 1, 1, 1 ], Math::PI)
    affine_tester(:rotate_y, [ 1, 1, -1 ], [ 1, 1, 1 ], Math::PI / 2)
    affine_tester(:rotate_y, [ -1, 1, 1 ], [ 1, 1, 1 ], Math::PI + Math::PI / 2)
    affine_tester(:rotate_y, [ 1, 1, 1 ], [ 1, 1, 1 ], Math::PI * 2)
  end

  def test_rotate_z
    affine_tester(:rotate_z, [ -1, -1 ], [ 1, 1 ], Math::PI)
    affine_tester(:rotate_z, [ -1, 1 ], [ 1, 1 ], Math::PI / 2)
    affine_tester(:rotate_z, [ 1, -1 ], [ 1, 1 ], Math::PI + Math::PI / 2)
    affine_tester(:rotate_z, [ 1, 1 ], [ 1, 1 ], Math::PI * 2)
  end

  def test_scale
    affine_tester(:scale, [ 5, 5 ], [ 1, 1 ], 5, 5)
    affine_tester(:scale, [ 3, 2 ], [ 1, 1 ], 3, 2)
    affine_tester(:scale, [ 40, 40, 40 ], [ 10, 20, -5 ], 4, 2, -8)
  end

  def test_scale_hash
    affine_tester(:scale, [ 5, 5 ], [ 1, 1 ], :x => 5, :y => 5)
    affine_tester(:scale, [ 3, 2 ], [ 1, 1 ], :x => 3, :y => 2)
    affine_tester(:scale, [ 40, 40, 40 ], [ 10, 20, -5 ], :x => 4, :y => 2, :z => -8)
  end

  def test_trans_scale
    affine_tester(:trans_scale, [ 2, 2 ], [ 1, 1 ], 1, 1, 1, 1)
    affine_tester(:trans_scale, [ 3, 3 ], [ 2, 2 ], 1, 1, 1, 1)
    affine_tester(:trans_scale, [ 0, 0 ], [ 1, 1 ], -1, -1, -1, -1)
    affine_tester(:trans_scale, [ 1, 2 ], [ 1, 1 ], 0, 1, 1, 1)
    affine_tester(:trans_scale, [ 2, 1 ], [ 1, 1 ], 1, 0, 1, 1)
    affine_tester(:trans_scale, [ 0, 2 ], [ 1, 1 ], 1, 1, 0, 1)
    affine_tester(:trans_scale, [ 2, 0 ], [ 1, 1 ], 1, 1, 1, 0)
    affine_tester(:trans_scale, [ 3, 2 ], [ 1, 1 ], 2, 1, 1, 1)
    affine_tester(:trans_scale, [ 2, 3 ], [ 1, 1 ], 1, 2, 1, 1)
    affine_tester(:trans_scale, [ 4, 2 ], [ 1, 1 ], 1, 1, 2, 1)
    affine_tester(:trans_scale, [ 2, 4 ], [ 1, 1 ], 1, 1, 1, 2)
    affine_tester(:trans_scale, [ 15, 28 ], [ 1, 1 ], 2, 3, 5, 7)
    affine_tester(:trans_scale, [ 15, 28, 1 ], [ 1, 1, 1 ], 2, 3, 5, 7)
  end

  def test_trans_scale_hash
    affine_tester(:trans_scale, [ 2, 2 ], [ 1, 1 ], :delta_x => 1, :delta_y => 1, :x_factor => 1, :y_factor => 1)
    affine_tester(:trans_scale, [ 15, 28, 1 ], [ 1, 1, 1 ], :delta_x => 2, :delta_y => 3, :x_factor => 5, :y_factor => 7)
    affine_tester(:trans_scale, [ 3, 1, 1 ], [ 1, 1, 1 ], :delta_x => 2, :z_factor => 2)
  end

  def test_translate
    affine_tester(:translate, [ 5, 12 ], [ 0, 0 ], 5, 12)
    affine_tester(:translate, [ -3, -7, 3 ], [ 0, 0, 0 ], -3, -7, 3)
  end

  def test_translate_hash
    affine_tester(:translate, [ 5, 12 ], [ 0, 0 ], :x => 5, :y => 12)
    affine_tester(:translate, [ -3, -7, 3 ], [ 0, 0, 0 ], :x => -3, :y => -7, :z => 3)
  end
end
