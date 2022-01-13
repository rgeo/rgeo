# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# GEOS implementation additions written in Ruby
#
# -----------------------------------------------------------------------------

require_relative "../impl_helper/validity_check"

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
    end

    module CAPIGeometryCollectionMethods # :nodoc:
      include Enumerable
    end

    # TODO: is this any useful?
    class CAPIGeometryImpl # :nodoc:
      include ImplHelper::ValidityCheck
      include CAPIGeometryMethods
    end

    class CAPIPointImpl # :nodoc:
      include ImplHelper::ValidityCheck
      include CAPIGeometryMethods
      include CAPIPointMethods
    end

    class CAPILineStringImpl  # :nodoc:
      include ImplHelper::ValidityCheck
      include CAPIGeometryMethods
      include CAPILineStringMethods
    end

    class CAPILinearRingImpl  # :nodoc:
      include ImplHelper::ValidityCheck
      include CAPIGeometryMethods
      include CAPILineStringMethods
      include CAPILinearRingMethods

      def ccw?
        RGeo::Cartesian::Analysis.ccw?(self)
      end
    end

    class CAPILineImpl # :nodoc:
      include ImplHelper::ValidityCheck
      include CAPIGeometryMethods
      include CAPILineStringMethods
      include CAPILineMethods
    end

    class CAPIPolygonImpl
      include ImplHelper::ValidityCheck
      include CAPIGeometryMethods
      include CAPIPolygonMethods
    end

    class CAPIGeometryCollectionImpl
      include ImplHelper::ValidityCheck
      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
    end

    class CAPIMultiPointImpl
      include ImplHelper::ValidityCheck
      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
      include CAPIMultiPointMethods
    end

    class CAPIMultiLineStringImpl
      include ImplHelper::ValidityCheck
      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
      include CAPIMultiLineStringMethods
    end

    class CAPIMultiPolygonImpl
      include ImplHelper::ValidityCheck
      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
      include CAPIMultiPolygonMethods
    end

    ImplHelper::ValidityCheck.override_classes
  end
end
