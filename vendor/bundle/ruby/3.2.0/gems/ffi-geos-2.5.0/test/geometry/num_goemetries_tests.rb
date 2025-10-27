# frozen_string_literal: true

require 'test_helper'

class GeometryTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_num_geometries
    simple_tester(:num_geometries, 1, 'POINT(0 0)')
    simple_tester(:num_geometries, 2, 'MULTIPOINT (0 1, 2 3)')
    simple_tester(:num_geometries, 1, 'LINESTRING (0 0, 2 3)')
    simple_tester(:num_geometries, 2, 'MULTILINESTRING ((0 1, 2 3), (10 10, 3 4))')
    simple_tester(:num_geometries, 1, 'POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0))')
    simple_tester(:num_geometries, 2, 'MULTIPOLYGON(
      ((0 0, 1 0, 1 1, 0 1, 0 0)),
      ((10 10, 10 14, 14 14, 14 10, 10 10),
      (11 11, 11 12, 12 12, 12 11, 11 11)))')
    simple_tester(:num_geometries, 6, 'GEOMETRYCOLLECTION (
      MULTIPOLYGON (
        ((0 0, 1 0, 1 1, 0 1, 0 0)),
        ((10 10, 10 14, 14 14, 14 10, 10 10),
        (11 11, 11 12, 12 12, 12 11, 11 11))
      ),
      POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0)),
      MULTILINESTRING ((0 0, 2 3), (10 10, 3 4)),
      LINESTRING (0 0, 2 3),
      MULTIPOINT (0 0, 2 3),
      POINT (9 0))')
  end
end
