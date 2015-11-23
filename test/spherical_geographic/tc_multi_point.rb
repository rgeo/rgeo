# -----------------------------------------------------------------------------
#
# Tests for the simple spherical multi point implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/multi_point_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module SphericalGeographic # :nodoc:
      class TestMultiPoint < ::Test::Unit::TestCase # :nodoc:
        def create_factory(opts_ = {})
          @factory = ::RGeo::Geographic.spherical_factory(opts_)
        end

        include ::RGeo::Tests::Common::MultiPointTests

        undef_method :test_fully_equal
        undef_method :test_geometrically_equal
        undef_method :test_not_equal
        undef_method :test_union
        undef_method :test_difference
        undef_method :test_intersection
      end
    end
  end
end
