# frozen_string_literal: true

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
    end

    class ProjectedLineStringImpl  # :nodoc:
      include Feature::LineString
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicLineStringMethods
      include ProjectedGeometryMethods
      include ProjectedNCurveMethods
      include ProjectedLineStringMethods
    end

    class ProjectedLinearRingImpl  # :nodoc:
      include Feature::LinearRing
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicLineStringMethods
      include ImplHelper::BasicLinearRingMethods
      include ProjectedGeometryMethods
      include ProjectedNCurveMethods
      include ProjectedLineStringMethods
    end

    class ProjectedLineImpl # :nodoc:
      include Feature::Line
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicLineStringMethods
      include ImplHelper::BasicLineMethods
      include ProjectedGeometryMethods
      include ProjectedNCurveMethods
      include ProjectedLineStringMethods
    end

    class ProjectedPolygonImpl # :nodoc:
      include Feature::Polygon
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicPolygonMethods
      include ProjectedGeometryMethods
      include ProjectedNSurfaceMethods
      include ProjectedPolygonMethods
    end

    class ProjectedGeometryCollectionImpl # :nodoc:
      include Feature::GeometryCollection
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ProjectedGeometryMethods
    end

    class ProjectedMultiPointImpl # :nodoc:
      include Feature::MultiPoint
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ImplHelper::BasicMultiPointMethods
      include ProjectedGeometryMethods
    end

    class ProjectedMultiLineStringImpl # :nodoc:
      include Feature::MultiLineString
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ImplHelper::BasicMultiLineStringMethods
      include ProjectedGeometryMethods
      include ProjectedNCurveMethods
    end

    class ProjectedMultiPolygonImpl # :nodoc:
      include Feature::MultiPolygon
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ImplHelper::BasicMultiPolygonMethods
      include ProjectedGeometryMethods
      include ProjectedNSurfaceMethods
      include ProjectedMultiPolygonMethods
    end
  end
end
