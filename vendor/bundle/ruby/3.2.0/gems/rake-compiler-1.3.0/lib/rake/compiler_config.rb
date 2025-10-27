module Rake
  class CompilerConfig
    def initialize(config_path)
      require "yaml"
      @config = YAML.load_file(config_path)
    end

    def find(ruby_version, gem_platform)
      gem_platform = Gem::Platform.new(gem_platform)

      @config.each do |config_name, config_location|
        # There are two variations we might find in the rake-compiler config.yml
        #
        # 1. config_name: rbconfig-x86_64-linux-3.0.0
        #    runtime_platform_name: x86_64-linux
        #    runtime_version: 3.0.0
        #
        # 2. config_name: rbconfig-x86_64-linux-gnu-3.0.0
        #    runtime_platform_name: x86_64-linux-gnu
        #    runtime_version: 3.0.0
        #
        # With rubygems < 3.3.21, both variations will be present (two entries pointing at the same
        # installation).
        #
        # With rubygems >= 3.3.21, only the second variation will be present.
        runtime_platform_name = config_name.split("-")[1..-2].join("-")
        runtime_version = config_name.split("-").last
        runtime_platform = Gem::Platform.new(runtime_platform_name)

        if (ruby_version == runtime_version) && (gem_platform =~ runtime_platform)
          return config_location
        end
      end

      nil
    end
  end
end
