# -----------------------------------------------------------------------------
#
# Projtected geographic feature classes
#
# -----------------------------------------------------------------------------

module RGeo
  module Geographic
    class ProjectedPointImpl # :nodoc:
      include Feature::Point
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicPointMethods
      include ProjectedGeometryMethods
      include ProjectedPointMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Point).include_in_class(self, true)
    end

    class ProjectedLineStringImpl  # :nodoc:
      include Feature::LineString
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicLineStringMethods
      include ProjectedGeometryMethods
      include ProjectedNCurveMethods
      include ProjectedLineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::LineString).include_in_class(self, true)
    end

    class ProjectedLinearRingImpl  # :nodoc:
      include Feature::LinearRing
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicLineStringMethods
      include ImplHelper::BasicLinearRingMethods
      include ProjectedGeometryMethods
      include ProjectedNCurveMethods
      include ProjectedLineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::LinearRing).include_in_class(self, true)
    end

    class ProjectedLineImpl # :nodoc:
      include Feature::Line
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicLineStringMethods
      include ImplHelper::BasicLineMethods
      include ProjectedGeometryMethods
      include ProjectedNCurveMethods
      include ProjectedLineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Line).include_in_class(self, true)
    end

    class ProjectedPolygonImpl # :nodoc:
      include Feature::Polygon
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicPolygonMethods
      include ProjectedGeometryMethods
      include ProjectedNSurfaceMethods
      include ProjectedPolygonMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Polygon).include_in_class(self, true)
    end

    class ProjectedGeometryCollectionImpl # :nodoc:
      include Feature::GeometryCollection
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ProjectedGeometryMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::GeometryCollection).include_in_class(self, true)
    end

    class ProjectedMultiPointImpl # :nodoc:
      include Feature::MultiPoint
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ImplHelper::BasicMultiPointMethods
      include ProjectedGeometryMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPoint).include_in_class(self, true)
    end

    class ProjectedMultiLineStringImpl # :nodoc:
      include Feature::MultiLineString
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ImplHelper::BasicMultiLineStringMethods
      include ProjectedGeometryMethods
      include ProjectedNCurveMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiLineString).include_in_class(self, true)
    end

    class ProjectedMultiPolygonImpl # :nodoc:
      include Feature::MultiPolygon
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ImplHelper::BasicMultiPolygonMethods
      include ProjectedGeometryMethods
      include ProjectedNSurfaceMethods
      include ProjectedMultiPolygonMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPolygon).include_in_class(self, true)
    end
  end
end
