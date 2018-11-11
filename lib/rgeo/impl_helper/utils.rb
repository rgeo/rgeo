# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Math constants and tools
#
# -----------------------------------------------------------------------------

module RGeo
  module ImplHelper # :nodoc:
    module Utils # :nodoc:
      class << self
        def symbolize_hash(hash)
          nhash = {}
          hash.each do |k, v|
            nhash[k.to_sym] = v.is_a?(String) ? v.to_sym : v
          end
          nhash
        end
      end
    end
  end
end
