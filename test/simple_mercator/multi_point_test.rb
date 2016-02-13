# -----------------------------------------------------------------------------
#
# Tests for the simple mercator multi point implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/multi_point_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module SimpleMercator # :nodoc:
      class TestMultiPoint < ::Test::Unit::TestCase # :nodoc:
        def create_factory(opts_ = {})
          ::RGeo::Geographic.simple_mercator_factory(opts_)
        end

        include ::RGeo::Tests::Common::MultiPointTests

        # These tests suffer from floating point issues
        undef_method :test_union
        undef_method :test_difference
        undef_method :test_intersection
      end
    end
  end
end
