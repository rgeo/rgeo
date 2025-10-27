# frozen_string_literal: true

require "English"
require "shellwords"
require "tempfile"
require "rake/testtask"

require "ruby_memcheck/configuration"
require "ruby_memcheck/frame"
require "ruby_memcheck/ruby_runner"
require "ruby_memcheck/stack"
require "ruby_memcheck/test_task_reporter"
require "ruby_memcheck/test_task"
require "ruby_memcheck/valgrind_error"
require "ruby_memcheck/suppression"
require "ruby_memcheck/version"

module RubyMemcheck
  class << self
    def config(**opts)
      @default_configuration = Configuration.new(**opts)
    end

    def default_configuration
      @default_configuration ||= config
    end
  end
end
