# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks the indentation of the first line of the
      # right-hand-side of a multi-line assignment.
      #
      # @example
      #   # bad
      #   value =
      #   if foo
      #     'bar'
      #   end
      #
      #   # good
      #   value =
      #     if foo
      #       'bar'
      #     end
      #
      # The indentation of the remaining lines can be corrected with
      # other cops such as `IndentationConsistency` and `EndAlignment`.
      class AssignmentIndentation < Cop
        include CheckAssignment
        include Alignment

        MSG = 'Indent the first line of the right-hand-side of a ' \
              'multi-line assignment.'

        def check_assignment(node, rhs)
          return unless rhs
          return unless node.loc.operator
          return if node.loc.operator.line == rhs.first_line

          base = display_column(leftmost_multiple_assignment(node).source_range)
          check_alignment([rhs], base + configured_indentation_width)
        end

        def autocorrect(node)
          AlignmentCorrector.correct(processed_source, node, column_delta)
        end

        def leftmost_multiple_assignment(node)
          return node unless same_line?(node, node.parent) &&
                             node.parent.assignment?

          leftmost_multiple_assignment(node.parent)

          node.parent
        end
      end
    end
  end
end
