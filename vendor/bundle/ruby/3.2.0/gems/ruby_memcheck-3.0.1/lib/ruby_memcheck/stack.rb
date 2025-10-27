# frozen_string_literal: true

module RubyMemcheck
  class Stack
    attr_reader :configuration, :frames

    def initialize(configuration, loaded_binaries, stack_xml)
      @configuration = configuration
      @frames = stack_xml.xpath("frame").map { |frame| Frame.new(configuration, loaded_binaries, frame) }
    end

    def skip?
      if @configuration.use_only_ruby_free_at_exit?
        skip_using_ruby_free_at_exit?
      else
        skip_using_original_heuristics?
      end
    end

    private

    def skip_using_ruby_free_at_exit?
      if configuration.binary_name.nil?
        false
      else
        in_binary = false

        frames.each do |frame|
          if frame.in_binary?
            in_binary = true
          end
        end

        !in_binary
      end
    end

    def skip_using_original_heuristics?
      in_binary = false

      frames.each do |frame|
        if frame.in_ruby?
          # If a stack from from the binary was encountered first, then this
          # memory leak did not occur from Ruby
          unless in_binary
            # Skip this stack because it was called from Ruby
            return true if configuration.skipped_ruby_functions.any? { |r| r.match?(frame.fn) }
          end
        elsif frame.in_binary?
          in_binary = true

          # Skip the Init function because it is only ever called once, so
          # leaks in it cannot cause memory bloat
          return true if frame.binary_init_func?
        end
      end

      # Skip if the stack was never in the binary because it is very likely
      # not a leak in the native gem
      !in_binary
    end
  end
end
