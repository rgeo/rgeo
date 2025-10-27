# frozen_string_literal: true

module RubyMemcheck
  class TestTaskReporter
    VALGRIND_REPORT_MSG = "Valgrind reported errors (e.g. memory leak or use-after-free)"

    attr_reader :configuration
    attr_reader :errors

    def initialize(configuration)
      @configuration = configuration
      @loaded_binaries = nil
    end

    def run_ruby_with_valgrind(&block)
      setup
      yield
      report_valgrind_errors
    end

    def setup
      ENV["RUBY_MEMCHECK_LOADED_FEATURES_FILE"] = File.expand_path(configuration.loaded_features_file)
      ENV["RUBY_MEMCHECK_RUNNING"] = "1"
      ENV["RUBY_FREE_AT_EXIT"] = "1"
    end

    def report_valgrind_errors
      parse_valgrind_output
      remove_valgrind_xml_files

      unless errors.empty?
        output_valgrind_errors
        raise VALGRIND_REPORT_MSG
      end
    end

    private

    def loaded_binaries
      return @loaded_binaries if @loaded_binaries

      loaded_features = File.readlines(configuration.loaded_features_file, chomp: true)
      @loaded_binaries = loaded_features.keep_if do |feat|
        # Keep only binaries (ignore Ruby files).
        File.extname(feat) == ".so"
      end

      if configuration.binary_name
        @loaded_binaries.keep_if do |feat|
          File.basename(feat, ".*") == configuration.binary_name
        end

        if @loaded_binaries.empty?
          raise "The Ruby program executed never loaded a binary called `#{configuration.binary_name}`"
        end
      end

      @loaded_binaries.freeze
    end

    def valgrind_xml_files
      @valgrind_xml_files ||= Dir[File.join(configuration.temp_dir, "*.xml")].freeze
    end

    def parse_valgrind_output
      require "nokogiri"

      @errors = []

      valgrind_xml_files.each do |file|
        reader = Nokogiri::XML::Reader(File.open(file)) do |config| # rubocop:disable Style/SymbolProc
          config.huge
        end
        reader.each do |node|
          next unless node.name == "error" && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT

          error_xml = Nokogiri::XML::Document.parse(node.outer_xml).root
          error = ValgrindError.new(configuration, loaded_binaries, error_xml)
          next if error.skip?

          @errors << error
        end
      end
    end

    def remove_valgrind_xml_files
      valgrind_xml_files.each do |file|
        File.delete(file)
      end
    end

    def output_valgrind_errors
      @errors.each do |error|
        configuration.output_io.puts error
        configuration.output_io.puts
      end
    end
  end
end
