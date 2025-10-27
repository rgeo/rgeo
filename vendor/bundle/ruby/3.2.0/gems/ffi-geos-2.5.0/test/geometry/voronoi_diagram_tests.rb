# frozen_string_literal: true

require 'test_helper'

class GeometryVoronoiDiagramTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_voronoi_diagram
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:voronoi_diagram)

    tester = lambda { |expected, geom, *args|
      geom = read(geom)
      voronoi_diagram = geom.voronoi_diagram(*args)

      assert_equal(expected, write(voronoi_diagram))
    }

    writer.trim = true

    geom = 'MULTIPOINT(0 0, 100 0, 100 100, 0 100)'

    tester[
      if Geos::GEOS_NICE_VERSION > '030900'
        'GEOMETRYCOLLECTION (POLYGON ((200 200, 200 50, 50 50, 50 200, 200 200)), POLYGON ((-100 200, 50 200, 50 50, -100 50, -100 200)), POLYGON ((-100 -100, -100 50, 50 50, 50 -100, -100 -100)), POLYGON ((200 -100, 50 -100, 50 50, 200 50, 200 -100)))'
      else
        'GEOMETRYCOLLECTION (POLYGON ((50 200, 200 200, 200 50, 50 50, 50 200)), POLYGON ((-100 50, -100 200, 50 200, 50 50, -100 50)), POLYGON ((50 -100, -100 -100, -100 50, 50 50, 50 -100)), POLYGON ((200 50, 200 -100, 50 -100, 50 50, 200 50)))'
      end,
      geom
    ]

    tester['MULTILINESTRING ((50 50, 50 200), (200 50, 50 50), (50 50, -100 50), (50 50, 50 -100))', geom, tolerance: 0, only_edges: true]

    tester['MULTILINESTRING ((50 50, 50 1100), (1100 50, 50 50), (50 50, -1000 50), (50 50, 50 -1000))', geom,
      only_edges: true,
      envelope: read(geom).buffer(1000)
    ]

    # Allows a tolerance for the first argument
    writer.rounding_precision = if Geos::GEOS_NICE_VERSION >= '031000'
      0
    else
      3
    end

    writer.trim = true

    tester[
      if Geos::GEOS_NICE_VERSION > '030900'
        'GEOMETRYCOLLECTION (POLYGON ((290 140, 185 140, 185 215, 188 235, 290 252, 290 140)), POLYGON ((80 340, 101 340, 188 235, 185 215, 80 215, 80 340)), POLYGON ((80 140, 80 215, 185 215, 185 140, 80 140)), POLYGON ((290 340, 290 252, 188 235, 101 340, 290 340)))'
      else
        'GEOMETRYCOLLECTION (POLYGON ((290 252, 290 140, 185 140, 185 215, 188 235, 290 252)), POLYGON ((80 215, 80 340, 101 340, 188 235, 185 215, 80 215)), POLYGON ((185 140, 80 140, 80 215, 185 215, 185 140)), POLYGON ((101 340, 290 340, 290 252, 188 235, 101 340)))'
      end,
      'MULTIPOINT ((150 210), (210 270), (150 220), (220 210), (215 269))',
      10
    ]
  end
end
