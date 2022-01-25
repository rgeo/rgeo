# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for places where multiple consecutive loops over the same data
      # can be combined into a single loop. It is very likely that combining them
      # will make the code more efficient and more concise.
      #
      # It is marked as unsafe, because the first loop might modify
      # a state that the second loop depends on; these two aren't combinable.
      #
      # @example
      #   # bad
      #   def method
      #     items.each do |item|
      #       do_something(item)
      #     end
      #
      #     items.each do |item|
      #       do_something_else(item)
      #     end
      #   end
      #
      #   # good
      #   def method
      #     items.each do |item|
      #       do_something(item)
      #       do_something_else(item)
      #     end
      #   end
      #
      #   # bad
      #   def method
      #     for item in items do
      #       do_something(item)
      #     end
      #
      #     for item in items do
      #       do_something_else(item)
      #     end
      #   end
      #
      #   # good
      #   def method
      #     for item in items do
      #       do_something(item)
      #       do_something_else(item)
      #     end
      #   end
      #
      #   # good
      #   def method
      #     each_slice(2) { |slice| do_something(slice) }
      #     each_slice(3) { |slice| do_something(slice) }
      #   end
      #
      class CombinableLoops < Base
        MSG = 'Combine this loop with the previous loop.'

        def on_block(node)
          return unless node.parent&.begin_type?
          return unless collection_looping_method?(node)

          add_offense(node) if same_collection_looping?(node, node.left_sibling)
        end

        def on_for(node)
          return unless node.parent&.begin_type?

          sibling = node.left_sibling
          add_offense(node) if sibling&.for_type? && node.collection == sibling.collection
        end

        private

        def collection_looping_method?(node)
          method_name = node.send_node.method_name
          method_name.match?(/^each/) || method_name.match?(/_each$/)
        end

        def same_collection_looping?(node, sibling)
          sibling&.block_type? &&
            sibling.send_node.method?(node.method_name) &&
            sibling.send_node.receiver == node.send_node.receiver &&
            sibling.send_node.arguments == node.send_node.arguments
        end
      end
    end
  end
end
