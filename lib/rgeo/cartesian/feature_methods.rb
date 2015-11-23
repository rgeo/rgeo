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
      def distance(rhs_)
        rhs_ = ::RGeo::Feature.cast(rhs_, @factory)
        case rhs_
        when PointImpl
          dx_ = @x - rhs_.x
          dy_ = @y - rhs_.y
          ::Math.sqrt(dx_ * dx_ + dy_ * dy_)
        else
          super
        end
      end

      def buffer(distance_)
        point_count_ = factory.property(:buffer_resolution) * 4
        angle_ = -::Math::PI * 2.0 / point_count_
        points_ = (0...point_count_).map do |i_|
          r_ = angle_ * i_
          factory.point(@x + distance_ * ::Math.cos(r_), @y + distance_ * ::Math.sin(r_))
        end
        factory.polygon(factory.linear_ring(points_))
      end
    end

    module LineStringMethods # :nodoc:
      def _segments
        unless defined?(@segments)
          @segments = (0..num_points - 2).map do |i_|
            Segment.new(point_n(i_), point_n(i_ + 1))
          end
        end
        @segments
      end

      def is_simple?
        segs_ = _segments
        len_ = segs_.length
        return false if segs_.any?(&:degenerate?)
        return true if len_ == 1
        return segs_[0].s != segs_[1].e if len_ == 2
        segs_.each_with_index do |seg_, index_|
          nindex_ = index_ + 1
          nindex_ = nil if nindex_ == len_
          return false if nindex_ && seg_.contains_point?(segs_[nindex_].e)
          pindex_ = index_ - 1
          pindex_ = nil if pindex_ < 0
          return false if pindex_ && seg_.contains_point?(segs_[pindex_].s)
          next unless nindex_
          oindex_ = nindex_ + 1
          while oindex_ < len_
            oseg_ = segs_[oindex_]
            return false if !(index_ == 0 && oindex_ == len_ - 1 && seg_.s == oseg_.e) && seg_.intersects_segment?(oseg_)
            oindex_ += 1
          end
        end
        true
      end

      def length
        _segments.inject(0.0) { |sum_, seg_| sum_ + seg_.length }
      end
    end

    module MultiLineStringMethods # :nodoc:
      def length
        inject(0.0) { |sum_, geom_| sum_ + geom_.length }
      end
    end
  end
end
