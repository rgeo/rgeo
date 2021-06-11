# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Cartesian feature classes
#
# -----------------------------------------------------------------------------

module RGeo
  module Cartesian
    class PointImpl
      include Feature::Point
      include ImplHelper::ValidityCheck
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicPointMethods
      include GeometryMethods
      include PointMethods
    end

    class LineStringImpl
      include Feature::LineString
      include ImplHelper::ValidityCheck
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicLineStringMethods
      include GeometryMethods
      include LineStringMethods
    end

    class LineImpl
      include Feature::Line
      include ImplHelper::ValidityCheck
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicLineStringMethods
      include ImplHelper::BasicLineMethods
      include GeometryMethods
      include LineStringMethods
    end

    class LinearRingImpl
      include Feature::LinearRing
      include ImplHelper::ValidityCheck
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicLineStringMethods
      include ImplHelper::BasicLinearRingMethods
      include GeometryMethods
      include LineStringMethods
    end

    class PolygonImpl
      include Feature::Polygon
      include ImplHelper::ValidityCheck
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicPolygonMethods
      include GeometryMethods
    end

    class GeometryCollectionImpl
      include Feature::GeometryCollection
      include ImplHelper::ValidityCheck
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include GeometryMethods
    end

    class MultiPointImpl
      include Feature::MultiPoint
      include ImplHelper::ValidityCheck
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ImplHelper::BasicMultiPointMethods
      include GeometryMethods
    end

    class MultiLineStringImpl
      include Feature::MultiLineString
      include ImplHelper::ValidityCheck
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ImplHelper::BasicMultiLineStringMethods
      include GeometryMethods
      include MultiLineStringMethods
    end

    class MultiPolygonImpl
      include Feature::MultiPolygon
      include ImplHelper::ValidityCheck
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ImplHelper::BasicMultiPolygonMethods
      include GeometryMethods
    end

    ImplHelper::ValidityCheck.override_classes
  end
end
