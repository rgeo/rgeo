# -----------------------------------------------------------------------------
#
# Tests for the simple mercator polygon implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

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
