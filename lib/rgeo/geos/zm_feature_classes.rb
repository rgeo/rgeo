# -----------------------------------------------------------------------------
#
# GEOS implementation additions written in Ruby
#
# -----------------------------------------------------------------------------

module RGeo
  module Geos
    class ZMPointImpl # :nodoc:
      include ZMGeometryMethods
      include ZMPointMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Point).include_in_class(self, true)
    end

    class ZMLineStringImpl  # :nodoc:
      include ZMGeometryMethods
      include ZMLineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::LineString).include_in_class(self, true)
    end

    class ZMLinearRingImpl  # :nodoc:
      include ZMGeometryMethods
      include ZMLineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::LinearRing).include_in_class(self, true)
    end

    class ZMLineImpl # :nodoc:
      include ZMGeometryMethods
      include ZMLineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Line).include_in_class(self, true)
    end

    class ZMPolygonImpl # :nodoc:
      include ZMGeometryMethods
      include ZMPolygonMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Polygon).include_in_class(self, true)
    end

    class ZMGeometryCollectionImpl # :nodoc:
      include ZMGeometryMethods
      include ZMGeometryCollectionMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::GeometryCollection).include_in_class(self, true)
    end

    class ZMMultiPointImpl # :nodoc:
      include ZMGeometryMethods
      include ZMGeometryCollectionMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPoint).include_in_class(self, true)
    end

    class ZMMultiLineStringImpl # :nodoc:
      include ZMGeometryMethods
      include ZMGeometryCollectionMethods
      include ZMMultiLineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiLineString).include_in_class(self, true)
    end

    class ZMMultiPolygonImpl # :nodoc:
      include ZMGeometryMethods
      include ZMGeometryCollectionMethods
      include ZMMultiPolygonMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPolygon).include_in_class(self, true)
    end

    class ZMGeometryImpl # :nodoc:
      include ZMGeometryMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Geometry).include_in_class(self, true)
    end
  end
end
