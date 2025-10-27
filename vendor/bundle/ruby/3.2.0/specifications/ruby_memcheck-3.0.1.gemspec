# -*- encoding: utf-8 -*-
# stub: ruby_memcheck 3.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "ruby_memcheck".freeze
  s.version = "3.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "homepage_uri" => "https://github.com/Shopify/ruby_memcheck" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Peter Zhu".freeze]
  s.bindir = "exe".freeze
  s.date = "2025-01-03"
  s.email = ["peter@peterzhu.ca".freeze]
  s.executables = ["ruby_memcheck".freeze]
  s.files = ["exe/ruby_memcheck".freeze]
  s.homepage = "https://github.com/Shopify/ruby_memcheck".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Use Valgrind memcheck without going crazy".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 0"])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.0"])
  s.add_development_dependency(%q<minitest-parallel_fork>.freeze, ["~> 2.0"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  s.add_development_dependency(%q<rake-compiler>.freeze, ["~> 1.1"])
  s.add_development_dependency(%q<rspec-core>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.22"])
  s.add_development_dependency(%q<rubocop-shopify>.freeze, ["~> 2.3"])
end
