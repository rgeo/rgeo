# -----------------------------------------------------------------------------
#
# Cartesian feature classes
#
# -----------------------------------------------------------------------------

module RGeo
  module Cartesian
    class PointImpl # :nodoc:
      include ::RGeo::Feature::Point
      include ::RGeo::ImplHelper::BasicGeometryMethods
      include ::RGeo::ImplHelper::BasicPointMethods
      include ::RGeo::Cartesian::GeometryMethods
      include ::RGeo::Cartesian::PointMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Point).include_in_class(self, true)
    end

    class LineStringImpl # :nodoc:
      include ::RGeo::Feature::LineString
      include ::RGeo::ImplHelper::BasicGeometryMethods
      include ::RGeo::ImplHelper::BasicLineStringMethods
      include ::RGeo::Cartesian::GeometryMethods
      include ::RGeo::Cartesian::LineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::LineString).include_in_class(self, true)
    end

    class LineImpl # :nodoc:
      include ::RGeo::Feature::Line
      include ::RGeo::ImplHelper::BasicGeometryMethods
      include ::RGeo::ImplHelper::BasicLineStringMethods
      include ::RGeo::ImplHelper::BasicLineMethods
      include ::RGeo::Cartesian::GeometryMethods
      include ::RGeo::Cartesian::LineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Line).include_in_class(self, true)
    end

    class LinearRingImpl # :nodoc:
      include ::RGeo::Feature::LinearRing
      include ::RGeo::ImplHelper::BasicGeometryMethods
      include ::RGeo::ImplHelper::BasicLineStringMethods
      include ::RGeo::ImplHelper::BasicLinearRingMethods
      include ::RGeo::Cartesian::GeometryMethods
      include ::RGeo::Cartesian::LineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::LinearRing).include_in_class(self, true)
    end

    class PolygonImpl # :nodoc:
      include ::RGeo::Feature::Polygon
      include ::RGeo::ImplHelper::BasicGeometryMethods
      include ::RGeo::ImplHelper::BasicPolygonMethods
      include ::RGeo::Cartesian::GeometryMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Polygon).include_in_class(self, true)
    end

    class GeometryCollectionImpl # :nodoc:
      include ::RGeo::Feature::GeometryCollection
      include ::RGeo::ImplHelper::BasicGeometryMethods
      include ::RGeo::ImplHelper::BasicGeometryCollectionMethods
      include ::RGeo::Cartesian::GeometryMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::GeometryCollection).include_in_class(self, true)
    end

    class MultiPointImpl # :nodoc:
      include ::RGeo::Feature::MultiPoint
      include ::RGeo::ImplHelper::BasicGeometryMethods
      include ::RGeo::ImplHelper::BasicGeometryCollectionMethods
      include ::RGeo::ImplHelper::BasicMultiPointMethods
      include ::RGeo::Cartesian::GeometryMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPoint).include_in_class(self, true)
    end

    class MultiLineStringImpl # :nodoc:
      include ::RGeo::Feature::MultiLineString
      include ::RGeo::ImplHelper::BasicGeometryMethods
      include ::RGeo::ImplHelper::BasicGeometryCollectionMethods
      include ::RGeo::ImplHelper::BasicMultiLineStringMethods
      include ::RGeo::Cartesian::GeometryMethods
      include ::RGeo::Cartesian::MultiLineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiLineString).include_in_class(self, true)
    end

    class MultiPolygonImpl # :nodoc:
      include ::RGeo::Feature::MultiPolygon
      include ::RGeo::ImplHelper::BasicGeometryMethods
      include ::RGeo::ImplHelper::BasicGeometryCollectionMethods
      include ::RGeo::ImplHelper::BasicMultiPolygonMethods
      include ::RGeo::Cartesian::GeometryMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPolygon).include_in_class(self, true)
    end
  end
end
