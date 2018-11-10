# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Cartesian common methods
#
# -----------------------------------------------------------------------------

module RGeo
  module Cartesian
    module GeometryMethods # :nodoc:
      def srid
        factory.srid
      end

      def envelope
        BoundingBox.new(factory).add(self).to_geometry
      end
    end

    module PointMethods # :nodoc:
      def distance(rhs)
        rhs = RGeo::Feature.cast(rhs, @factory)
        case rhs
        when PointImpl
          dx = @x - rhs.x
          dy = @y - rhs.y
          Math.sqrt(dx * dx + dy * dy)
        else
          super
        end
      end

      def buffer(distance)
        point_count = factory.property(:buffer_resolution) * 4
        angle = -::Math::PI * 2.0 / point_count
        points = (0...point_count).map do |i|
          r = angle * i
          factory.point(@x + distance * Math.cos(r), @y + distance * Math.sin(r))
        end
        factory.polygon(factory.linear_ring(points))
      end
    end

    module LineStringMethods # :nodoc:
      def segments
        @segments ||= (0..num_points - 2).map do |i|
          Segment.new(point_n(i), point_n(i + 1))
        end
      end

      def is_simple?
        len = segments.length
        return false if segments.any?(&:degenerate?)
        return true if len == 1
        return segments[0].s != segments[1].e if len == 2
        segments.each_with_index do |seg, index|
          nindex = index + 1
          nindex = nil if nindex == len
          return false if nindex && seg.contains_point?(segments[nindex].e)
          pindex = index - 1
          pindex = nil if pindex < 0
          return false if pindex && seg.contains_point?(segments[pindex].s)
          next unless nindex
          oindex = nindex + 1
          while oindex < len
            oseg = segments[oindex]
            return false if !(index == 0 && oindex == len - 1 && seg.s == oseg.e) && seg.intersects_segment?(oseg)
            oindex += 1
          end
        end
        true
      end

      def length
        segments.inject(0.0) { |sum, seg| sum + seg.length }
      end
    end

    module MultiLineStringMethods # :nodoc:
      def length
        inject(0.0) { |sum, geom| sum + geom.length }
      end
    end
  end
end
