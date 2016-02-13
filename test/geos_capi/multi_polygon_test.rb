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
    module GeosCAPI # :nodoc:
      class TestMultiPolygon < ::Test::Unit::TestCase # :nodoc:
        def create_factories
          @factory = ::RGeo::Geos.factory
          @lenient_factory = ::RGeo::Geos.factory(lenient_multi_polygon_assertions: true)
        end

        include ::RGeo::Tests::Common::MultiPolygonTests

        # Centroid of an empty should return an empty collection rather than crash

        def test_empty_centroid
          assert_equal(@factory.collection([]), @factory.multi_polygon([]).centroid)
        end

        def _test_geos_bug_582
          f_ = ::RGeo::Geos.factory(buffer_resolution: 2)
          p1_ = f_.polygon(f_.linear_ring([]))
          p2_ = f_.polygon(f_.linear_ring([f_.point(0, 0), f_.point(0, 1), f_.point(1, 1), f_.point(1, 0)]))
          mp_ = f_.multi_polygon([p2_, p1_])
          mp_.centroid.as_text
        end
      end
    end
  end
end if ::RGeo::Geos.capi_supported?
