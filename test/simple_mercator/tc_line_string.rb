# -----------------------------------------------------------------------------
#
# Tests for the simple mercator line string implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/line_string_tests.rb", ::File.dirname(__FILE__))

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
