# frozen_string_literal: true

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
      def xyz
        @xyz ||= SphericalMath::PointXYZ.from_latlon(@y, @x)
      end

      def distance(rhs)
        rhs = Feature.cast(rhs, @factory)
        case rhs
        when SphericalPointImpl
          xyz.dist_to_point(rhs.xyz) * SphericalMath::RADIUS
        else
          super
        end
      end

      def equals?(rhs)
        return false unless rhs.is_a?(self.class) && rhs.factory == factory
        case rhs
        when Feature::Point
          if @y == 90
            rhs.y == 90
          elsif @y == -90
            rhs.y == -90
          else
            rhs.x == @x && rhs.y == @y
          end
        when Feature::LineString
          rhs.num_points > 0 && rhs.points.all? { |elem| equals?(elem) }
        when Feature::GeometryCollection
          rhs.num_geometries > 0 && rhs.all? { |elem| equals?(elem) }
        else
          false
        end
      end

      def buffer(distance)
        radius = distance / SphericalMath::RADIUS
        radius = 1.5 if radius > 1.5
        cos = Math.cos(radius)
        sin = Math.sin(radius)
        point_count = factory.property(:buffer_resolution) * 4
        p0 = xyz
        p1 = p0.create_perpendicular
        p2 = p1 % p0
        angle = Math::PI * 2.0 / point_count
        points = (0...point_count).map do |i|
          r = angle * i
          pi = SphericalMath::PointXYZ.weighted_combination(p1, Math.cos(r), p2, Math.sin(r))
          p = SphericalMath::PointXYZ.weighted_combination(p0, cos, pi, sin)
          factory.point(*p.lonlat)
        end
        factory.polygon(factory.linear_ring(points))
      end

      def self.included(klass)
        klass.module_eval do
          alias_method :longitude, :x
          alias_method :lon, :x
          alias_method :latitude, :y
          alias_method :lat, :y
        end
      end

      private

      def validate_geometry
        if @x < -180.0 || @x > 180.0
          @x = @x % 360.0
          @x -= 360.0 if @x > 180.0
        end
        @y = 90.0 if @y > 90.0
        @y = -90.0 if @y < -90.0
        super
      end
    end

    module SphericalLineStringMethods # :nodoc:
      def arcs
        @arcs ||= (0..num_points - 2).map do |i|
          SphericalMath::ArcXYZ.new(point_n(i).xyz, point_n(i + 1).xyz)
        end
      end

      def is_simple?
        len = arcs.length
        return false if arcs.any?(&:degenerate?)
        return true if len == 1
        return arcs[0].s != arcs[1].e if len == 2
        arcs.each_with_index do |arc, index|
          nindex = index + 1
          nindex = nil if nindex == len
          return false if nindex && arc.contains_point?(arcs[nindex].e)
          pindex = index - 1
          pindex = nil if pindex < 0
          return false if pindex && arc.contains_point?(arcs[pindex].s)
          next unless nindex
          oindex = nindex + 1
          while oindex < len
            oarc = arcs[oindex]
            return false if !(index == 0 && oindex == len - 1 && arc.s == oarc.e) && arc.intersects_arc?(oarc)
            oindex += 1
          end
        end
        true
      end

      def length
        arcs.inject(0.0) { |sum, arc| sum + arc.length } * SphericalMath::RADIUS
      end
    end

    module SphericalMultiLineStringMethods # :nodoc:
      def length
        inject(0.0) { |sum, geom| sum + geom.length }
      end
    end
  end
end
