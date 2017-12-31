# -----------------------------------------------------------------------------
#
# Tests for the simple mercator line string implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

module RGeo
  module Tests # :nodoc:
    module SimpleMercator # :nodoc:
      class TestLineString < ::Test::Unit::TestCase # :nodoc:
        def setup
          @factory = ::RGeo::Geographic.simple_mercator_factory
        end

        include ::RGeo::Tests::Common::LineStringTests
      end
    end
  end
end
