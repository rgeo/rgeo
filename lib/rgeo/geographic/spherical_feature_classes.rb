# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Spherical geographic feature classes
#
# -----------------------------------------------------------------------------

module RGeo
  module Geographic
    class SphericalPointImpl # :nodoc:
      include Feature::Point
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicPointMethods
      include SphericalGeometryMethods
      include SphericalPointMethods
    end

    class SphericalLineStringImpl # :nodoc:
      include Feature::LineString
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicLineStringMethods
      include SphericalGeometryMethods
      include SphericalLineStringMethods
    end

    class SphericalLineImpl # :nodoc:
      include Feature::Line
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicLineStringMethods
      include ImplHelper::BasicLineMethods
      include SphericalGeometryMethods
      include SphericalLineStringMethods
    end

    class SphericalLinearRingImpl # :nodoc:
      include Feature::LinearRing
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicLineStringMethods
      include ImplHelper::BasicLinearRingMethods
      include SphericalGeometryMethods
      include SphericalLineStringMethods
    end

    class SphericalPolygonImpl # :nodoc:
      include Feature::Polygon
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicPolygonMethods
      include SphericalGeometryMethods
    end

    class SphericalGeometryCollectionImpl # :nodoc:
      include Feature::GeometryCollection
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include SphericalGeometryMethods
    end

    class SphericalMultiPointImpl # :nodoc:
      include Feature::MultiPoint
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ImplHelper::BasicMultiPointMethods
      include SphericalGeometryMethods
    end

    class SphericalMultiLineStringImpl # :nodoc:
      include Feature::MultiLineString
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ImplHelper::BasicMultiLineStringMethods
      include SphericalGeometryMethods
      include SphericalMultiLineStringMethods
    end

    class SphericalMultiPolygonImpl # :nodoc:
      include Feature::MultiPolygon
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ImplHelper::BasicMultiPolygonMethods
      include SphericalGeometryMethods
    end
  end
end
