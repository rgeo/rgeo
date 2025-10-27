# frozen_string_literal: true

require 'test_helper'

class GeometryReverseTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_reverse
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:reverse)

    simple_tester(:reverse, 'POINT (3 5)', 'POINT (3 5)')

    if Geos::GEOS_NICE_VERSION >= '031200'
      simple_tester(:reverse, 'MULTIPOINT ((100 100), (10 100), (30 100))', 'MULTIPOINT (100 100, 10 100, 30 100)')
    else
      simple_tester(:reverse, 'MULTIPOINT (100 100, 10 100, 30 100)', 'MULTIPOINT (100 100, 10 100, 30 100)')
    end

    simple_tester(:reverse, 'LINESTRING (200 200, 200 100)', 'LINESTRING (200 100, 200 200)')

    if Geos::GEOS_NICE_VERSION >= '030801'
      simple_tester(:reverse, 'MULTILINESTRING ((3 3, 4 4), (1 1, 2 2))', 'MULTILINESTRING ((4 4, 3 3), (2 2, 1 1))')
    else
      simple_tester(:reverse, 'MULTILINESTRING ((1 1, 2 2), (3 3, 4 4))', 'MULTILINESTRING ((4 4, 3 3), (2 2, 1 1))')
    end

    simple_tester(:reverse, 'POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1))', 'POLYGON ((0 0, 0 10, 10 10, 10 0, 0 0), (1 1, 1 2, 2 2, 2 1, 1 1))')
    simple_tester(:reverse, 'MULTIPOLYGON (((0 0, 10 0, 10 10, 0 10, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1)), ((100 100, 100 200, 200 200, 100 100)))', 'MULTIPOLYGON (((0 0, 0 10, 10 10, 10 0, 0 0), (1 1, 1 2, 2 2, 2 1, 1 1)), ((100 100, 200 200, 100 200, 100 100)))')
    simple_tester(:reverse, 'GEOMETRYCOLLECTION (LINESTRING (1 1, 2 2), GEOMETRYCOLLECTION (LINESTRING (3 5, 2 9)))', 'GEOMETRYCOLLECTION (LINESTRING (2 2, 1 1), GEOMETRYCOLLECTION(LINESTRING (2 9, 3 5)))')
    simple_tester(:reverse, 'POINT EMPTY', 'POINT EMPTY')
    simple_tester(:reverse, 'LINESTRING EMPTY', 'LINESTRING EMPTY')
    simple_tester(:reverse, 'LINEARRING EMPTY', 'LINEARRING EMPTY')
    simple_tester(:reverse, 'POLYGON EMPTY', 'POLYGON EMPTY')
    simple_tester(:reverse, 'MULTIPOINT EMPTY', 'MULTIPOINT EMPTY')
    simple_tester(:reverse, 'MULTILINESTRING EMPTY', 'MULTILINESTRING EMPTY')
    simple_tester(:reverse, 'MULTIPOLYGON EMPTY', 'MULTIPOLYGON EMPTY')
    simple_tester(:reverse, 'GEOMETRYCOLLECTION EMPTY', 'GEOMETRYCOLLECTION EMPTY')
  end
end
