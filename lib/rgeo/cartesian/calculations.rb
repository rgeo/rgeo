# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Core calculations in the plane
#
# -----------------------------------------------------------------------------

module RGeo
  module Cartesian
    # Represents a line segment in the plane.

    class Segment # :nodoc:
      def initialize(start, stop)
        @s = start
        @e = stop
        @sx = @s.x
        @sy = @s.y
        @ex = @e.x
        @ey = @e.y
        @dx = @ex - @sx
        @dy = @ey - @sy
        @lensq = @dx * @dx + @dy * @dy
      end

      attr_reader :s
      attr_reader :e
      attr_reader :dx
      attr_reader :dy

      def to_s
        "#{@s} - #{@e}"
      end

      def eql?(rhs)
        rhs.is_a?(Segment) && @s == rhs.s && @e == rhs.e
      end
      alias == eql?

      def degenerate?
        @lensq == 0
      end

      # Returns a negative value if the point is to the left,
      # a positive value if the point is to the right, or
      # 0 if the point is collinear to the segment.

      def side(p)
        px = p.x
        py = p.y
        (@sx - px) * (@ey - py) - (@sy - py) * (@ex - px)
      end

      def tproj(p)
        if @lensq == 0
          nil
        else
          (@dx * (p.x - @sx) + @dy * (p.y - @sy)) / @lensq
        end
      end

      def contains_point?(p)
        if side(p) == 0
          t = tproj(p)
          t && t >= 0.0 && t <= 1.0
        else
          false
        end
      end

      def intersects_segment?(seg)
        !segment_intersection(seg).nil?
      end

      # If this and the other segment intersect, this method will return the coordinate
      # at which they intersect, otherwise nil.
      # In the case of a partial overlap (parallel segments), this will return
      # a single point on the overlapping portion.
      #
      # @param seg [Segment]
      #
      # @return [RGeo::Feature::Point, nil]
      def segment_intersection(seg)
        s2 = seg.s
        # Handle degenerate cases
        if seg.degenerate?
          if @lensq == 0 && @s == s2
            return @s
          else
            return contains_point?(s2) ? s2 : nil
          end
        elsif @lensq == 0
          return seg.contains_point?(@s) ? @s : nil
        end

        # Both segments have nonzero length.
        sx2 = s2.x
        sy2 = s2.y
        dx2 = seg.dx
        dy2 = seg.dy
        denom = @dx * dy2 - @dy * dx2

        if denom == 0
          # Segments are parallel. Make sure they are collinear.
          return nil unless side(s2) == 0

          # return the first point it finds that intersects another line.
          # In many cases, the intersection is actually another line
          # segment, but for now, we will just return a single point.
          return s2 if contains_point?(s2)
          return seg.e if contains_point?(seg.e)
          return @s if seg.contains_point?(@s)
          return @e if seg.contains_point?(@e)
          nil
        else
          # Segments are not parallel. Check the intersection of their
          # containing lines.
          num1 = dx2 * (@sy - sy2) - (dy2 * (@sx - sx2))
          num2 = @dx * (@sy - sy2) - (@dy * (@sx - sx2))
          cross1 = num1 / denom
          cross2 = num2 / denom

          return nil if cross1 < 0.0 || cross1 > 1.0
          if cross2 >= 0.0 && cross2 <= 1.0
            x = @sx + (cross1 * @dx)
            y = @sy + (cross1 * @dy)

            @s.factory.point(x, y)
          end
        end
      end

      def length
        Math.sqrt(@lensq)
      end
    end

    # Implements a Sweepline intersector to find all intersections
    # in a group of segments. The idea is to use a horizontal line starting
    # at y = +Infinity that sweeps down to y = -Infinity and every time it hits
    # a new line, it will check if it intersects with any of the segments
    # the line currently intersects at that y value.
    # This is a more simplistic implementation that uses an array to hold
    # observed segments instead of a sorted BST, so performance may be significantly
    # worse in the case of lots of segments overlapping in y-ranges.
    class SweeplineIntersector
      Event = Struct.new(:point, :segment, :is_start)
      Intersection = Struct.new(:point, :s1, :s2)

      def initialize(segments)
        @segments = segments
        @events = []
        @intersections = []
        @proper_intersections = []
      end
      attr_reader :segments

      # Returns the "proper" intersections from the list of segments.
      #
      # This will only return intersections that are not the start/end or 
      # end/start of the 2 segments. This could be useful for finding intersections
      # in a ring for example, because knowing that segments are connected in a linestring
      # is not always helpful, but those are reported by default.
      #
      # Note: This is not the true definition of a proper intersection. A
      # truly proper intersection does not include colinear intersections and
      # the intersection must lie in the interior of both segments.
      #
      # @return [Array<RGeo::Cartesian::SweeplineIntersector::Intersection>]
      def proper_intersections
        return @proper_intersections if @proper_intersections.size.positive?

        intersections.each do |intersection|
          s1 = intersection.s1
          s2 = intersection.s2
          pt = intersection.point

          unless (pt == s1.s && pt == s2.e) || (pt == s1.e && pt == s2.s)
            @proper_intersections << intersection
          end
        end
        @proper_intersections
      end

      # Computes the intersections of the input segments.
      #
      # Creates an event queue from the +events+ and adds segments to the
      # +observed_segments+ array while their ending event has not been popped
      # from the queue.
      #
      # Compares the new segment from the +is_start+ event to each observed segment
      # then adds it to +observed_segments+. Records any intersections in to the
      # returned array.
      #
      # @return [Array<RGeo::Cartesian::SweeplineIntersector::Intersection>]
      def intersections
        return @intersections if @intersections.size.positive?

        observed_segments = []
        eq = Queue.new
        events.each { |e| eq.push(e) }

        until eq.empty?
          e = eq.pop
          seg = e.segment

          if e.is_start
            observed_segments.each do |oseg|
              int_pt = seg.segment_intersection(oseg)
              if int_pt
                intersect = Intersection.new(int_pt, seg, oseg)
                @intersections << intersect
              end
            end
            observed_segments << seg
          else
            observed_segments.delete_if { |oseg| oseg == seg }
          end
        end
        @intersections
      end

      # Returns an ordered array of events from the input segments. Events
      # are the start and endpoints of each segment with an is_start tag to
      # indicate if this is the starting or ending event for that segment.
      #
      # Ordering is done by greatest-y -> smallest-x -> is_start = true.
      #
      # @return [Array]
      def events
        return @events if @events.size.positive?

        segments.each do |segment|
          event_pair = create_event_pair(segment)
          @events.concat(event_pair)
        end

        @events.sort! do |a, b|
          if a.point == b.point
            if a.is_start
              -1
            else
              1
            end
          elsif a.point.y == b.point.y
            a.point.x <=> b.point.x
          else
            b.point.y <=> a.point.y
          end
        end
        @events
      end

      private

      # Creates a pair of events from a segment
      #
      # @param segment [Segment]
      #
      # @return [Array]
      def create_event_pair(segment)
        s = segment.s
        e = segment.e

        s_event = Event.new(s, segment)
        e_event = Event.new(e, segment)

        if s.y > e.y
          s_event.is_start = true
          e_event.is_start = false
        elsif s.y < e.y
          s_event.is_start = false
          e_event.is_start = true
        elsif s.x < e.x
          s_event.is_start = true
          e_event.is_start = false
        elsif s.x > e.x
          s_event.is_start = false
          e_event.is_start = true
        else
          # degenerate case, should probably never happen
          s_event.is_start = true
          e_event.is_start = false
        end

        [s_event, e_event]
      end
    end
  end
end
