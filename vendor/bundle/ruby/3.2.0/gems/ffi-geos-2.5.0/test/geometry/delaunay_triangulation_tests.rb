# frozen_string_literal: true

require 'test_helper'

class GeometryDelaunayTriangulationTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_delaunay_triangulation
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:delaunay_triangulation)

    tester = lambda { |expected, geom, *args|
      geom = read(geom)
      geom_tri = geom.delaunay_triangulation(*args)
      geom_tri.normalize!

      assert_equal(expected, write(geom_tri))
    }

    writer.trim = true

    # empty polygon
    tester['GEOMETRYCOLLECTION EMPTY', 'POLYGON EMPTY', 0]
    tester['MULTILINESTRING EMPTY', 'POLYGON EMPTY', 0, only_edges: true]

    # single point
    tester['GEOMETRYCOLLECTION EMPTY', 'POINT (0 0)', 0]
    tester['MULTILINESTRING EMPTY', 'POINT (0 0)', 0, only_edges: true]

    # three collinear points
    tester['GEOMETRYCOLLECTION EMPTY', 'MULTIPOINT(0 0, 5 0, 10 0)', 0]
    tester['MULTILINESTRING ((5 0, 10 0), (0 0, 5 0))', 'MULTIPOINT(0 0, 5 0, 10 0)', 0, only_edges: true]

    # three points
    tester['GEOMETRYCOLLECTION (POLYGON ((0 0, 10 10, 5 0, 0 0)))', 'MULTIPOINT(0 0, 5 0, 10 10)', 0]
    tester['MULTILINESTRING ((5 0, 10 10), (0 0, 10 10), (0 0, 5 0))', 'MULTIPOINT(0 0, 5 0, 10 10)', 0, only_edges: true]

    # polygon with a hole
    tester[
      'GEOMETRYCOLLECTION (POLYGON ((8 2, 10 10, 8.5 1, 8 2)), POLYGON ((7 8, 10 10, 8 2, 7 8)), POLYGON ((3 8, 10 10, 7 8, 3 8)), ' \
      'POLYGON ((2 2, 8 2, 8.5 1, 2 2)), POLYGON ((2 2, 7 8, 8 2, 2 2)), POLYGON ((2 2, 3 8, 7 8, 2 2)), POLYGON ((0.5 9, 10 10, 3 8, 0.5 9)), ' \
      'POLYGON ((0.5 9, 3 8, 2 2, 0.5 9)), POLYGON ((0 0, 2 2, 8.5 1, 0 0)), POLYGON ((0 0, 0.5 9, 2 2, 0 0)))',
      'POLYGON((0 0, 8.5 1, 10 10, 0.5 9, 0 0),(2 2, 3 8, 7 8, 8 2, 2 2))',
      0
    ]

    tester[
      'MULTILINESTRING ((8.5 1, 10 10), (8 2, 10 10), (8 2, 8.5 1), (7 8, 10 10), (7 8, 8 2), (3 8, 10 10), (3 8, 7 8), (2 2, 8.5 1), (2 2, 8 2), (2 2, 7 8), (2 2, 3 8), (0.5 9, 10 10), (0.5 9, 3 8), (0.5 9, 2 2), (0 0, 8.5 1), (0 0, 2 2), (0 0, 0.5 9))',
      'POLYGON((0 0, 8.5 1, 10 10, 0.5 9, 0 0),(2 2, 3 8, 7 8, 8 2, 2 2))',
      0,
      only_edges: true
    ]

    # four points with a tolerance making one collapse
    tester['MULTILINESTRING ((10 0, 10 10), (0 0, 10 10), (0 0, 10 0))', 'MULTIPOINT(0 0, 10 0, 10 10, 11 10)', 2.0, only_edges: true]

    # tolerance as an option
    tester['MULTILINESTRING ((10 0, 10 10), (0 0, 10 10), (0 0, 10 0))', 'MULTIPOINT(0 0, 10 0, 10 10, 11 10)', tolerance: 2.0, only_edges: true]
  end

  def test_constrained_delaunay_triangulation
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:constrained_delaunay_triangulation)

    tester = lambda { |expected, geom|
      geom = read(geom)
      geom_tri = geom.constrained_delaunay_triangulation
      geom_tri.normalize!

      assert_equal(write(read(expected).normalize), write(geom_tri))
    }

    writer.trim = true

    tester['GEOMETRYCOLLECTION EMPTY', 'POLYGON EMPTY']
    tester['GEOMETRYCOLLECTION EMPTY', 'POINT(0 0)']
    tester['GEOMETRYCOLLECTION (POLYGON ((10 10, 20 40, 90 10, 10 10)), POLYGON ((90 90, 20 40, 90 10, 90 90)))', 'POLYGON ((10 10, 20 40, 90 90, 90 10, 10 10))']
  end
end
