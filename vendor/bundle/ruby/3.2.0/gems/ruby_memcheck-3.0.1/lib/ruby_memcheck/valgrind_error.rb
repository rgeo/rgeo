# frozen_string_literal: true

module RubyMemcheck
  class ValgrindError
    SUPPRESSION_NOT_CONFIGURED_ERROR_MSG =
      "Please enable suppressions by configuring with valgrind_generate_suppressions set to true"

    attr_reader :kind, :msg, :stack, :suppression

    def initialize(configuration, loaded_binaries, error)
      @kind = error.at_xpath("kind").content
      @msg =
        if kind_leak?
          error.at_xpath("xwhat/text").content
        else
          error.at_xpath("what").content
        end
      @stack = Stack.new(configuration, loaded_binaries, error.at_xpath("stack"))
      @configuration = configuration

      suppression_node = error.at_xpath("suppression")
      if configuration.valgrind_generate_suppressions?
        @suppression = Suppression.new(configuration, suppression_node)
      elsif suppression_node
        raise SUPPRESSION_NOT_CONFIGURED_ERROR_MSG
      end
    end

    def skip?
      should_filter? && stack.skip?
    end

    def to_s
      str = StringIO.new
      str << "#{msg}\n"
      stack.frames.each do |frame|
        str << if frame.in_binary?
          " *#{frame}\n"
        else
          "  #{frame}\n"
        end
      end
      str << suppression.to_s if suppression
      str.string
    end

    private

    def should_filter?
      @configuration.filter_all_errors? || kind_leak?
    end

    def kind_leak?
      kind.start_with?("Leak_")
    end
  end
end
