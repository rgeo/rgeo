# -----------------------------------------------------------------------------
#
# Tests for the GEOS polygon implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/polygon_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module GeosFFI # :nodoc:
      class TestPolygon < ::Test::Unit::TestCase # :nodoc:
        def setup
          @factory = ::RGeo::Geos.factory(native_interface: :ffi)
        end

        include ::RGeo::Tests::Common::PolygonTests

        def test_intersection
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 2)
          point3_ = @factory.point(2, 2)
          point4_ = @factory.point(2, 0)
          poly1_ = @factory.polygon(@factory.linear_ring([point1_, point2_, point3_, point4_]))
          poly2_ = @factory.polygon(@factory.linear_ring([point1_, point2_, point4_]))
          poly3_ = poly1_.intersection(poly2_)
          assert_equal(poly2_, poly3_)
        end

        def test_union
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 2)
          point3_ = @factory.point(2, 2)
          point4_ = @factory.point(2, 0)
          poly1_ = @factory.polygon(@factory.linear_ring([point1_, point2_, point3_, point4_]))
          poly2_ = @factory.polygon(@factory.linear_ring([point1_, point2_, point4_]))
          poly3_ = poly1_.union(poly2_)
          assert_equal(poly1_, poly3_)
        end
      end
    end
  end
end if ::RGeo::Geos.ffi_supported?
