# -*- encoding: utf-8 -*-
# stub: ffi-geos 2.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "ffi-geos".freeze
  s.version = "2.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["J Smith".freeze]
  s.date = "2024-08-02"
  s.description = "An ffi wrapper for GEOS, a C++ port of the Java Topology Suite (JTS).".freeze
  s.email = "dark.panda@gmail.com".freeze
  s.extra_rdoc_files = ["README.rdoc".freeze]
  s.files = ["README.rdoc".freeze]
  s.homepage = "https://github.com/dark-panda/ffi-geos".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "An ffi wrapper for GEOS, a C++ port of the Java Topology Suite (JTS).".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<ffi>.freeze, [">= 1.0.0"])
end
