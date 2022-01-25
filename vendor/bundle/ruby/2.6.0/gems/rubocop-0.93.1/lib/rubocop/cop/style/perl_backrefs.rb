# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop looks for uses of Perl-style regexp match
      # backreferences like $1, $2, etc.
      #
      # @example
      #   # bad
      #   puts $1
      #
      #   # good
      #   puts Regexp.last_match(1)
      class PerlBackrefs < Base
        extend AutoCorrector

        MSG = 'Avoid the use of Perl-style backrefs.'

        def on_nth_ref(node)
          add_offense(node) do |corrector|
            backref, = *node
            parent_type = node.parent ? node.parent.type : nil

            if %i[dstr xstr regexp].include?(parent_type)
              corrector.replace(node, "{Regexp.last_match(#{backref})}")

            else
              corrector.replace(node, "Regexp.last_match(#{backref})")
            end
          end
        end
      end
    end
  end
end
