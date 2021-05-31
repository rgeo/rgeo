# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# GEOS implementation additions written in Ruby
#
# -----------------------------------------------------------------------------

module RGeo
  module ValidityCheck
    OGC_METHODS = %i(contains? intersection area).freeze
    class << self
      def override_classes
        override(classes.pop) until classes.empty?
      end

      def included(klass)
        classes << klass
      end

      private

      def classes
        @classes ||= Queue.new
      end

      def override(klass)
        klass.class_eval do
          (OGC_METHODS & instance_methods).each do |method_sym|
            copy = "unsafe_#{method_sym}".to_sym
            alias_method copy, method_sym
            undef_method method_sym
            define_method(method_sym) do |*args|
              check_validity!
              method(copy).call(*args)
            end
          end
        end
      end
    end

    def check_validity!
      if defined?(@invalid_reason)
        return unless @invalid_reason

        raise Error::InvalidGeometry, @invalid_reason
      end

      unless respond_to?(:invalid_reason)
        raise Error::UnsupportedOperation, "Method #{self.class}#invalid_reason not defined."
      end

      @invalid_reason = invalid_reason
      return unless @invalid_reason

      raise Error::InvalidGeometry, @invalid_reason
    end
  end

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
      include ValidityCheck
      include CAPIGeometryMethods
    end

    class CAPIPointImpl # :nodoc:
      include ValidityCheck
      include CAPIGeometryMethods
      include CAPIPointMethods
    end

    class CAPILineStringImpl  # :nodoc:
      include ValidityCheck
      include CAPIGeometryMethods
      include CAPILineStringMethods
    end

    class CAPILinearRingImpl  # :nodoc:
      include ValidityCheck
      include CAPIGeometryMethods
      include CAPILineStringMethods
      include CAPILinearRingMethods

      def ccw?
        RGeo::Cartesian::Analysis.ccw?(self)
      end
    end

    class CAPILineImpl # :nodoc:
      include ValidityCheck
      include CAPIGeometryMethods
      include CAPILineStringMethods
      include CAPILineMethods
    end

    class CAPIPolygonImpl # :nodoc:
      include ValidityCheck
      include CAPIGeometryMethods
      include CAPIPolygonMethods
    end

    class CAPIGeometryCollectionImpl # :nodoc:
      include ValidityCheck
      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
    end

    class CAPIMultiPointImpl # :nodoc:
      include ValidityCheck
      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
      include CAPIMultiPointMethods
    end

    class CAPIMultiLineStringImpl # :nodoc:
      include ValidityCheck
      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
      include CAPIMultiLineStringMethods
    end

    class CAPIMultiPolygonImpl # :nodoc:
      include ValidityCheck
      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
      include CAPIMultiPolygonMethods
    end

    OGC_METHODS = %i(contains? intersection area).freeze

    puts("objspace: " + Benchmark.measure do
      ValidityCheck.override_classes
      # ObjectSpace.each_object(Class) do |impl|
      #   next unless impl < CAPIGeometryMethods

      #   impl.class_eval do
      #     (OGC_METHODS & instance_methods).each do |method_sym|
      #       copy = "unsafe_#{method_sym}".to_sym
      #       alias_method copy, method_sym
      #       undef_method method_sym
      #       define_method(method_sym) do |*args|
      #         check_validity!
      #         method(copy).call(*args)
      #       end
      #     end
      #   end
      # end
    end.real.to_s)
  end
end
