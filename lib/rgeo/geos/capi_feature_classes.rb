# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# GEOS implementation additions written in Ruby
#
# -----------------------------------------------------------------------------

module RGeo
  module Geos
    module CAPIGeometryMethods # :nodoc:
      include Feature::Instance

      def is_empty? # rubocop:disable Naming/PredicateName
        warn "The is_empty? method is deprecated, please use the empty? counterpart, will be removed in v3" unless ENV["RGEO_SILENCE_DEPRECATION"]
        empty?
      end

      def is_simple? # rubocop:disable Naming/PredicateName
        warn "The is_simple? method is deprecated, please use the simple? counterpart, will be removed in v3" unless ENV["RGEO_SILENCE_DEPRECATION"]
        simple?
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
    end

    module CAPIMultiLineStringMethods # :nodoc:
      def is_closed? # rubocop:disable Naming/PredicateName
        warn "The is_closed? method is deprecated, please use the closed? counterpart, will be removed in v3" unless ENV["RGEO_SILENCE_DEPRECATION"]
        closed?
      end
    end

    module CAPILineStringMethods # :nodoc:
      def is_closed? # rubocop:disable Naming/PredicateName
        warn "The is_closed? method is deprecated, please use the closed? counterpart, will be removed in v3" unless ENV["RGEO_SILENCE_DEPRECATION"]
        closed?
      end

      def is_ring? # rubocop:disable Naming/PredicateName
        warn "The is_ring? method is deprecated, please use the ring? counterpart, will be removed in v3" unless ENV["RGEO_SILENCE_DEPRECATION"]
        ring?
      end
    end

    module CAPIGeometryCollectionMethods # :nodoc:
      include Enumerable
    end

    class CAPIGeometryImpl # :nodoc:
      include CAPIGeometryMethods
    end

    class CAPIPointImpl # :nodoc:
      include CAPIGeometryMethods
      include CAPIPointMethods
    end

    class CAPILineStringImpl  # :nodoc:
      include CAPIGeometryMethods
      include CAPILineStringMethods
    end

    class CAPILinearRingImpl  # :nodoc:
      include CAPIGeometryMethods
      include CAPILineStringMethods
      include CAPILinearRingMethods

      def ccw?
        RGeo::Cartesian::Analysis.ccw?(self)
      end
    end

    class CAPILineImpl # :nodoc:
      include CAPIGeometryMethods
      include CAPILineStringMethods
      include CAPILineMethods
    end

    class CAPIPolygonImpl # :nodoc:
      include CAPIGeometryMethods
      include CAPIPolygonMethods
    end

    class CAPIGeometryCollectionImpl # :nodoc:
      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
    end

    class CAPIMultiPointImpl # :nodoc:
      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
      include CAPIMultiPointMethods
    end

    class CAPIMultiLineStringImpl # :nodoc:
      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
      include CAPIMultiLineStringMethods
    end

    class CAPIMultiPolygonImpl # :nodoc:
      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
      include CAPIMultiPolygonMethods
    end
  end
end
