# -----------------------------------------------------------------------------
#
# Core calculations in the plane
#
# -----------------------------------------------------------------------------

module RGeo
  module Cartesian
    # Represents a line segment in the plane.

    class Segment # :nodoc:
      def initialize(start_, end_)
        @s = start_
        @e = end_
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

      def eql?(rhs_)
        rhs_.is_a?(Segment) && @s == rhs_.s && @e == rhs_.e
      end
      alias_method :==, :eql?

      def degenerate?
        @lensq == 0
      end

      # Returns a negative value if the point is to the left,
      # a positive value if the point is to the right, or
      # 0 if the point is collinear to the segment.

      def side(p_)
        px_ = p_.x
        py_ = p_.y
        (@sx - px_) * (@ey - py_) - (@sy - py_) * (@ex - px_)
      end

      def tproj(p_)
        if @lensq == 0
          nil
        else
          (@dx * (p_.x - @sx) + @dy * (p_.y - @sy)) / @lensq
        end
      end

      def contains_point?(p_)
        if side(p_) == 0
          t_ = tproj(p_)
          t_ && t_ >= 0.0 && t_ <= 1.0
        else
          false
        end
      end

      def intersects_segment?(seg_)
        s2_ = seg_.s
        # Handle degenerate cases
        if seg_.degenerate?
          if @lensq == 0
            return @s == s2_
          else
            return contains_point?(s2_)
          end
        elsif @lensq == 0
          return seg_.contains_point?(@s)
        end
        # Both segments have nonzero length.
        sx2_ = s2_.x
        sy2_ = s2_.y
        dx2_ = seg_.dx
        dy2_ = seg_.dy
        denom_ = @dx * dy2_ - @dy * dx2_
        if denom_ == 0
          # Segments are parallel. Make sure they are collinear.
          return false unless side(s2_) == 0
          # 1-D check.
          ts_ = (@dx * (sx2_ - @sx) + @dy * (sy2_ - @sy)) / @lensq
          te_ = (@dx * (sx2_ + dx2_ - @sx) + @dy * (sy2_ + dy2_ - @sy)) / @lensq
          if ts_ < te_
            te_ >= 0.0 && ts_ <= 1.0
          else
            ts_ >= 0.0 && te_ <= 1.0
          end
        else
          # Segments are not parallel. Check the intersection of their
          # containing lines.
          t_ = (dy2_ * (sx2_ - @sx) + dx2_ * (@sy - sy2_)) / denom_
          return false if t_ < 0.0 || t_ > 1.0
          t2_ = (@dy * (sx2_ - @sx) + @dx * (@sy - sy2_)) / denom_
          t2_ >= 0.0 && t2_ <= 1.0
        end
      end

      def length
        ::Math.sqrt(@lensq)
      end
    end
  end
end
