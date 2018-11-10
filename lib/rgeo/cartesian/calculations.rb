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
        s2 = seg.s
        # Handle degenerate cases
        if seg.degenerate?
          if @lensq == 0
            return @s == s2
          else
            return contains_point?(s2)
          end
        elsif @lensq == 0
          return seg.contains_point?(@s)
        end
        # Both segments have nonzero length.
        sx2 = s2.x
        sy2 = s2.y
        dx2 = seg.dx
        dy2 = seg.dy
        denom = @dx * dy2 - @dy * dx2
        if denom == 0
          # Segments are parallel. Make sure they are collinear.
          return false unless side(s2) == 0
          # 1-D check.
          ts = (@dx * (sx2 - @sx) + @dy * (sy2 - @sy)) / @lensq
          te = (@dx * (sx2 + dx2 - @sx) + @dy * (sy2 + dy2 - @sy)) / @lensq
          if ts < te
            te >= 0.0 && ts <= 1.0
          else
            ts >= 0.0 && te <= 1.0
          end
        else
          # Segments are not parallel. Check the intersection of their
          # containing lines.
          t = (dy2 * (sx2 - @sx) + dx2 * (@sy - sy2)) / denom
          return false if t < 0.0 || t > 1.0
          t2 = (@dy * (sx2 - @sx) + @dx * (@sy - sy2)) / denom
          t2 >= 0.0 && t2 <= 1.0
        end
      end

      def length
        Math.sqrt(@lensq)
      end
    end
  end
end
