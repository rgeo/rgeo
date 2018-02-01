# -----------------------------------------------------------------------------
#
# GEOS implementation additions written in Ruby
#
# -----------------------------------------------------------------------------

module RGeo
  module Geos
    module CAPIGeometryMethods # :nodoc:
      include Feature::Instance

      def inspect
        "#<#{self.class}:0x#{object_id.to_s(16)} #{as_text.inspect}>"
      end

      # Marshal support

      def marshal_dump # :nodoc:
        my_factory = factory
        [my_factory, my_factory._write_for_marshal(self)]
      end

      def marshal_load(data_) # :nodoc:
        obj = data_[0]._read_for_marshal(data_[1])
        _steal(obj)
      end

      # Psych support

      def encode_with(coder) # :nodoc:
        my_factory = factory
        coder["factory"] = my_factory
        str = my_factory._write_for_psych(self)
        str = str.encode("US-ASCII") if str.respond_to?(:encode)
        coder["wkt"] = str
      end

      def init_with(coder) # :nodoc:
        obj = coder["factory"]._read_for_psych(coder["wkt"])
        _steal(obj)
      end

      def as_text
        str = _as_text
        str.force_encoding("US-ASCII") if str.respond_to?(:force_encoding)
        str
      end
      alias to_s as_text
    end

    module CAPIGeometryCollectionMethods # :nodoc:
      include ::Enumerable
    end

    class CAPIGeometryImpl # :nodoc:
      include CAPIGeometryMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Geometry).include_in_class(self, true)
    end

    class CAPIPointImpl # :nodoc:
      include CAPIGeometryMethods
      include CAPIPointMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Point).include_in_class(self, true)
    end

    class CAPILineStringImpl  # :nodoc:
      include CAPIGeometryMethods
      include CAPILineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::LineString).include_in_class(self, true)
    end

    class CAPILinearRingImpl  # :nodoc:
      include CAPIGeometryMethods
      include CAPILineStringMethods
      include CAPILinearRingMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::LinearRing).include_in_class(self, true)
    end

    class CAPILineImpl # :nodoc:
      include CAPIGeometryMethods
      include CAPILineStringMethods
      include CAPILineMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Line).include_in_class(self, true)
    end

    class CAPIPolygonImpl # :nodoc:
      include CAPIGeometryMethods
      include CAPIPolygonMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Polygon).include_in_class(self, true)
    end

    class CAPIGeometryCollectionImpl # :nodoc:
      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::GeometryCollection).include_in_class(self, true)
    end

    class CAPIMultiPointImpl # :nodoc:
      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
      include CAPIMultiPointMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPoint).include_in_class(self, true)
    end

    class CAPIMultiLineStringImpl # :nodoc:
      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
      include CAPIMultiLineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiLineString).include_in_class(self, true)
    end

    class CAPIMultiPolygonImpl # :nodoc:
      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
      include CAPIMultiPolygonMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPolygon).include_in_class(self, true)
    end
  end
end
