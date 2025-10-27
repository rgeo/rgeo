# frozen_string_literal: true

require_relative "lib/ruby_memcheck/version"

Gem::Specification.new do |spec|
  spec.name          = "ruby_memcheck"
  spec.version       = RubyMemcheck::VERSION
  spec.authors       = ["Peter Zhu"]
  spec.email         = ["peter@peterzhu.ca"]

  spec.summary       = "Use Valgrind memcheck without going crazy"
  spec.homepage      = "https://github.com/Shopify/ruby_memcheck"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    %x(git ls-files -z).split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency("nokogiri")

  spec.add_development_dependency("minitest", "~> 5.0")
  spec.add_development_dependency("minitest-parallel_fork", "~> 2.0")
  spec.add_development_dependency("rake", "~> 13.0")
  spec.add_development_dependency("rake-compiler", "~> 1.1")
  spec.add_development_dependency("rspec-core")
  spec.add_development_dependency("rubocop", "~> 1.22")
  spec.add_development_dependency("rubocop-shopify", "~> 2.3")
end
