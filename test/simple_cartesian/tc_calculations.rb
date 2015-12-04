# -----------------------------------------------------------------------------
#
# Tests for the internal calculations for simple cartesian
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

module RGeo
  module Tests # :nodoc:
    module Cartesian # :nodoc:
      class TestCalculations < ::Test::Unit::TestCase # :nodoc:
        def setup
          @factory = ::RGeo::Cartesian.simple_factory
          @point1 = @factory.point(3, 4)
          @point2 = @factory.point(5, 5)
          @point3 = @factory.point(6, 4)
          @point4 = @factory.point(3, 5)
          @point5 = @factory.point(-1, 2)
          @point6 = @factory.point(-1, 1)
          @point7 = @factory.point(5, 4)
          @point8 = @factory.point(1, 3)
          @horiz_seg = ::RGeo::Cartesian::Segment.new(@point1, @point3)
          @vert_seg = ::RGeo::Cartesian::Segment.new(@point4, @point1)
          @short_rising_seg = ::RGeo::Cartesian::Segment.new(@point1, @point2)
          @long_rising_seg = ::RGeo::Cartesian::Segment.new(@point5, @point2)
          @collinear_rising_seg = ::RGeo::Cartesian::Segment.new(@point5, @point8)
          @touching_collinear_rising_seg = ::RGeo::Cartesian::Segment.new(@point1, @point8)
          @parallel_rising_seg = ::RGeo::Cartesian::Segment.new(@point6, @point7)
          @steep_rising_seg = ::RGeo::Cartesian::Segment.new(@point6, @point4)
          @degenerate_seg = ::RGeo::Cartesian::Segment.new(@point5, @point5)
        end

        def assert_close_enough(v1_, v2_)
          diff_ = (v1_ - v2_).abs
          # denom_ = (v1_ + v2_).abs
          # diff_ /= denom_ if denom_ > 0.01
          assert(diff_ < 0.00000001, "#{v1_} is not close to #{v2_}")
        end

        def test_segment_degenerate
          assert(@degenerate_seg.degenerate?)
          assert_equal(0, @degenerate_seg.dx)
          assert_equal(0, @degenerate_seg.dy)
          assert_equal(@point5, @degenerate_seg.s)
          assert_equal(@point5, @degenerate_seg.e)
        end

        def test_segment_basic
          assert(!@short_rising_seg.degenerate?)
          assert_equal(2, @short_rising_seg.dx)
          assert_equal(1, @short_rising_seg.dy)
          assert_equal(@point1, @short_rising_seg.s)
          assert_equal(@point2, @short_rising_seg.e)
        end

        def test_segment_side_basic
          assert_equal(0.0, @short_rising_seg.side(@point5))
          assert(@short_rising_seg.side(@point4) > 0.0)
          assert(@short_rising_seg.side(@point6) < 0.0)
        end

        def test_segment_tproj_basic
          assert_equal(-2, @short_rising_seg.tproj(@point5))
          assert_close_enough(2.0 / 3.0, @long_rising_seg.tproj(@point1))
        end

        def test_segment_contains_point
          assert(@long_rising_seg.contains_point?(@point1))
          assert(@long_rising_seg.contains_point?(@point2))
          assert(!@long_rising_seg.contains_point?(@point3))
          assert(!@short_rising_seg.contains_point?(@point5))
        end

        def test_segment_intersects_parallel
          assert(@long_rising_seg.intersects_segment?(@long_rising_seg))
          assert(!@long_rising_seg.intersects_segment?(@parallel_rising_seg))
          assert(!@short_rising_seg.intersects_segment?(@collinear_rising_seg))
          assert(@touching_collinear_rising_seg.intersects_segment?(@short_rising_seg))
          assert(@touching_collinear_rising_seg.intersects_segment?(@long_rising_seg))
          assert(@long_rising_seg.intersects_segment?(@touching_collinear_rising_seg))
        end

        def test_segment_intersects_basic
          assert(@long_rising_seg.intersects_segment?(@steep_rising_seg))
          assert(@steep_rising_seg.intersects_segment?(@long_rising_seg))
          assert(!@short_rising_seg.intersects_segment?(@steep_rising_seg))
          assert(!@steep_rising_seg.intersects_segment?(@short_rising_seg))
        end

        def test_segment_intersects_endpoints
          assert(@horiz_seg.intersects_segment?(@vert_seg))
          assert(@vert_seg.intersects_segment?(@horiz_seg))
        end
      end
    end
  end
end
