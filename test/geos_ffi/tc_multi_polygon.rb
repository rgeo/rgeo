# -----------------------------------------------------------------------------
#
# Tests for the GEOS multi polygon implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/multi_polygon_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module GeosFFI # :nodoc:
      class TestMultiPolygon < ::Test::Unit::TestCase # :nodoc:
        def create_factories
          @factory = ::RGeo::Geos.factory(native_interface: :ffi)
          @lenient_factory = ::RGeo::Geos.factory(lenient_multi_polygon_assertions: true,
                                                  native_interface: :ffi)
        end

        include ::RGeo::Tests::Common::MultiPolygonTests

        # Centroid of an empty should return an empty collection
        # rather than throw a weird exception out of ffi-geos

        def test_empty_centroid
          assert_equal(@factory.collection([]), @factory.multi_polygon([]).centroid)
        end
      end
    end
  end
end if ::RGeo::Geos.ffi_supported?
