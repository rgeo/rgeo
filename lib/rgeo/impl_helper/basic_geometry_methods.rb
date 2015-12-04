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

      def _set_factory(factory_)  # :nodoc:
        @factory = factory_
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

      def _copy_state_from(obj_)  # :nodoc:
        @factory = obj_.factory
      end

      def marshal_dump # :nodoc:
        [@factory, @factory._marshal_wkb_generator.generate(self)]
      end

      def marshal_load(data_)  # :nodoc:
        _copy_state_from(data_[0]._marshal_wkb_parser.parse(data_[1]))
      end

      def encode_with(coder_)  # :nodoc:
        coder_["factory"] = @factory
        coder_["wkt"] = @factory._psych_wkt_generator.generate(self)
      end

      def init_with(coder_) # :nodoc:
        _copy_state_from(coder_["factory"]._psych_wkt_parser.parse(coder_["wkt"]))
      end
    end
  end
end
