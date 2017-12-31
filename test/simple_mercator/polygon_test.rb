# -----------------------------------------------------------------------------
#
# Tests for the simple mercator polygon implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/polygon_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module SimpleMercator # :nodoc:
      class TestPolygon < ::Test::Unit::TestCase # :nodoc:
        include RGeo::Tests::Common::PolygonTests

        def setup
          @factory = ::RGeo::Geographic.simple_mercator_factory
        end
      end
    end
  end
end
