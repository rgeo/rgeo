# -----------------------------------------------------------------------------
#
# Spherical geographic common methods
#
# -----------------------------------------------------------------------------

module RGeo
  module Geographic
    module SphericalGeometryMethods # :nodoc:
      def srid
        factory.srid
      end
    end

    module SphericalPointMethods # :nodoc:
      def _validate_geometry
        if @x < -180.0 || @x > 180.0
          @x = @x % 360.0
          @x -= 360.0 if @x > 180.0
        end
        @y = 90.0 if @y > 90.0
        @y = -90.0 if @y < -90.0
        super
      end

      def _xyz
        @xyz ||= SphericalMath::PointXYZ.from_latlon(@y, @x)
      end

      def distance(rhs_)
        rhs_ = Feature.cast(rhs_, @factory)
        case rhs_
        when SphericalPointImpl
          _xyz.dist_to_point(rhs_._xyz) * SphericalMath::RADIUS
        else
          super
        end
      end

      def equals?(rhs_)
        return false unless rhs_.is_a?(self.class) && rhs_.factory == factory
        case rhs_
        when Feature::Point
          if @y == 90
            rhs_.y == 90
          elsif @y == -90
            rhs_.y == -90
          else
            rhs_.x == @x && rhs_.y == @y
          end
        when Feature::LineString
          rhs_.num_points > 0 && rhs_.points.all? { |elem_| equals?(elem_) }
        when Feature::GeometryCollection
          rhs_.num_geometries > 0 && rhs_.all? { |elem_| equals?(elem_) }
        else
          false
        end
      end

      def buffer(distance_)
        radius_ = distance_ / SphericalMath::RADIUS
        radius_ = 1.5 if radius_ > 1.5
        cos_ = ::Math.cos(radius_)
        sin_ = ::Math.sin(radius_)
        point_count_ = factory.property(:buffer_resolution) * 4
        p0_ = _xyz
        p1_ = p0_.create_perpendicular
        p2_ = p1_ % p0_
        angle_ = ::Math::PI * 2.0 / point_count_
        points_ = (0...point_count_).map do |i_|
          r_ = angle_ * i_
          pi_ = SphericalMath::PointXYZ.weighted_combination(p1_, ::Math.cos(r_), p2_, ::Math.sin(r_))
          p_ = SphericalMath::PointXYZ.weighted_combination(p0_, cos_, pi_, sin_)
          factory.point(*p_.lonlat)
        end
        factory.polygon(factory.linear_ring(points_))
      end

      def self.included(klass_)
        klass_.module_eval do
          alias_method :longitude, :x
          alias_method :lon, :x
          alias_method :latitude, :y
          alias_method :lat, :y
        end
      end
    end

    module SphericalLineStringMethods # :nodoc:
      def _arcs
        unless defined?(@arcs)
          @arcs = (0..num_points - 2).map do |i_|
            SphericalMath::ArcXYZ.new(point_n(i_)._xyz, point_n(i_ + 1)._xyz)
          end
        end
        @arcs
      end

      def is_simple?
        arcs_ = _arcs
        len_ = arcs_.length
        return false if arcs_.any?(&:degenerate?)
        return true if len_ == 1
        return arcs_[0].s != arcs_[1].e if len_ == 2
        arcs_.each_with_index do |arc_, index_|
          nindex_ = index_ + 1
          nindex_ = nil if nindex_ == len_
          return false if nindex_ && arc_.contains_point?(arcs_[nindex_].e)
          pindex_ = index_ - 1
          pindex_ = nil if pindex_ < 0
          return false if pindex_ && arc_.contains_point?(arcs_[pindex_].s)
          next unless nindex_
          oindex_ = nindex_ + 1
          while oindex_ < len_
            oarc_ = arcs_[oindex_]
            return false if !(index_ == 0 && oindex_ == len_ - 1 && arc_.s == oarc_.e) && arc_.intersects_arc?(oarc_)
            oindex_ += 1
          end
        end
        true
      end

      def length
        _arcs.inject(0.0) { |sum_, arc_| sum_ + arc_.length } * SphericalMath::RADIUS
      end
    end

    module SphericalMultiLineStringMethods # :nodoc:
      def length
        inject(0.0) { |sum_, geom_| sum_ + geom_.length }
      end
    end
  end
end
