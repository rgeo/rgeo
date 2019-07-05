# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Projected geographic common method definitions
#
# -----------------------------------------------------------------------------

module RGeo
  module Geographic
    module ProjectedGeometryMethods # :nodoc:
      def srid
        factory.srid
      end

      def projection
        @projection = factory.project(self) unless defined?(@projection)
        @projection
      end

      def envelope
        factory.unproject(projection.envelope)
      end

      def is_empty?
        projection.is_empty?
      end

      def is_simple?
        projection.is_simple?
      end

      def boundary
        boundary = projection.boundary
        boundary ? factory.unproject(boundary) : nil
      end

      def equals?(rhs)
        projection.equals?(Feature.cast(rhs, factory).projection)
      end

      def disjoint?(rhs)
        projection.disjoint?(Feature.cast(rhs, factory).projection)
      end

      def intersects?(rhs)
        projection.intersects?(Feature.cast(rhs, factory).projection)
      end

      def touches?(rhs)
        projection.touches?(Feature.cast(rhs, factory).projection)
      end

      def crosses?(rhs)
        projection.crosses?(Feature.cast(rhs, factory).projection)
      end

      def within?(rhs)
        projection.within?(Feature.cast(rhs, factory).projection)
      end

      def contains?(rhs)
        projection.contains?(Feature.cast(rhs, factory).projection)
      end

      def overlaps?(rhs)
        projection.overlaps?(Feature.cast(rhs, factory).projection)
      end

      def relate(rhs, pattern_)
        projection.relate(Feature.cast(rhs, factory).projection, pattern_)
      end

      def distance(rhs)
        projection.distance(Feature.cast(rhs, factory).projection)
      end

      def buffer(distance)
        factory.unproject(projection.buffer(distance))
      end

      def buffer_with_style(distance, end_cap_style, join_style, mitre_limit)
        factory.unproject(projection.buffer_with_style(distance, end_cap_style, join_style, mitre_limit))
      end

      def simplify(tolerance)
        factory.unproject(projection.simplify(tolerance))
      end

      def simplify_preserve_topology(tolerance)
        factory.unproject(projection.simplify_preserve_topology(tolerance))
      end

      def convex_hull
        factory.unproject(projection.convex_hull)
      end

      def intersection(rhs)
        factory.unproject(projection.intersection(Feature.cast(rhs, factory).projection))
      end

      def union(rhs)
        factory.unproject(projection.union(Feature.cast(rhs, factory).projection))
      end

      def difference(rhs)
        factory.unproject(projection.difference(Feature.cast(rhs, factory).projection))
      end

      def sym_difference(rhs)
        factory.unproject(projection.sym_difference(Feature.cast(rhs, factory).projection))
      end

      def point_on_surface
        factory.unproject(projection.point_on_surface)
      end
    end

    module ProjectedPointMethods # :nodoc:
      def canonical_x
        x_ = @x % 360.0
        x_ -= 360.0 if x_ > 180.0
        x_
      end
      alias canonical_longitude canonical_x
      alias canonical_lon canonical_x

      def canonical_point
        if @x >= -180.0 && @x < 180.0
          self
        else
          ProjectedPointImpl.new(@factory, canonical_x, @y)
        end
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
        @y = 85.0511287 if @y > 85.0511287
        @y = -85.0511287 if @y < -85.0511287
        super
      end
    end

    module ProjectedNCurveMethods # :nodoc:
      def length
        projection.length
      end
    end

    module ProjectedLineStringMethods # :nodoc:
      private

      def validate_geometry
        @points = @points.map(&:canonical_point)
        super
      end
    end

    module ProjectedNSurfaceMethods # :nodoc:
      def area
        projection.area
      end

      def centroid
        factory.unproject(projection.centroid)
      end
    end

    module ProjectedPolygonMethods # :nodoc:
      private

      def validate_geometry
        super
        unless projection
          raise Error::InvalidGeometry, "Polygon failed assertions"
        end
      end
    end

    module ProjectedMultiPolygonMethods # :nodoc:
      private

      def validate_geometry
        super
        unless projection
          raise Error::InvalidGeometry, "MultiPolygon failed assertions"
        end
      end
    end
  end
end
