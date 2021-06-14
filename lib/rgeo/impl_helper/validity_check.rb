# frozen_string_literal: true

module RGeo
  module ImplHelper
    # This helper enforces valid geometry computation, avoiding results such
    # as a 0 area for a bowtie shaped polygon. Implementations that are part
    # of RGeo core should all include this.
    #
    # You can play around validity checks if needed:
    #
    # - {check_validity!} is the method that will raise if your geometry is
    #   not valid. Its message will be the same as {invalid_reason}.
    # - {make_valid} is the method you can call to get a valid copy of the
    #   current geometry.
    # - finally, you can bypass any checked method by prepending `unsafe_` to
    #   it. At your own risk.
    module ValidityCheck
      # Every method that need to be valid to give a correct result.
      # TODO: list all methods that need valid geometries here.
      CHECKED_METHODS = [:area].freeze

      class << self
        # Note for contributors: this should be called after all methods
        # are loaded for a given feature classe. No worries though, this
        # is tested.
        def override_classes # :nodoc:
          # Using pop here to be thread safe.
          while (klass = classes.pop)
            override(klass)
          end
        end

        def included(klass) # :nodoc:
          classes << klass
        end

        private

        def classes
          @classes ||= []
        end

        def override(klass)
          klass.class_eval do
            (CHECKED_METHODS & instance_methods).each do |method_sym|
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

      # Raises {invalid_reason} if the polygon is not valid, does nothing
      # otherwise.
      def check_validity!
        # This method will use a cached invalid_reason for performance purposes.
        # DO NOT MUTATE GEOMETRIES.
        return unless invalid_reason_memo

        raise Error::InvalidGeometry, invalid_reason_memo
      end

      # Tell why the geometry is not valid, `nil` means it is valid.
      def invalid_reason
        if defined?(super) == "super"
          raise Error::RGeoError, "ValidityCheck MUST be loaded before " \
            "definition of #{self.class}#invalid_reason."
        end

        raise Error::UnsupportedOperation, "Method #{self.class}#invalid_reason not defined."
      end

      # Try and make the geometry valid, this may change its shape.
      # Returns a valid copy of the geometry.
      def make_valid
        if defined?(super) == "super"
          raise Error::RGeoError, "ValidityCheck MUST be loaded before " \
            "definition of #{self.class}#invalid_reason."
        end

        raise Error::UnsupportedOperation, "Method #{self.class}#make_valid not defined."
      end

      private

      def invalid_reason_memo
        # `defined?`` is a bit faster than `instance_variable_defined?`.
        return @invalid_reason_memo if defined?(@invalid_reason_memo)

        @invalid_reason_memo = invalid_reason
      end
    end
  end
end
