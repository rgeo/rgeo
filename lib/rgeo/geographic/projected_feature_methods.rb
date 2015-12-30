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
        boundary_ = projection.boundary
        boundary_ ? factory.unproject(boundary_) : nil
      end

      def equals?(rhs_)
        projection.equals?(Feature.cast(rhs_, factory).projection)
      end

      def disjoint?(rhs_)
        projection.disjoint?(Feature.cast(rhs_, factory).projection)
      end

      def intersects?(rhs_)
        projection.intersects?(Feature.cast(rhs_, factory).projection)
      end

      def touches?(rhs_)
        projection.touches?(Feature.cast(rhs_, factory).projection)
      end

      def crosses?(rhs_)
        projection.crosses?(Feature.cast(rhs_, factory).projection)
      end

      def within?(rhs_)
        projection.within?(Feature.cast(rhs_, factory).projection)
      end

      def contains?(rhs_)
        projection.contains?(Feature.cast(rhs_, factory).projection)
      end

      def overlaps?(rhs_)
        projection.overlaps?(Feature.cast(rhs_, factory).projection)
      end

      def relate(rhs_, pattern_)
        projection.relate(Feature.cast(rhs_, factory).projection, pattern_)
      end

      def distance(rhs_)
        projection.distance(Feature.cast(rhs_, factory).projection)
      end

      def buffer(distance_)
        factory.unproject(projection.buffer(distance_))
      end

      def buffer_with_style(distance_, endCapStyle_, joinStyle_, mitreLimit_)
        factory.unproject(projection.buffer_with_style(distance_, endCapStyle_, joinStyle_, mitreLimit_))
      end

      def simplify(tolerance_)
        factory.unproject(projection.simplify(tolerance_))
      end

      def simplify_preserve_topology(tolerance_)
        factory.unproject(projection.simplify_preserve_topology(tolerance_))
      end

      def convex_hull
        factory.unproject(projection.convex_hull)
      end

      def intersection(rhs_)
        factory.unproject(projection.intersection(Feature.cast(rhs_, factory).projection))
      end

      def union(rhs_)
        factory.unproject(projection.union(Feature.cast(rhs_, factory).projection))
      end

      def difference(rhs_)
        factory.unproject(projection.difference(Feature.cast(rhs_, factory).projection))
      end

      def sym_difference(rhs_)
        factory.unproject(projection.sym_difference(Feature.cast(rhs_, factory).projection))
      end
    end

    module ProjectedPointMethods # :nodoc:
      def _validate_geometry
        @y = 85.0511287 if @y > 85.0511287
        @y = -85.0511287 if @y < -85.0511287
        super
      end

      def canonical_x
        x_ = @x % 360.0
        x_ -= 360.0 if x_ > 180.0
        x_
      end
      alias_method :canonical_longitude, :canonical_x
      alias_method :canonical_lon, :canonical_x

      def canonical_point
        if @x >= -180.0 && @x < 180.0
          self
        else
          PointImpl.new(@factory, canonical_x, @y)
        end
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

    module ProjectedNCurveMethods # :nodoc:
      def length
        projection.length
      end
    end

    module ProjectedLineStringMethods # :nodoc:
      def _validate_geometry
        size_ = @points.size
        if size_ > 1
          last_ = @points[0]
          (1...size_).each do |i_|
            p_ = @points[i_]
            last_x_ = last_.x
            p_x_ = p_.x
            changed_ = true
            if p_x_ < last_x_ - 180.0
              p_x_ += 360.0 while p_x_ < last_x_ - 180.0
            elsif p_x_ > last_x_ + 180.0
              p_x_ -= 360.0 while p_x_ > last_x_ + 180.0
            else
              changed_ = false
            end
            if changed_
              p_ = factory.point(p_x_, p_.y)
              @points[i_] = p_
            end
            last_ = p_
          end
        end
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

      def point_on_surface
        factory.unproject(projection.point_on_surface)
      end
    end

    module ProjectedPolygonMethods # :nodoc:
      def _validate_geometry
        super
        unless projection
          raise Error::InvalidGeometry, "Polygon failed assertions"
        end
      end
    end

    module ProjectedMultiPolygonMethods # :nodoc:
      def _validate_geometry
        super
        unless projection
          raise Error::InvalidGeometry, "MultiPolygon failed assertions"
        end
      end
    end
  end
end
