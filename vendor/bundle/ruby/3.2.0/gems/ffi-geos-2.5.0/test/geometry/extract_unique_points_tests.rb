# frozen_string_literal: true

require 'test_helper'

class GeometryExtractUniquePointsTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_extract_unique_points
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:extract_unique_points)

    geom = read('GEOMETRYCOLLECTION (
      MULTIPOLYGON (
        ((0 0, 1 0, 1 1, 0 1, 0 0)),
        ((10 10, 10 14, 14 14, 14 10, 10 10),
        (11 11, 11 12, 12 12, 12 11, 11 11))
      ),
      POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0)),
      MULTILINESTRING ((0 0, 2 3), (10 10, 3 4)),
      LINESTRING (0 0, 2 3),
      MULTIPOINT (0 0, 2 3),
      POINT (9 0),
      POINT (1 0),
      LINESTRING EMPTY
    )')

    simple_tester(
      :extract_unique_points,
      if Geos::GEOS_NICE_VERSION >= '031200'
        'MULTIPOINT ((0 0), (1 0), (1 1), (0 1), (10 10), (10 14), (14 14), (14 10), (11 11), (11 12), (12 12), (12 11), (2 3), (3 4), (9 0))'
      else
        'MULTIPOINT (0 0, 1 0, 1 1, 0 1, 10 10, 10 14, 14 14, 14 10, 11 11, 11 12, 12 12, 12 11, 2 3, 3 4, 9 0)'
      end,
      geom.extract_unique_points
    )
  end
end
