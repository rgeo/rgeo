# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS geometry collection implementation
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"

class GeosGeometryCollectionTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::GeometryCollectionTests

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
end if RGeo::Geos.capi_supported?
