# -----------------------------------------------------------------------------
#
# Tests for the GEOS factory
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/factory_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module SimpleMercator # :nodoc:
      class TestFactory < ::Test::Unit::TestCase # :nodoc:
        include RGeo::Tests::Common::FactoryTests

        def setup
          @factory = ::RGeo::Geographic.simple_mercator_factory
          @srid = 4326
        end
      end
    end
  end
end
