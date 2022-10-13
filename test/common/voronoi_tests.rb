# frozen_string_literal: true

module RGeo
  module Tests
    module Common
      module VoronoiTests
        def test_empty_voronoi_diagram
          point = @factory.point(1, 1)
          diagram = point.voronoi_diagram
          edge_diagram = point.voronoi_diagram(only_edges: true)

          assert(diagram.empty?)
          assert(edge_diagram.empty?)
          assert(RGeo::Feature::GeometryCollection, diagram.geometry_type)
          assert(RGeo::Feature::MultiLineString, edge_diagram.geometry_type)
        end

        def test_voronoi_diagram
          line = @factory.parse_wkt("LINESTRING (1 0, 1 2)")
          envelope = @factory.parse_wkt("POLYGON ((-10 -10, 21 -10, 21 21, -10 21, -10 -10))")
          expected_collection = @factory.parse_wkt <<~WKT
            GEOMETRYCOLLECTION (
              POLYGON ((-1 4, 3 4, 3 1, -1 1, -1 4)),
              POLYGON ((3 -2, -1 -2, -1 1, 3 1, 3 -2))
            )
          WKT
          assert_equal(expected_collection, line.voronoi_diagram)
          assert_equal(RGeo::Feature::LineString, line.voronoi_diagram(only_edges: true).geometry_type)
          assert_equal(RGeo::Feature::MultiLineString, envelope.voronoi_diagram(only_edges: true).geometry_type)

          expected_collection_in_envelope = @factory.parse_wkt <<~WKT
            GEOMETRYCOLLECTION (
              POLYGON ((-10 21, 21 21, 21 1, -10 1, -10 21)),
              POLYGON ((21 -10, -10 -10, -10 1, 21 1, 21 -10))
            )
          WKT
          assert_equal(expected_collection_in_envelope, line.voronoi_diagram(envelope: envelope)) # TODO: why is envelope ignored ?
        end

        def test_voronoi_diagram_tolerance
          polygon = @factory.parse_wkt("POLYGON ((0 0, 0.5 0, 0.5 0.5, 0 0.5, 0 0))")
          polygon.voronoi_diagram(tolerance: 1.0)
          error = assert_raises(RGeo::Error::InvalidGeometry) do
            polygon.voronoi_diagram(tolerance: 0.6)
          end
          assert_match(/Try removing the `tolerance` parameter from #voronoi_diagram/, error.message)
        end
      end
    end
  end
end
