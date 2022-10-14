# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the Sweepline Intersector
#
# -----------------------------------------------------------------------------

class SweeplineIntersectorTest < Minitest::Test
  def setup
    @factory = RGeo::Cartesian.simple_factory

    @point1 = @factory.point(0, 0)
    @point2 = @factory.point(0, 1)
    @point3 = @factory.point(-0.5, 0.5)
    @point4 = @factory.point(0.5, 0.5)
    @point5 = @factory.point(0, 0.5)
    @point6 = @factory.point(0.5, 0.6)
    @point7 = @factory.point(0, 0.6)

    @li_seg1 = RGeo::Cartesian::Segment.new(@point1, @point2)
    @li_seg2 = RGeo::Cartesian::Segment.new(@point3, @point4)
    @li_seg3 = RGeo::Cartesian::Segment.new(@point4, @point5)
    @li_seg4 = RGeo::Cartesian::Segment.new(@point6, @point5)
    @li_seg5 = RGeo::Cartesian::Segment.new(@point6, @point7)
  end

  def test_sweepline_create_events
    segs = [@li_seg1, @li_seg2]
    li = RGeo::Cartesian::SweeplineIntersector.new(segs)

    assert_equal(4, li.events.size)
    events = li.events
    assert_equal(@point2, events[0].point)
    assert_equal(@point3, events[1].point)
    assert_equal(@point4, events[2].point)
    assert_equal(@point1, events[3].point)

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
    square_pts = [
      @factory.point(0, 0),
      @factory.point(0, 1),
      @factory.point(1, 1),
      @factory.point(1, 0),
      @factory.point(0, 0)
    ]
    square = @factory.line_string(square_pts)

    hourglass_pts = [
      @factory.point(0, 0),
      @factory.point(0, 1),
      @factory.point(1, 0),
      @factory.point(1, 1),
      @factory.point(0, 0)
    ]
    hourglass = @factory.line_string(hourglass_pts)

    square_li = RGeo::Cartesian::SweeplineIntersector.new(square.segments)
    assert_equal(0, square_li.proper_intersections.size)

    hourglass_li = RGeo::Cartesian::SweeplineIntersector.new(hourglass.segments)
    assert_equal(1, hourglass_li.proper_intersections.size)
    intersections = hourglass_li.proper_intersections
    assert_equal(@factory.point(0.5, 0.5), intersections.first.point)
  end
end
