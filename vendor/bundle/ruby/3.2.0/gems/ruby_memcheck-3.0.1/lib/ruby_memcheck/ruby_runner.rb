# frozen_string_literal: true

module RubyMemcheck
  class RubyRunner
    attr_reader :configuration
    attr_reader :reporter

    def initialize(*args)
      @configuration =
        if !args.empty? && args[0].is_a?(Configuration)
          args.shift
        else
          RubyMemcheck.default_configuration
        end
    end

    def run(*args, **options)
      command = configuration.command(args.map { |a| Shellwords.escape(a) })

      @reporter = TestTaskReporter.new(configuration)

      @reporter.setup

      system(command, options)
      exit_code = $CHILD_STATUS.exitstatus

      @reporter.report_valgrind_errors

      exit_code
    end
  end
end
