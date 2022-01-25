# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces the use of `Array()` instead of explicit `Array` check or `[*var]`.
      #
      # This cop is disabled by default because false positive will occur if
      # the argument of `Array()` is not an array (e.g. Hash, Set),
      # an array will be returned as an incompatibility result.
      #
      # @example
      #   # bad
      #   paths = [paths] unless paths.is_a?(Array)
      #   paths.each { |path| do_something(path) }
      #
      #   # bad (always creates a new Array instance)
      #   [*paths].each { |path| do_something(path) }
      #
      #   # good (and a bit more readable)
      #   Array(paths).each { |path| do_something(path) }
      #
      class ArrayCoercion < Base
        extend AutoCorrector

        SPLAT_MSG = 'Use `Array(%<arg>s)` instead of `[*%<arg>s]`.'
        CHECK_MSG = 'Use `Array(%<arg>s)` instead of explicit `Array` check.'

        def_node_matcher :array_splat?, <<~PATTERN
          (array (splat $_))
        PATTERN

        def_node_matcher :unless_array?, <<~PATTERN
          (if
            (send
              (lvar $_) :is_a?
              (const nil? :Array)) nil?
            (lvasgn $_
              (array
                (lvar $_))))
        PATTERN

        def on_array(node)
          return unless node.square_brackets?

          array_splat?(node) do |arg_node|
            message = format(SPLAT_MSG, arg: arg_node.source)
            add_offense(node, message: message) do |corrector|
              corrector.replace(node, "Array(#{arg_node.source})")
            end
          end
        end

        def on_if(node)
          unless_array?(node) do |var_a, var_b, var_c|
            if var_a == var_b && var_c == var_b
              message = format(CHECK_MSG, arg: var_a)
              add_offense(node, message: message) do |corrector|
                corrector.replace(node, "#{var_a} = Array(#{var_a})")
              end
            end
          end
        end
      end
    end
  end
end
