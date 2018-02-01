# -----------------------------------------------------------------------------
#
# Basic methods used by geometry objects
#
# -----------------------------------------------------------------------------

module RGeo
  module ImplHelper # :nodoc:
    module BasicGeometryMethods # :nodoc:
      include Feature::Instance

      def inspect # :nodoc:
        "#<#{self.class}:0x#{object_id.to_s(16)} #{as_text.inspect}>"
      end

      def to_s # :nodoc:
        as_text
      end

      def _validate_geometry # :nodoc:
      end

      def _set_factory(factory)  # :nodoc:
        @factory = factory
      end

      def factory
        @factory
      end

      def as_text
        @factory._generate_wkt(self)
      end

      def as_binary
        @factory._generate_wkb(self)
      end

      def _copy_state_from(obj)  # :nodoc:
        @factory = obj.factory
      end

      def marshal_dump # :nodoc:
        [@factory, @factory._marshal_wkb_generator.generate(self)]
      end

      def marshal_load(data)  # :nodoc:
        _copy_state_from(data[0]._marshal_wkb_parser.parse(data[1]))
      end

      def encode_with(coder)  # :nodoc:
        coder["factory"] = @factory
        coder["wkt"] = @factory._psych_wkt_generator.generate(self)
      end

      def init_with(coder) # :nodoc:
        _copy_state_from(coder["factory"]._psych_wkt_parser.parse(coder["wkt"]))
      end
    end
  end
end
