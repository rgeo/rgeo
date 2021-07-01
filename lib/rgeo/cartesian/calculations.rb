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

            # Check if this segment contains the point.
            # Sometimes round-off errors occur and intersections
            # are recorded as off the line segments.
            #
            # If this is the case, return the closest point from
            # either segment.
            int_pt = @s.factory.point(x, y)
            if contains_point?(int_pt)
              int_pt
            else
              # find closest of @s, @e, seg.s, seg.e
              [@e, seg.s, seg.e].reduce(@s) do |closest, pt|
                int_pt.distance(pt) < int_pt.distance(closest) ? pt : closest
              end
            end
          end
        end
      end

      def length
        Math.sqrt(@lensq)
      end
    end
  end
end
