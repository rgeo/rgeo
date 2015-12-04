# -----------------------------------------------------------------------------
#
# Tests for the simple spherical polygon implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/polygon_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module SphericalGeographic # :nodoc:
      class TestPolygon < ::Test::Unit::TestCase # :nodoc:
        def setup
          @factory = ::RGeo::Geographic.spherical_factory
        end

        include ::RGeo::Tests::Common::PolygonTests

        undef_method :test_fully_equal
        undef_method :test_geometrically_equal_but_ordered_different
        undef_method :test_geometrically_equal_but_different_directions
      end
    end
  end
end
