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
        def create_factory
          ::RGeo::Geographic.simple_mercator_factory
        end

        include ::RGeo::Tests::Common::MultiLineStringTests

        undef_method :test_length
      end
    end
  end
end
