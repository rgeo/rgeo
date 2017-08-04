# -----------------------------------------------------------------------------
#
# Tests for the GEOS geometry collection implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/geometry_collection_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module GeosCAPI # :nodoc:
      class TestGeometryCollection < ::Test::Unit::TestCase # :nodoc:
        def create_factory
          ::RGeo::Geos.factory
        end

        def test_collection_node
          lines = [ [[0,0], [0,2]], [[-1,1], [1,1]] ]
            .map { |p1,p2| [@factory.point(*p1), @factory.point(*p2)] }
            .map { |p1,p2| @factory.line(p1,p2) }

          multi = @factory.multi_line_string(lines)

          expected_lines = [
              [ [0,0],  [0,1] ],
              [ [0,1],  [0,2] ],
              [ [-1,1], [0,1] ],
              [ [0,1],  [1,1] ]
            ].map { |p1, p2| @factory.line(@factory.point(*p1), @factory.point(*p2)) }

          noded = multi.node

          assert_equal(noded.count, 4)
          assert_true(expected_lines.all? { |line| noded.include? line })
        end

        include ::RGeo::Tests::Common::GeometryCollectionTests
      end
    end
  end
end if ::RGeo::Geos.capi_supported?
