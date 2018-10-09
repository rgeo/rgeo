# -----------------------------------------------------------------------------
#
# Cartesian geometric analysis utilities
#
# -----------------------------------------------------------------------------

module RGeo
  module Cartesian
    # This provides includes some spatial analysis algorithms supporting
    # Cartesian data.

    module Analysis
      class << self
        # Given a LineString, which must be a ring, determine whether the
        # ring proceeds clockwise or counterclockwise.
        # Returns 1 for counterclockwise, or -1 for clockwise.
        #
        # Returns 0 if the ring is empty.
        # The return value is undefined if the object is not a ring, or
        # is not in a Cartesian coordinate system.

        def ring_direction(ring_)
          size_ = ring_.num_points - 1
          return 0 if size_ == 0

          # Extract unit-length segments from the ring.
          segs_ = []
          size_.times do |i_|
            p0_ = ring_.point_n(i_)
            p1_ = ring_.point_n(i_ + 1)
            x_ = p1_.x - p0_.x
            y_ = p1_.y - p0_.y
            r_ = ::Math.sqrt(x_ * x_ + y_ * y_)
            if r_ > 0.0
              segs_ << x_ / r_ << y_ / r_
            else
              size_ -= 1
            end
          end
          segs_ << segs_[0] << segs_[1]

          # Extract angles from the segments by subtracting the segments.
          # Note angles are represented as cos/sin pairs so we don't
          # have to calculate any trig functions.
          angs_ = []
          size_.times do |i_|
            x0_, y0_, x1_, y1_ = segs_[i_ * 2, 4]
            angs_ << x0_ * x1_ + y0_ * y1_ << x0_ * y1_ - x1_ * y0_
          end

          # Now add the angles and count revolutions.
          # Again, our running sum is represented as a cos/sin pair.
          revolutions = 0
          direction = nil
          sin = 0.0
          cos = 1.0
          angs_.each_slice(2) do |(x, y)|
            ready = y > 0.0 && (sin > 0.0 || sin == 0.0 && direction == -1) || y < 0.0 && (sin < 0.0 || sin == 0.0 && direction == 1)
            if y != 0.0
              s = sin * x + cos * y
              c = cos * x - sin * y
              r = ::Math.sqrt(s * s + c * c)
              sin = s / r
              cos = c / r
            end
            next unless ready
            if y > 0.0 && sin <= 0.0
              revolutions += 1
              direction = 1
            elsif y < 0.0 && sin >= 0.0
              revolutions -= 1
              direction = -1
            end
          end
          revolutions
        end
      end
    end
  end
end
