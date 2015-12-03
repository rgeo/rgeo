# -----------------------------------------------------------------------------
#
# FFI-GEOS geometry implementation
#
# -----------------------------------------------------------------------------

module RGeo
  module Geos
    class FFIGeometryImpl # :nodoc:
      include FFIGeometryMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Geometry).include_in_class(self, true)
    end

    class FFIPointImpl # :nodoc:
      include FFIGeometryMethods
      include FFIPointMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Point).include_in_class(self, true)
    end

    class FFILineStringImpl  # :nodoc:
      include FFIGeometryMethods
      include FFILineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::LineString).include_in_class(self, true)
    end

    class FFILinearRingImpl  # :nodoc:
      include FFIGeometryMethods
      include FFILineStringMethods
      include FFILinearRingMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::LinearRing).include_in_class(self, true)
    end

    class FFILineImpl # :nodoc:
      include FFIGeometryMethods
      include FFILineStringMethods
      include FFILineMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Line).include_in_class(self, true)
    end

    class FFIPolygonImpl # :nodoc:
      include FFIGeometryMethods
      include FFIPolygonMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Polygon).include_in_class(self, true)
    end

    class FFIGeometryCollectionImpl # :nodoc:
      include FFIGeometryMethods
      include FFIGeometryCollectionMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::GeometryCollection).include_in_class(self, true)
    end

    class FFIMultiPointImpl # :nodoc:
      include FFIGeometryMethods
      include FFIGeometryCollectionMethods
      include FFIMultiPointMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPoint).include_in_class(self, true)
    end

    class FFIMultiLineStringImpl # :nodoc:
      include FFIGeometryMethods
      include FFIGeometryCollectionMethods
      include FFIMultiLineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiLineString).include_in_class(self, true)
    end

    class FFIMultiPolygonImpl # :nodoc:
      include FFIGeometryMethods
      include FFIGeometryCollectionMethods
      include FFIMultiPolygonMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPolygon).include_in_class(self, true)
    end
  end
end
