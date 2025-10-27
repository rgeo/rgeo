# frozen_string_literal: true

require 'test_helper'

class LineStringTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_default_srid
    geom = read('LINESTRING (0 0, 10 10)')

    assert_equal(0, geom.srid)
  end

  def test_setting_srid_manually
    geom = read('LINESTRING (0 0, 10 10)')
    geom.srid = 4326

    assert_equal(4326, geom.srid)
  end

  def test_dimensions
    geom = read('LINESTRING (0 0, 10 10)')

    assert_equal(1, geom.dimensions)

    geom = read('LINESTRING (0 0 0, 10 10 10)')

    assert_equal(1, geom.dimensions)
  end

  def test_num_geometries
    geom = read('LINESTRING (0 0, 10 10)')

    assert_equal(1, geom.num_geometries)
  end

  def test_line_string_array
    skip unless ENV['FORCE_TESTS'] || Geos::LineString.method_defined?(:[])

    geom = read('LINESTRING(0 0, 1 1, 2 2, 3 3, 4 4)')

    assert_equal('POINT (0 0)', write(geom[0]))
    assert_equal('POINT (4 4)', write(geom[-1]))

    assert_equal([
      'POINT (0 0)',
      'POINT (1 1)'
    ], geom[0, 2].collect { |g| write(g) })

    assert_nil(geom[0, -1])
    assert_empty(geom[-1, 0])
    assert_equal([
      'POINT (1 1)',
      'POINT (2 2)'
    ], geom[1..2].collect { |g| write(g) })
  end

  def test_line_string_enumerable
    skip unless ENV['FORCE_TESTS'] || Geos::LineString.method_defined?(:select)

    geom = read('LINESTRING(0 0, 1 1, 2 2, 3 3, 10 0, 2 2)')

    assert_equal(2, geom.select { |point| point == read('POINT(2 2)') }.length)
  end

  def test_offset_curve
    skip unless ENV['FORCE_TESTS'] || Geos::LineString.method_defined?(:offset_curve)

    # straight left
    simple_tester(
      :offset_curve,
      'LINESTRING (0 2, 10 2)',
      'LINESTRING (0 0, 10 0)',
      2,
      quad_segs: 0,
      join: :round,
      mitre_limit: 2
    )

    # straight right
    simple_tester(
      :offset_curve,
      if Geos::GEOS_NICE_VERSION >= '031100'
        'LINESTRING (0 -2, 10 -2)'
      else
        'LINESTRING (10 -2, 0 -2)'
      end,
      'LINESTRING (0 0, 10 0)',
      -2,
      quad_segs: 0,
      join: :round,
      mitre_limit: 2
    )

    # outside curve
    simple_tester(
      :offset_curve,
      if Geos::GEOS_NICE_VERSION >= '031201'
        'LINESTRING (0 -2, 10 -2, 10.390180644032256 -1.9615705608064609, 10.76536686473018 -1.8477590650225735, ' \
          '11.111140466039204 -1.6629392246050905, 11.414213562373096 -1.414213562373095, 11.66293922460509 -1.1111404660392044, ' \
          '11.847759065022574 -0.7653668647301796, 11.96157056080646 -0.3901806440322565, 12 0, 12 10)'
      elsif Geos::GEOS_NICE_VERSION >= '031200'
        'LINESTRING (0 -2, 10 -2, 10.390180644032256 -1.9615705608064609, 10.76536686473018 -1.8477590650225735, ' \
          '11.111140466039204 -1.6629392246050902, 11.414213562373096 -1.414213562373095, 11.66293922460509 -1.1111404660392044, ' \
          '11.847759065022574 -0.7653668647301796, 11.96157056080646 -0.3901806440322565, 12 0, 12 10)'
      elsif Geos::GEOS_NICE_VERSION >= '031100'
        'LINESTRING (0 -2, 10 -2, 12 0, 12 10)'
      else
        'LINESTRING (12 10, 12 0, 10 -2, 0 -2)'
      end,
      'LINESTRING (0 0, 10 0, 10 10)',
      -2,
      quad_segs: 1,
      join: :round,
      mitre_limit: 2
    )

    # inside curve
    simple_tester(
      :offset_curve,
      'LINESTRING (0 2, 8 2, 8 10)',
      'LINESTRING (0 0, 10 0, 10 10)',
      2,
      quad_segs: 1,
      join: :round,
      mitre_limit: 2
    )
  end

  def test_closed
    skip unless ENV['FORCE_TESTS'] || Geos::LineString.method_defined?(:closed?)

    assert_geom_closed(read('LINESTRING(0 0, 1 1, 2 2, 0 0)'))
    refute_geom_closed(read('LINESTRING(0 0, 1 1, 2 2)'))
    assert_geom_closed(read('LINEARRING(0 0, 1 1, 2 2, 0 0)'))
  end

  def test_num_points
    skip unless ENV['FORCE_TESTS'] || Geos::LineString.method_defined?(:num_points)

    assert_equal(4, read('LINESTRING (0 0, 1 0, 1 1, 0 1)').num_points)

    assert_raises(NoMethodError) do
      read('POINT (0 0)').num_points
    end
  end

  def test_point_n
    skip unless ENV['FORCE_TESTS'] || Geos::LineString.method_defined?(:point_n)

    geom = read('LINESTRING (10 10, 10 14, 14 14, 14 10)')
    simple_tester(:point_n, 'POINT (10 10)', geom, 0)
    simple_tester(:point_n, 'POINT (10 14)', geom, 1)
    simple_tester(:point_n, 'POINT (14 14)', geom, 2)
    simple_tester(:point_n, 'POINT (14 10)', geom, 3)

    assert_raises(Geos::IndexBoundsError) do
      geom.point_n(4)
    end

    geom = read('LINEARRING (11 11, 11 12, 12 11, 11 11)')
    simple_tester(:point_n, 'POINT (11 11)', geom, 0)
    simple_tester(:point_n, 'POINT (11 12)', geom, 1)
    simple_tester(:point_n, 'POINT (12 11)', geom, 2)
    simple_tester(:point_n, 'POINT (11 11)', geom, 3)

    assert_raises(NoMethodError) do
      read('POINT (0 0)').point_n(0)
    end
  end

  def test_to_linear_ring
    simple_tester(:to_linear_ring, 'LINEARRING (0 0, 0 5, 5 5, 5 0, 0 0)', 'LINESTRING (0 0, 0 5, 5 5, 5 0, 0 0)')
    simple_tester(:to_linear_ring, 'LINEARRING (0 0, 0 5, 5 5, 5 0, 0 0)', 'LINESTRING (0 0, 0 5, 5 5, 5 0)')

    writer.output_dimensions = 3
    simple_tester(:to_linear_ring, 'LINEARRING Z (0 0 0, 0 5 0, 5 5 0, 5 0 0, 0 0 0)', 'LINESTRING Z (0 0 0, 0 5 0, 5 5 0, 5 0 0, 0 0 0)')
    simple_tester(:to_linear_ring, 'LINEARRING Z (0 0 0, 0 5 0, 5 5 0, 5 0 0, 0 0 0)', 'LINESTRING Z (0 0 0, 0 5 0, 5 5 0, 5 0 0)')
  end

  def test_to_linear_ring_with_srid
    wkt = 'LINESTRING (0 0, 5 0, 5 5, 0 5, 0 0)'
    expected = 'LINEARRING (0 0, 5 0, 5 5, 0 5, 0 0)'

    srid_copy_tester(:to_linear_ring, expected, 0, :zero, wkt)
    srid_copy_tester(:to_linear_ring, expected, 4326, :lenient, wkt)
    srid_copy_tester(:to_linear_ring, expected, 4326, :strict, wkt)
  end

  def test_to_polygon
    simple_tester(:to_polygon, 'POLYGON ((0 0, 0 5, 5 5, 5 0, 0 0))', 'LINESTRING (0 0, 0 5, 5 5, 5 0, 0 0)')
    simple_tester(:to_polygon, 'POLYGON ((0 0, 0 5, 5 5, 5 0, 0 0))', 'LINESTRING (0 0, 0 5, 5 5, 5 0)')

    writer.output_dimensions = 3
    simple_tester(:to_polygon, 'POLYGON Z ((0 0 0, 0 5 0, 5 5 0, 5 0 0, 0 0 0))', 'LINESTRING Z (0 0 0, 0 5 0, 5 5 0, 5 0 0, 0 0 0)')
    simple_tester(:to_polygon, 'POLYGON Z ((0 0 0, 0 5 0, 5 5 0, 5 0 0, 0 0 0))', 'LINESTRING Z (0 0 0, 0 5 0, 5 5 0, 5 0 0)')
  end

  def test_to_polygon_with_srid
    wkt = 'LINESTRING (0 0, 5 0, 5 5, 0 5, 0 0)'
    expected = 'POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))'

    srid_copy_tester(:to_polygon, expected, 0, :zero, wkt)
    srid_copy_tester(:to_polygon, expected, 4326, :lenient, wkt)
    srid_copy_tester(:to_polygon, expected, 4326, :strict, wkt)
  end

  def test_x_max
    geom = read('LINESTRING (0 0, 5 0, 8 9, -10 5, 0 0)')

    assert_equal(8, geom.x_max)
  end

  def test_x_min
    geom = read('LINESTRING (0 0, 5 0, 8 9, -10 5, 0 0)')

    assert_equal(-10, geom.x_min)
  end

  def test_y_max
    geom = read('LINESTRING (0 0, 5 0, 8 9, -10 5, 0 0)')

    assert_equal(9, geom.y_max)
  end

  def test_y_min
    geom = read('LINESTRING (0 0, 5 0, 8 9, -10 5, 0 0)')

    assert_equal(0, geom.y_min)
  end

  def test_z_max
    geom = read('LINESTRING (0 0, 5 0, 8 9, -10 5, 0 0)')

    assert_equal(0, geom.z_max)

    geom = read('LINESTRING Z (0 0 0, 5 0 3, 8 9 4, -10 5 3, 0 0 0)')

    assert_equal(4, geom.z_max)
  end

  def test_z_min
    geom = read('LINESTRING (0 0, 5 0, 8 9, -10 5, 0 0)')

    assert_equal(0, geom.z_min)

    geom = read('LINESTRING Z (0 0 0, 5 0 3, 8 9 4, -10 5 3, 0 0 0)')

    assert_equal(0, geom.z_min)
  end

  def test_snap_to_grid
    wkt = 'LINESTRING (-10.12 0, -10.12 5, -10.12 5, -10.12 6, -10.12 6, -10.12 6, -10.12 7, -10.12 7, -10.12 7, -10.12 8, -10.12 8, -9 8, -9 9, -10.12 0)'
    expected = 'LINESTRING (-10 0, -10 5, -10 6, -10 7, -10 8, -9 8, -9 9, -10 0)'

    simple_bang_tester(:snap_to_grid, expected, wkt, 1)
  end

  def test_snap_to_grid_empty
    assert_empty(read('LINESTRING EMPTY').snap_to_grid!, 'Expected an empty LineString')
  end

  def test_snap_to_grid_with_srid
    wkt = 'LINESTRING (0.1 0.1, 0.1 5.1, 5.1 5.1, 5.1 0.1, 0.1 0.1)'
    expected = 'LINESTRING (0 0, 0 5, 5 5, 5 0, 0 0)'

    srid_copy_tester(:snap_to_grid, expected, 0, :zero, wkt, 1)
    srid_copy_tester(:snap_to_grid, expected, 4326, :lenient, wkt, 1)
    srid_copy_tester(:snap_to_grid, expected, 4326, :strict, wkt, 1)
  end

  def test_rotate
    writer.rounding_precision = 2

    wkt = 'LINESTRING (0 0, 10 10)'

    affine_tester(:rotate, 'LINESTRING (30 10, 20 20)', wkt, Math::PI / 2, [10.0, 20.0])
    affine_tester(:rotate, 'LINESTRING (-3 1, 7 -9)', wkt, -Math::PI / 2, [-1.0, 2.0])
    affine_tester(:rotate, 'LINESTRING (2 2, -8 -8)', wkt, Math::PI, read('POINT(1 1)'))
    affine_tester(:rotate, 'LINESTRING (0.5 -0.5, -9.5 9.5)', wkt, Math::PI / 2, read('LINESTRING(0 0, 1 0)'))
  end

  def test_rotate_x
    writer.output_dimensions = 3
    writer.rounding_precision = 2

    wkt = 'LINESTRING Z (1 1 1, 10 10 10)'

    affine_tester(:rotate_x, 'LINESTRING Z (1 -1 -1, 10 -10 -10)', wkt, Math::PI)
    affine_tester(:rotate_x, 'LINESTRING Z (1 -1 1, 10 -10 10)', wkt, Math::PI / 2)
    affine_tester(:rotate_x, 'LINESTRING Z (1 1 -1, 10 10 -10)', wkt, Math::PI + (Math::PI / 2))
    affine_tester(:rotate_x, wkt, wkt, Math::PI * 2)
  end

  def test_rotate_y
    writer.output_dimensions = 3
    writer.rounding_precision = 2

    wkt = 'LINESTRING Z (1 1 1, 10 10 10)'

    affine_tester(:rotate_y, 'LINESTRING Z (-1 1 -1, -10 10 -10)', wkt, Math::PI)
    affine_tester(:rotate_y, 'LINESTRING Z (1 1 -1, 10 10 -10)', wkt, Math::PI / 2)
    affine_tester(:rotate_y, 'LINESTRING Z (-1 1 1, -10 10 10)', wkt, Math::PI + (Math::PI / 2))
    affine_tester(:rotate_y, wkt, wkt, Math::PI * 2)
  end

  def test_rotate_z
    writer.rounding_precision = 2

    wkt = 'LINESTRING (1 1, 10 10)'

    affine_tester(:rotate_z, 'LINESTRING (-1 -1, -10 -10)', wkt, Math::PI)
    affine_tester(:rotate_z, 'LINESTRING (-1 1, -10 10)', wkt, Math::PI / 2)
    affine_tester(:rotate_z, 'LINESTRING (1 -1, 10 -10)', wkt, Math::PI + (Math::PI / 2))
    affine_tester(:rotate_z, wkt, wkt, Math::PI * 2)
  end

  def test_scale
    affine_tester(:scale, 'LINESTRING (5 5, 50 50)', 'LINESTRING (1 1, 10 10)', 5, 5)
    affine_tester(:scale, 'LINESTRING (3 2, 30 20)', 'LINESTRING (1 1, 10 10)', 3, 2)

    writer.output_dimensions = 3
    affine_tester(:scale, 'LINESTRING Z (40 40 40, 80 80 80)', 'LINESTRING Z (10 20 -5, 20 40 -10)', 4, 2, -8)
  end

  def test_scale_hash
    affine_tester(:scale, 'LINESTRING (5 5, 50 50)', 'LINESTRING (1 1, 10 10)', x: 5, y: 5)
    affine_tester(:scale, 'LINESTRING (3 2, 30 20)', 'LINESTRING (1 1, 10 10)', x: 3, y: 2)

    writer.output_dimensions = 3
    affine_tester(:scale, 'LINESTRING Z (40 40 40, 80 80 80)', 'LINESTRING Z (10 20 -5, 20 40 -10)', x: 4, y: 2, z: -8)
  end

  def test_trans_scale
    affine_tester(:trans_scale, 'LINESTRING (2 2, 11 11)', 'LINESTRING (1 1, 10 10)', 1, 1, 1, 1)
    affine_tester(:trans_scale, 'LINESTRING (3 3, 12 12)', 'LINESTRING (2 2, 11 11)', 1, 1, 1, 1)
    affine_tester(:trans_scale, 'LINESTRING (0 0, -9 -9)', 'LINESTRING (1 1, 10 10)', -1, -1, -1, -1)
    affine_tester(:trans_scale, 'LINESTRING (1 2, 10 11)', 'LINESTRING (1 1, 10 10)', 0, 1, 1, 1)
    affine_tester(:trans_scale, 'LINESTRING (2 1, 11 10)', 'LINESTRING (1 1, 10 10)', 1, 0, 1, 1)
    affine_tester(:trans_scale, 'LINESTRING (0 2, 0 11)', 'LINESTRING (1 1, 10 10)', 1, 1, 0, 1)
    affine_tester(:trans_scale, 'LINESTRING (2 0, 11 0)', 'LINESTRING (1 1, 10 10)', 1, 1, 1, 0)
    affine_tester(:trans_scale, 'LINESTRING (3 2, 12 11)', 'LINESTRING (1 1, 10 10)', 2, 1, 1, 1)
    affine_tester(:trans_scale, 'LINESTRING (2 3, 11 12)', 'LINESTRING (1 1, 10 10)', 1, 2, 1, 1)
    affine_tester(:trans_scale, 'LINESTRING (4 2, 22 11)', 'LINESTRING (1 1, 10 10)', 1, 1, 2, 1)
    affine_tester(:trans_scale, 'LINESTRING (2 4, 11 22)', 'LINESTRING (1 1, 10 10)', 1, 1, 1, 2)
    affine_tester(:trans_scale, 'LINESTRING (15 28, 60 91)', 'LINESTRING (1 1, 10 10)', 2, 3, 5, 7)

    writer.output_dimensions = 3
    affine_tester(:trans_scale, 'LINESTRING Z (15 28 1, 60 91 10)', 'LINESTRING Z (1 1 1, 10 10 10)', 2, 3, 5, 7)
  end

  def test_trans_scale_hash
    affine_tester(:trans_scale, 'LINESTRING (2 2, 11 11)', 'LINESTRING (1 1, 10 10)', delta_x: 1, delta_y: 1, x_factor: 1, y_factor: 1)

    writer.output_dimensions = 3
    affine_tester(:trans_scale, 'LINESTRING Z (15 28 1, 60 91 10)', 'LINESTRING Z (1 1 1, 10 10 10)', delta_x: 2, delta_y: 3, x_factor: 5, y_factor: 7)
    affine_tester(:trans_scale, 'LINESTRING Z (3 1 1, 12 10 10)', 'LINESTRING Z (1 1 1, 10 10 10)', delta_x: 2, z_factor: 2)
  end

  def test_translate
    affine_tester(:translate, 'LINESTRING (5 12, 15 22)', 'LINESTRING (0 0, 10 10)', 5, 12)

    writer.output_dimensions = 3
    affine_tester(:translate, 'LINESTRING Z (-3 -7 3, 7 3 13)', 'LINESTRING Z (0 0 0, 10 10 10)', -3, -7, 3)
  end

  def test_translate_hash
    affine_tester(:translate, 'LINESTRING (5 12, 15 22)', 'LINESTRING (0 0, 10 10)', x: 5, y: 12)

    writer.output_dimensions = 3
    affine_tester(:translate, 'LINESTRING Z (-3 -7 3, 7 3 13)', 'LINESTRING Z (0 0 0, 10 10 10)', x: -3, y: -7, z: 3)
  end

  def test_line_interpolate_point
    %w{
      line_interpolate_point
      interpolate_point
    }.each do |method|
      writer.output_dimensions = 2
      simple_tester(method, 'POINT (0 0)', 'LINESTRING (0 0, 1 1)', 0)
      simple_tester(method, 'POINT (1 1)', 'LINESTRING (0 0, 1 1)', 1)
      simple_tester(method, 'POINT (0 25)', 'LINESTRING (0 0, 0 25, 0 50, 0 75, 0 100)', 0.25)

      writer.output_dimensions = 3
      simple_tester(method, 'POINT Z (0.5 0.5 7.5)', 'LINESTRING(0 0 10, 1 1 5)', 0.5)
    end
  end

  def test_line_interpolate_point_with_srid
    writer.trim = true

    srid_copy_tester(:line_interpolate_point, 'POINT (0 0)', 0, :zero, 'LINESTRING (0 0, 1 1)', 0)
    srid_copy_tester(:line_interpolate_point, 'POINT (0 0)', 4326, :lenient, 'LINESTRING (0 0, 1 1)', 0)
    srid_copy_tester(:line_interpolate_point, 'POINT (0 0)', 4326, :strict, 'LINESTRING (0 0, 1 1)', 0)

    srid_copy_tester(:line_interpolate_point, 'POINT (1 1)', 0, :zero, 'LINESTRING (0 0, 1 1)', 1)
    srid_copy_tester(:line_interpolate_point, 'POINT (1 1)', 4326, :lenient, 'LINESTRING (0 0, 1 1)', 1)
    srid_copy_tester(:line_interpolate_point, 'POINT (1 1)', 4326, :strict, 'LINESTRING (0 0, 1 1)', 1)

    srid_copy_tester(:line_interpolate_point, 'POINT (0 25)', 0, :zero, 'LINESTRING (0 0, 0 25, 0 50, 0 75, 0 100)', 0.25)
    srid_copy_tester(:line_interpolate_point, 'POINT (0 25)', 4326, :lenient, 'LINESTRING (0 0, 0 25, 0 50, 0 75, 0 100)', 0.25)
    srid_copy_tester(:line_interpolate_point, 'POINT (0 25)', 4326, :strict, 'LINESTRING (0 0, 0 25, 0 50, 0 75, 0 100)', 0.25)

    writer.output_dimensions = 3
    srid_copy_tester(:line_interpolate_point, 'POINT Z (0.5 0.5 7.5)', 0, :zero, 'LINESTRING(0 0 10, 1 1 5)', 0.5)
    srid_copy_tester(:line_interpolate_point, 'POINT Z (0.5 0.5 7.5)', 4326, :lenient, 'LINESTRING(0 0 10, 1 1 5)', 0.5)
    srid_copy_tester(:line_interpolate_point, 'POINT Z (0.5 0.5 7.5)', 4326, :strict, 'LINESTRING(0 0 10, 1 1 5)', 0.5)
  end
end
