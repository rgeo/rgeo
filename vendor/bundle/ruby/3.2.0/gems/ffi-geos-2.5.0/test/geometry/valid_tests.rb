# frozen_string_literal: true

require 'test_helper'

class GeometryValidTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_valid
    assert_geom_valid(read('POINT(0 0)'))
    refute_geom_valid(read('POINT(0 NaN)'))
    refute_geom_valid(read('POINT(0 nan)'))
  end

  def test_valid_reason
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:valid_reason)

    assert_equal('Valid Geometry', read('POINT(0 0)').valid_reason)
    assert_equal('Invalid Coordinate[0 nan]', read('POINT(0 NaN)').valid_reason)
    assert_equal('Invalid Coordinate[0 nan]', read('POINT(0 nan)').valid_reason)
    assert_equal('Self-intersection[2.5 5]', read('POLYGON((0 0, 0 5, 5 5, 5 10, 0 0))').valid_reason)
  end

  def test_valid_detail
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:valid_detail)

    tester = lambda { |detail, location, geom, flags|
      ret = read(geom).valid_detail(flags)

      assert_equal(detail, ret[:detail])
      assert_equal(location, write(ret[:location]))
    }

    assert_nil(read('POINT(0 0)').valid_detail)

    if Geos::GEOS_NICE_VERSION >= '031000'
      tester['Invalid Coordinate', 'POINT (0 NaN)', 'POINT(0 NaN)', 0]
    else
      tester['Invalid Coordinate', 'POINT (0 nan)', 'POINT(0 NaN)', 0]
    end

    tester['Self-intersection', 'POINT (2.5 5)', 'POLYGON((0 0, 0 5, 5 5, 5 10, 0 0))', 0]

    tester['Ring Self-intersection', 'POINT (0 0)', 'POLYGON((0 0, -10 10, 10 10, 0 0, 4 5, -4 5, 0 0))', 0]

    assert_nil(
      read('POLYGON((0 0, -10 10, 10 10, 0 0, 4 5, -4 5, 0 0))').valid_detail(
        :allow_selftouching_ring_forming_hole
      )
    )
  end
end
