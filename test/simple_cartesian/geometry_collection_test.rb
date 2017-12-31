# -----------------------------------------------------------------------------
#
# Tests for the simple cartesian geometry collection implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/geometry_collection_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module SimpleCartesian # :nodoc:
      class TestGeometryCollection < ::Test::Unit::TestCase # :nodoc:
        include RGeo::Tests::Common::GeometryCollectionTests

        def create_factory
          @factory = ::RGeo::Cartesian.simple_factory
        end

        undef_method :test_fully_equal
        undef_method :test_geometrically_equal
        undef_method :test_empty_equal
        undef_method :test_not_equal
        undef_method :test_empty_collection_boundary
      end
    end
  end
end
