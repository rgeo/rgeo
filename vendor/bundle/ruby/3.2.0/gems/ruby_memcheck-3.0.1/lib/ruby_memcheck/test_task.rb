# frozen_string_literal: true

module RubyMemcheck
  class TestTask < Rake::TestTask
    attr_reader :configuration
    attr_reader :reporter

    def initialize(*args)
      @configuration =
        if !args.empty? && args[0].is_a?(Configuration)
          args.shift
        else
          RubyMemcheck.default_configuration
        end

      super
    end

    def ruby(*args, **options, &block)
      command = configuration.command(args)

      @reporter = TestTaskReporter.new(configuration)

      @reporter.setup

      sh(command, **options) do |ok, res|
        @reporter.report_valgrind_errors

        yield ok, res if block_given?
      end
    end
  end
end
