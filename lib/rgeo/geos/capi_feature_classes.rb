# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# GEOS implementation additions written in Ruby
#
# -----------------------------------------------------------------------------

require_relative "../impl_helper/validity_check"

module RGeo
  module Geos
    module CAPIGeometryMethods
      include Feature::Instance

      def coordinate_dimension
        dim = 2
        dim += 1 if factory.supports_z?
        dim += 1 if factory.supports_m?
        dim
      end

      def spatial_dimension
        factory.supports_z? ? 3 : 2
      end

      def is_3d?
        factory.supports_z?
      end

      def measured?
        factory.supports_m?
      end

      def inspect
        "#<#{self.class}:0x#{object_id.to_s(16)} #{as_text.inspect}>"
      end

      # Marshal support

      def marshal_dump # :nodoc:
        my_factory = factory
        [my_factory, my_factory.write_for_marshal(self)]
      end

      def marshal_load(data_) # :nodoc:
        obj = data_[0].read_for_marshal(data_[1])
        _steal(obj)
      end

      # Psych support

      def encode_with(coder) # :nodoc:
        my_factory = factory
        coder["factory"] = my_factory
        str = my_factory.write_for_psych(self)
        str = str.encode("US-ASCII") if str.respond_to?(:encode)
        coder["wkt"] = str
      end

      def init_with(coder) # :nodoc:
        obj = coder["factory"].read_for_psych(coder["wkt"])
        _steal(obj)
      end

      def as_text
        str = _as_text
        str.force_encoding("US-ASCII") if str.respond_to?(:force_encoding)
        str
      end
      alias to_s as_text

      # Constructs a Voronoi diagram from the vertices of the input geometry.
      #
      # The source may be any geometry type. All vertices of the geometry will be
      # used as the input points to the diagram.
      #
      # @param enevelope [RGeo::Feature::Geometry | nil]
      #   The +envelope+ keyword argument provides an envelope to use to clip the
      #   resulting diagram. If +nil+, it will be calculated automatically.
      #   The diagram will be clipped to the *larger* of the provided envelope
      #   or an envelope surrounding the sites.
      #
      # @param tolerance [Float]
      #   The +tolerance+ keyword argument sets the snapping tolerance used to improve
      #   the robustness of the computation. A tolerance of 0.0 specifies
      #   that no snapping will take place. The +tolerance+ argument can be
      #   finicky and is known to cause the algorithm to fail in several cases.
      #   If you're using +tolerance+ and getting a failure, try removing it.
      #   The test +test_voronoi_diagram_tolerance+ in +test/common/voronoi_tests.rb+
      #   shows more details.
      #
      # @param only_edges [true|false]
      #   If the +only_edges+ keyword argument is +false+ a collection of +Polygon+s
      #   will be returned. Otherwise a collection of +LineString+ edges is returned.
      #
      # @return [RGeo::Feature::Geometry]
      #   if +only_edges+ is true, this will return a LineString or MultiLineString.
      #   Otherwise, it will be a GeometryCollection of polygons.
      #
      # @see https://en.wikipedia.org/wiki/Voronoi_diagram
      # @see https://libgeos.org/doxygen/geos__c_8h.html#ace0b2fabc92d8457a295c385ea128aa5
      def voronoi_diagram(envelope: nil, tolerance: 0.0, only_edges: false)
        Primary.voronoi_diagram(self, envelope, Float(tolerance), only_edges)
      rescue RGeo::Error::InvalidGeometry => e
        message = "Could not create a voronoi_diagram with the specified inputs"
        message += ". Try removing the `tolerance` parameter from ##{__method__}" if tolerance
        raise e, message
      end
    end

    module CAPIGeometryCollectionMethods # :nodoc:
      include Enumerable
    end

    class CAPIGeometryImpl
      include Feature::Geometry
      include ImplHelper::ValidityCheck
      include CAPIGeometryMethods
    end

    class CAPIPointImpl
      include Feature::Point
      include ImplHelper::ValidityCheck
      include CAPIGeometryMethods
      include CAPIPointMethods
    end

    class CAPILineStringImpl
      include Feature::LineString
      include ImplHelper::ValidityCheck
      include CAPIGeometryMethods
      include CAPILineStringMethods
    end

    class CAPILinearRingImpl
      include Feature::LinearRing
      include ImplHelper::ValidityCheck
      include CAPIGeometryMethods
      include CAPILineStringMethods
      include CAPILinearRingMethods

      def ccw?
        RGeo::Cartesian::Analysis.ccw?(self)
      end
    end

    class CAPILineImpl
      include Feature::Line
      include ImplHelper::ValidityCheck
      include CAPIGeometryMethods
      include CAPILineStringMethods
      include CAPILineMethods
    end

    class CAPIPolygonImpl
      include Feature::Polygon
      include ImplHelper::ValidityCheck
      include CAPIGeometryMethods
      include CAPIPolygonMethods
    end

    class CAPIGeometryCollectionImpl
      include Feature::GeometryCollection
      include ImplHelper::ValidityCheck
      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
    end

    class CAPIMultiPointImpl
      include Feature::MultiPoint
      include ImplHelper::ValidityCheck
      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
      include CAPIMultiPointMethods
    end

    class CAPIMultiLineStringImpl
      include Feature::MultiLineString
      include ImplHelper::ValidityCheck
      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
      include CAPIMultiLineStringMethods
    end

    class CAPIMultiPolygonImpl
      include Feature::MultiPolygon
      include ImplHelper::ValidityCheck
      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
      include CAPIMultiPolygonMethods
    end

    ImplHelper::ValidityCheck.override_classes
  end
end
