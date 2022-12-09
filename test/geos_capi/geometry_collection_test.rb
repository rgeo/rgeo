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
end
