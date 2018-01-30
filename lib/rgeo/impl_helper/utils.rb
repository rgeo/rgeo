# -----------------------------------------------------------------------------
#
# Math constants and tools
#
# -----------------------------------------------------------------------------

module RGeo
  module ImplHelper # :nodoc:
    module Utils # :nodoc:
      class << self
        def stringize_hash(hash)
          nhash = {}
          hash.each do |k, v|
            nhash[k.is_a?(::Symbol) ? k.to_s : k] = v.is_a?(::Symbol) ? v.to_s : v
          end
          nhash
        end

        def symbolize_hash(hash)
          nhash = {}
          hash.each do |k, v|
            nhash[k.is_a?(::String) ? k.to_sym : k] = v.is_a?(::String) ? v.to_sym : v
          end
          nhash
        end
      end
    end
  end
end
