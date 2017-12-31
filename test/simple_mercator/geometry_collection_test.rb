# -----------------------------------------------------------------------------
#
# Tests for the simple mercator geometry collection implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

module RGeo
  module Tests # :nodoc:
    module SimpleMercator # :nodoc:
      class TestGeometryCollection < ::Test::Unit::TestCase # :nodoc:
        include RGeo::Tests::Common::GeometryCollectionTests

        def create_factory
          ::RGeo::Geographic.simple_mercator_factory
        end
      end
    end
  end
end
