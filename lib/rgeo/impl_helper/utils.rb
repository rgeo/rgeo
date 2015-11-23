# -----------------------------------------------------------------------------
#
# Math constants and tools
#
# -----------------------------------------------------------------------------

module RGeo
  module ImplHelper # :nodoc:
    module Utils # :nodoc:
      class << self
        def stringize_hash(hash_)
          nhash_ = {}
          hash_.each do |k_, v_|
            nhash_[k_.is_a?(::Symbol) ? k_.to_s : k_] = v_.is_a?(::Symbol) ? v_.to_s : v_
          end
          nhash_
        end

        def symbolize_hash(hash_)
          nhash_ = {}
          hash_.each do |k_, v_|
            nhash_[k_.is_a?(::String) ? k_.to_sym : k_] = v_.is_a?(::String) ? v_.to_sym : v_
          end
          nhash_
        end
      end
    end
  end
end
