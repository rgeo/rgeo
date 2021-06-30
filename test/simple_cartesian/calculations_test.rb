# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the internal calculations for simple cartesian
#
# -----------------------------------------------------------------------------

require "test_helper"

class CartesianCalculationsTest < Minitest::Test # :nodoc:
  def setup
    @factory = RGeo::Cartesian.simple_factory
    @point1 = @factory.point(3, 4)
    @point2 = @factory.point(5, 5)
    @point3 = @factory.point(6, 4)
    @point4 = @factory.point(3, 5)
    @point5 = @factory.point(-1, 2)
    @point6 = @factory.point(-1, 1)
    @point7 = @factory.point(5, 4)
    @point8 = @factory.point(1, 3)
    @horiz_seg = RGeo::Cartesian::Segment.new(@point1, @point3)
    @vert_seg = RGeo::Cartesian::Segment.new(@point4, @point1)
    @short_rising_seg = RGeo::Cartesian::Segment.new(@point1, @point2)
    @long_rising_seg = RGeo::Cartesian::Segment.new(@point5, @point2)
    @collinear_rising_seg = RGeo::Cartesian::Segment.new(@point5, @point8)
    @touching_collinear_rising_seg = RGeo::Cartesian::Segment.new(@point1, @point8)
    @parallel_rising_seg = RGeo::Cartesian::Segment.new(@point6, @point7)
    @steep_rising_seg = RGeo::Cartesian::Segment.new(@point6, @point4)
    @degenerate_seg = RGeo::Cartesian::Segment.new(@point5, @point5)

    # sweepline tests
    @point9 = @factory.point(0, 0)
    @point10 = @factory.point(0, 1)
    @point11 = @factory.point(-0.5, 0.5)
    @point12 = @factory.point(0.5, 0.5)
    @point13 = @factory.point(0, 0.5)
    @point14 = @factory.point(0.5, 0.6)
    @point15 = @factory.point(0, 0.6)

    @li_seg1 = RGeo::Cartesian::Segment.new(@point9, @point10)
    @li_seg2 = RGeo::Cartesian::Segment.new(@point11, @point12)
    @li_seg3 = RGeo::Cartesian::Segment.new(@point12, @point13)
    @li_seg4 = RGeo::Cartesian::Segment.new(@point14, @point13)
    @li_seg5 = RGeo::Cartesian::Segment.new(@point14, @point15)
  end

  def assert_close_enough(v1, v2)
    diff = (v1 - v2).abs
    # denom = (v1 + v2).abs
    # diff /= denom if denom > 0.01
    assert(diff < 0.00000001, "#{v1} is not close to #{v2}")
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

  def test_segment_intersection_parallel
    assert_equal(@point5, @long_rising_seg.segment_intersection(@long_rising_seg))
    assert_nil(@long_rising_seg.segment_intersection(@parallel_rising_seg))
    assert_equal(@point1, @long_rising_seg.segment_intersection(@short_rising_seg))
    assert_equal(@point1, @touching_collinear_rising_seg.segment_intersection(@long_rising_seg))
  end

  def test_segment_intersection_basic
    int1 = @factory.point(1, 3)
    assert_equal(int1, @long_rising_seg.segment_intersection(@steep_rising_seg))

    int2 = @factory.point(0, 0.5)
    assert_equal(int2, @li_seg1.segment_intersection(@li_seg2))

    assert_nil(@short_rising_seg.segment_intersection(@steep_rising_seg))
  end

  def test_segment_intersection_endpoints
    assert_equal(@point1, @horiz_seg.segment_intersection(@vert_seg))
    assert_equal(@point1, @vert_seg.segment_intersection(@horiz_seg))
  end

  def test_segment_intersection_floating_point_miss
    poly = @factory.point(0, 0).buffer(1)
    poly.exterior_ring.segments.each_cons(2) do |seg1, seg2|
      assert_equal(seg1.e, seg1.segment_intersection(seg2))
    end
  end

  def test_sweepline_create_events
    segs = [@li_seg1, @li_seg2]
    li = RGeo::Cartesian::SweeplineIntersector.new(segs)

    assert_equal(4, li.events.size)
    events = li.events
    assert_equal(@point10, events[0].point)
    assert_equal(@point11, events[1].point)
    assert_equal(@point12, events[2].point)
    assert_equal(@point9, events[3].point)

    assert_equal(@li_seg1, events[0].segment)
    assert_equal(@li_seg2, events[1].segment)
    assert_equal(@li_seg2, events[2].segment)
    assert_equal(@li_seg1, events[3].segment)

    assert(events[0].is_start)
    assert(events[1].is_start)
    refute(events[2].is_start)
    refute(events[3].is_start)
  end

  def test_sweepline_intersections_crossing_lines
    segs1 = [@li_seg1, @li_seg2]
    li = RGeo::Cartesian::SweeplineIntersector.new(segs1)
    int_pt = @factory.point(0, 0.5)

    assert_equal(1, li.intersections.size)

    intersection = li.intersections.first
    expected = RGeo::Cartesian::SweeplineIntersector::Intersection.new(int_pt, @li_seg2, @li_seg1)
    assert_equal(expected, intersection)
  end

  def test_sweepline_intersections_converging_lines
    segs = [@li_seg1, @li_seg3, @li_seg4]
    li = RGeo::Cartesian::SweeplineIntersector.new(segs)
    int_pt = @factory.point(0, 0.5)

    assert_equal(3, li.intersections.size)
    li.intersections.each do |int|
      assert_equal(int_pt, int.point)
    end
  end

  def test_sweepline_intersections_crossing_lines_and_touching_line
    segs = [@li_seg1, @li_seg2, @li_seg5]
    li = RGeo::Cartesian::SweeplineIntersector.new(segs)
    int_pt1 = @factory.point(0, 0.6)
    int_pt2 = @factory.point(0, 0.5)

    assert_equal(2, li.intersections.size)

    expected1 = RGeo::Cartesian::SweeplineIntersector::Intersection.new(int_pt1, @li_seg5, @li_seg1)
    expected2 = RGeo::Cartesian::SweeplineIntersector::Intersection.new(int_pt2, @li_seg2, @li_seg1)
    assert_equal([expected1, expected2], li.intersections)
  end

  def test_sweepline_proper_intersections
    square_pts = [@factory.point(0, 0), @factory.point(0, 1), @factory.point(1, 1), @factory.point(1, 0), @factory.point(0, 0)]
    square = @factory.line_string(square_pts)

    hourglass_pts = [@factory.point(0, 0), @factory.point(0, 1), @factory.point(1, 0), @factory.point(1, 1), @factory.point(0, 0)]
    hourglass = @factory.line_string(hourglass_pts)

    square_li = RGeo::Cartesian::SweeplineIntersector.new(square.segments)
    assert_equal(0, square_li.proper_intersections.size)

    hourglass_li = RGeo::Cartesian::SweeplineIntersector.new(hourglass.segments)
    assert_equal(1, hourglass_li.proper_intersections.size)
    intersections = hourglass_li.proper_intersections
    assert_equal(@factory.point(0.5, 0.5), intersections.first.point)
  end
end
