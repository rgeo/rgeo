# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Cartesian feature classes
#
# -----------------------------------------------------------------------------

module RGeo
  module Cartesian
    class PointImpl # :nodoc:
      include RGeo::Feature::Point
      include RGeo::ImplHelper::BasicGeometryMethods
      include RGeo::ImplHelper::BasicPointMethods
      include RGeo::ImplHelper::ValidOp
      include RGeo::Cartesian::GeometryMethods
      include RGeo::Cartesian::PointMethods
    end

    class LineStringImpl # :nodoc:
      include RGeo::Feature::LineString
      include RGeo::ImplHelper::BasicGeometryMethods
      include RGeo::ImplHelper::BasicLineStringMethods
      include RGeo::ImplHelper::ValidOp
      include RGeo::Cartesian::GeometryMethods
      include RGeo::Cartesian::LineStringMethods
    end

    class LineImpl # :nodoc:
      include RGeo::Feature::Line
      include RGeo::ImplHelper::BasicGeometryMethods
      include RGeo::ImplHelper::BasicLineStringMethods
      include RGeo::ImplHelper::BasicLineMethods
      include RGeo::ImplHelper::ValidOp
      include RGeo::Cartesian::GeometryMethods
      include RGeo::Cartesian::LineStringMethods
    end

    class LinearRingImpl # :nodoc:
      include RGeo::Feature::LinearRing
      include RGeo::ImplHelper::BasicGeometryMethods
      include RGeo::ImplHelper::BasicLineStringMethods
      include RGeo::ImplHelper::BasicLinearRingMethods
      include RGeo::ImplHelper::ValidOp
      include RGeo::Cartesian::GeometryMethods
      include RGeo::Cartesian::LineStringMethods
    end

    class PolygonImpl # :nodoc:
      include RGeo::Feature::Polygon
      include RGeo::ImplHelper::BasicGeometryMethods
      include RGeo::ImplHelper::BasicPolygonMethods
      include RGeo::ImplHelper::ValidOp
      include RGeo::Cartesian::GeometryMethods
    end

    class GeometryCollectionImpl # :nodoc:
      include RGeo::Feature::GeometryCollection
      include RGeo::ImplHelper::BasicGeometryMethods
      include RGeo::ImplHelper::BasicGeometryCollectionMethods
      include RGeo::ImplHelper::ValidOp
      include RGeo::Cartesian::GeometryMethods
    end

    class MultiPointImpl # :nodoc:
      include RGeo::Feature::MultiPoint
      include RGeo::ImplHelper::BasicGeometryMethods
      include RGeo::ImplHelper::BasicGeometryCollectionMethods
      include RGeo::ImplHelper::BasicMultiPointMethods
      include RGeo::ImplHelper::ValidOp
      include RGeo::Cartesian::GeometryMethods
    end

    class MultiLineStringImpl # :nodoc:
      include RGeo::Feature::MultiLineString
      include RGeo::ImplHelper::BasicGeometryMethods
      include RGeo::ImplHelper::BasicGeometryCollectionMethods
      include RGeo::ImplHelper::BasicMultiLineStringMethods
      include RGeo::ImplHelper::ValidOp
      include RGeo::Cartesian::GeometryMethods
      include RGeo::Cartesian::MultiLineStringMethods
    end

    class MultiPolygonImpl # :nodoc:
      include RGeo::Feature::MultiPolygon
      include RGeo::ImplHelper::BasicGeometryMethods
      include RGeo::ImplHelper::BasicGeometryCollectionMethods
      include RGeo::ImplHelper::BasicMultiPolygonMethods
      include RGeo::ImplHelper::ValidOp
      include RGeo::Cartesian::GeometryMethods
    end
  end
end
