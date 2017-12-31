# -----------------------------------------------------------------------------
#
# Tests for the simple mercator multi polygon implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/multi_polygon_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module SimpleMercator # :nodoc:
      class TestMultiPolygon < ::Test::Unit::TestCase # :nodoc:
        include RGeo::Tests::Common::MultiPolygonTests

        def create_factories
          @factory = ::RGeo::Geographic.simple_mercator_factory
          @lenient_factory = ::RGeo::Geographic.simple_mercator_factory(lenient_multi_polygon_assertions: true)
        end
      end
    end
  end
end
