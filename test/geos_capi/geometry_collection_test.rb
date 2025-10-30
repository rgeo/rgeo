# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS geometry collection implementation
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"
require_relative "skip_capi"

class GeosGeometryCollectionTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::GeometryCollectionTests
  prepend SkipCAPI

  def create_factory
    RGeo::Geos.factory
  end

  def test_collection_node
    lines = [[[0, 0], [0, 2]], [[-1, 1], [1, 1]]]
            .map { |p1, p2| [@factory.point(*p1), @factory.point(*p2)] }
            .map { |p1, p2| @factory.line(p1, p2) }

    multi = @factory.multi_line_string(lines)

    expected_lines = [
      [[0, 0],  [0, 1]],
      [[0, 1],  [0, 2]],
      [[-1, 1], [0, 1]],
      [[0, 1],  [1, 1]]
    ].map { |p1, p2| @factory.line(@factory.point(*p1), @factory.point(*p2)) }

    noded = multi.node

    assert_equal(noded.count, 4)
    assert(expected_lines.all? { |line| noded.include? line })
  end

  def test_polygonize_collection
    input = @factory.parse_wkt(
      "GEOMETRYCOLLECTION(LINESTRING(0 0, 1 1, 1 0, 0 0), POINT(2 2))"
    )
    expected = @factory.parse_wkt(
      "GEOMETRYCOLLECTION(POLYGON ((0 0, 1 1, 1 0, 0 0)))"
    )

    assert_equal expected, input.polygonize
  end

  # GEOS 3.14+ Clustering features

  def test_cluster_dbscan_basic

    # Create 3 clusters of points
    points = [
      # Cluster 1
      @factory.point(0, 0),
      @factory.point(0.5, 0),
      @factory.point(0, 0.5),
      # Cluster 2
      @factory.point(10, 10),
      @factory.point(10.5, 10),
      # Cluster 3 (isolated point - noise)
      @factory.point(100, 100)
    ]
    collection = @factory.collection(points)

    clusters = collection.cluster_dbscan(2.0, 2)

    assert_instance_of Array, clusters
    # Should have clusters for points in dense regions
    assert clusters.any? { |c| c.is_a?(RGeo::Geos::CAPIGeometryCollectionImpl) }
  end

  def test_cluster_by_distance

    points = [
      @factory.point(0, 0),
      @factory.point(1, 0),
      @factory.point(10, 10),
      @factory.point(11, 10)
    ]
    collection = @factory.collection(points)

    clusters = collection.cluster_by_distance(2.0)

    assert_instance_of Array, clusters
    assert_equal 2, clusters.length
    clusters.each do |cluster|
      assert_instance_of RGeo::Geos::CAPIGeometryCollectionImpl, cluster
    end
  end

  def test_cluster_by_intersects

    # Two overlapping polygons and one separate
    polys = [
      @factory.parse_wkt("POLYGON((0 0, 2 0, 2 2, 0 2, 0 0))"),
      @factory.parse_wkt("POLYGON((1 1, 3 1, 3 3, 1 3, 1 1))"),
      @factory.parse_wkt("POLYGON((10 10, 12 10, 12 12, 10 12, 10 10))")
    ]
    collection = @factory.collection(polys)

    clusters = collection.cluster_by_intersects

    assert_instance_of Array, clusters
    assert_equal 2, clusters.length
  end

  def test_cluster_by_envelope_distance

    points = [
      @factory.point(0, 0),
      @factory.point(1, 0),
      @factory.point(10, 10),
      @factory.point(11, 10)
    ]
    collection = @factory.collection(points)

    clusters = collection.cluster_by_envelope_distance(2.0)

    assert_instance_of Array, clusters
    assert_equal 2, clusters.length
  end

  # GEOS 3.14+ Coverage features

  def test_coverage_is_valid_with_valid_coverage

    # A valid coverage: two adjacent non-overlapping polygons
    polys = [
      @factory.parse_wkt("POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))"),
      @factory.parse_wkt("POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))")
    ]
    collection = @factory.collection(polys)

    assert collection.coverage_is_valid?
  end

  def test_coverage_is_valid_with_invalid_coverage

    # An invalid coverage: two overlapping polygons
    polys = [
      @factory.parse_wkt("POLYGON((0 0, 2 0, 2 2, 0 2, 0 0))"),
      @factory.parse_wkt("POLYGON((1 1, 3 1, 3 3, 1 3, 1 1))")
    ]
    collection = @factory.collection(polys)

    refute collection.coverage_is_valid?
  end

  def test_coverage_invalid_edges

    # Overlapping polygons - should return invalid edges
    polys = [
      @factory.parse_wkt("POLYGON((0 0, 2 0, 2 2, 0 2, 0 0))"),
      @factory.parse_wkt("POLYGON((1 1, 3 1, 3 3, 1 3, 1 1))")
    ]
    collection = @factory.collection(polys)

    edges = collection.coverage_invalid_edges(0.0)

    assert_instance_of RGeo::Geos::CAPIGeometryCollectionImpl, edges
  end

  def test_coverage_simplify_vw

    # Two adjacent polygons
    polys = [
      @factory.parse_wkt("POLYGON((0 0, 1 0, 1 0.1, 1 1, 0 1, 0 0))"),
      @factory.parse_wkt("POLYGON((1 0, 2 0, 2 1, 1 1, 1 0.1, 1 0))")
    ]
    collection = @factory.collection(polys)

    simplified = collection.coverage_simplify_vw(0.5, false)

    assert_instance_of RGeo::Geos::CAPIGeometryCollectionImpl, simplified
    assert_equal 2, simplified.count
  end

  def test_coverage_union

    # Two adjacent non-overlapping polygons
    polys = [
      @factory.parse_wkt("POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))"),
      @factory.parse_wkt("POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))")
    ]
    collection = @factory.collection(polys)

    union = collection.coverage_union

    assert_instance_of RGeo::Geos::CAPIPolygonImpl, union
    # Union should be a single rectangle
    expected = @factory.parse_wkt("POLYGON((0 0, 2 0, 2 1, 1 1, 0 1, 0 0))")
    assert union.equals?(expected)
  end
end
