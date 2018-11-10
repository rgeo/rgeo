# frozen_string_literal: true

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

        def ring_direction(ring)
          size = ring.num_points - 1
          return 0 if size == 0

          # Extract unit-length segments from the ring.
          segs = []
          size.times do |i|
            p0 = ring.point_n(i)
            p1 = ring.point_n(i + 1)
            x = p1.x - p0.x
            y = p1.y - p0.y
            r = Math.sqrt(x * x + y * y)
            if r > 0.0
              segs << x / r << y / r
            else
              size -= 1
            end
          end
          segs << segs[0] << segs[1]

          # Extract angles from the segments by subtracting the segments.
          # Note angles are represented as cos/sin pairs so we don't
          # have to calculate any trig functions.
          angs = []
          size.times do |i|
            x0, y0, x1, y1 = segs[i * 2, 4]
            angs << x0 * x1 + y0 * y1 << x0 * y1 - x1 * y0
          end

          # Now add the angles and count revolutions.
          # Again, our running sum is represented as a cos/sin pair.
          revolutions = 0
          direction = nil
          sin = 0.0
          cos = 1.0
          angs.each_slice(2) do |(x, y)|
            ready = y > 0.0 && (sin > 0.0 || sin == 0.0 && direction == -1) || y < 0.0 && (sin < 0.0 || sin == 0.0 && direction == 1)
            if y != 0.0
              s = sin * x + cos * y
              c = cos * x - sin * y
              r = Math.sqrt(s * s + c * c)
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
