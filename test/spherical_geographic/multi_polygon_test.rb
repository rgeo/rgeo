# -----------------------------------------------------------------------------
#
# Tests for the simple spherical multi polygon implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/multi_polygon_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module SphericalGeographic # :nodoc:
      class TestMultiPolygon < ::Test::Unit::TestCase # :nodoc:
        def create_factories
          @factory = ::RGeo::Geographic.spherical_factory
          @lenient_factory = ::RGeo::Geographic.spherical_factory(lenient_multi_polygon_assertions: true)
        end

        include ::RGeo::Tests::Common::MultiPolygonTests

        undef_method :test_creation_wrong_type
        undef_method :test_creation_overlapping
        undef_method :test_creation_connected
        undef_method :test_equal
        undef_method :test_not_equal
      end
    end
  end
end
