# -----------------------------------------------------------------------------
#
# Tests for the simple mercator multi line string implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/multi_line_string_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module SimpleMercator # :nodoc:
      class TestMultiLineString < ::Test::Unit::TestCase # :nodoc:
        include RGeo::Tests::Common::MultiLineStringTests

        def create_factory
          ::RGeo::Geographic.simple_mercator_factory
        end

        undef_method :test_length
      end
    end
  end
end
