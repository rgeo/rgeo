# frozen_string_literal: true

module RGeo
  module ImplHelper
    # Mixin based off of the JTS/GEOS IsValidOp class.
    # Implements #valid? and #invalid_reason on Features that include this.
    #
    # @see: https://github.com/locationtech/jts/blob/master/modules/core/src/main/java/org/locationtech/jts/operation/valid/IsValidOp.java
    module ValidOp
      # Standard error messages from
      # https://github.com/locationtech/jts/blob/0afbfb1956ec24912a8b4dc4edff0f1200442857/modules/core/src/main/java/org/locationtech/jts/operation/valid/TopologyValidationError.java#L98-L110
      ERROR_MSG = [
        "Topology Validation Error",
        "Repeated Point",
        "Hole lies outside shell",
        "Holes are nested",
        "Interior is disconnected",
        "Self-intersection",
        "Ring Self-intersection",
        "Nested shells",
        "Duplicate Rings",
        "Too few distinct points in geometry component",
        "Invalid Coordinate",
        "Ring is not closed"
      ].freeze

      # TODO: determine if "Unkown Validity" should count as valid.
      def valid?
        invalid_reason.nil?
      end
      alias is_valid? valid?

      def invalid_reason
        @invalid_reason ||= check_valid
      end

      private

      def check_valid
        case self
        when Feature::Point
          check_valid_point
        when Feature::LineString
          check_valid_line_string
        when Feature::LinearRing
          check_valid_linear_ring
        when Feature::Polygon
          check_valid_polygon
        when Feature::MultiPoint
          check_valid_multi_point
        when Feature::MultiPolygon
          check_valid_multi_polygon
        when Feature::GeometryCollection
          check_valid_geometry_collection
        else
          raise NotImplementedError, "check_valid is not implemented for #{self}"
        end
      rescue RGeo::Error::UnsupportedOperation, NoMethodError
        "Unkown Validity"
      end

      def check_valid_point
        check_invalid_coordinate(self)
      end

      def check_valid_line_string
        raise RGeo::Error::UnsupportedOperation, "#{__method__} is not yet implemented"
      end

      def check_valid_linear_ring
        raise RGeo::Error::UnsupportedOperation, "#{__method__} is not yet implemented"
      end

      def check_valid_polygon
        raise RGeo::Error::UnsupportedOperation, "#{__method__} is not yet implemented"
      end

      def check_valid_multi_point
        raise RGeo::Error::UnsupportedOperation, "#{__method__} is not yet implemented"
      end

      def check_valid_multi_polygon
        raise RGeo::Error::UnsupportedOperation, "#{__method__} is not yet implemented"
      end

      def check_valid_geometry_collection
        raise RGeo::Error::UnsupportedOperation, "#{__method__} is not yet implemented"
      end

      ##
      # Helper functions for specific validity checks
      ##

      def check_invalid_coordinate(pt)
        return unless pt.x.nan? || pt.x.infinite? || pt.y.nan? || pt.y.infinite?

        ERROR_MSG[10]
      end

      # TODO: Implement the rest of the validity checks
      # ...
    end
  end
end
