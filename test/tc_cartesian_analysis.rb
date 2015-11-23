# -----------------------------------------------------------------------------
#
# Tests for basic GeoJSON usage
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

module RGeo
  module Tests # :nodoc:
    class TestCartesianAnalysis < ::Test::Unit::TestCase # :nodoc:
      def setup
        @factory = ::RGeo::Cartesian.simple_factory
      end

      def test_ring_direction_clockwise_triangle
        p1_ = @factory.point(1, 1)
        p2_ = @factory.point(2, 4)
        p3_ = @factory.point(5, 2)
        ring_ = @factory.line_string([p1_, p2_, p3_, p1_])
        assert_equal(-1, ::RGeo::Cartesian::Analysis.ring_direction(ring_))
      end

      def test_ring_direction_counterclockwise_triangle
        p1_ = @factory.point(1, 1)
        p2_ = @factory.point(2, 4)
        p3_ = @factory.point(5, 2)
        ring_ = @factory.line_string([p1_, p3_, p2_, p1_])
        assert_equal(1, ::RGeo::Cartesian::Analysis.ring_direction(ring_))
      end

      def test_ring_direction_clockwise_puckered_quad
        p1_ = @factory.point(1, 1)
        p2_ = @factory.point(2, 6)
        p3_ = @factory.point(3, 3)
        p4_ = @factory.point(5, 2)
        ring_ = @factory.line_string([p1_, p2_, p3_, p4_, p1_])
        assert_equal(-1, ::RGeo::Cartesian::Analysis.ring_direction(ring_))
      end

      def test_ring_direction_counterclockwise_puckered_quad
        p1_ = @factory.point(1, 1)
        p2_ = @factory.point(2, 6)
        p3_ = @factory.point(3, 3)
        p4_ = @factory.point(5, 2)
        ring_ = @factory.line_string([p1_, p4_, p3_, p2_, p1_])
        assert_equal(1, ::RGeo::Cartesian::Analysis.ring_direction(ring_))
      end

      def test_ring_direction_counterclockwise_near_circle
        p1_ = @factory.point(0, -3)
        p2_ = @factory.point(2, -2)
        p3_ = @factory.point(3, 0)
        p4_ = @factory.point(2, 2)
        p5_ = @factory.point(0, 3)
        p6_ = @factory.point(-2, 2)
        p7_ = @factory.point(-3, 0)
        p8_ = @factory.point(-2, -2)
        ring_ = @factory.line_string([p1_, p2_, p3_, p4_, p5_, p6_, p7_, p8_, p1_])
        assert_equal(1, ::RGeo::Cartesian::Analysis.ring_direction(ring_))
      end
    end
  end
end
