# -*- encoding: utf-8 -*-
# stub: ffi-geos 1.2.2 ruby lib

Gem::Specification.new do |s|
  s.name = "ffi-geos".freeze
  s.version = "1.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["J Smith".freeze]
  s.date = "2018-12-05"
  s.description = "An ffi wrapper for GEOS, a C++ port of the Java Topology Suite (JTS).".freeze
  s.email = "dark.panda@gmail.com".freeze
  s.extra_rdoc_files = ["README.rdoc".freeze]
  s.files = ["README.rdoc".freeze]
  s.homepage = "http://github.com/dark-panda/ffi-geos".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3.1".freeze
  s.summary = "An ffi wrapper for GEOS, a C++ port of the Java Topology Suite (JTS).".freeze

  s.installed_by_version = "3.0.3.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ffi>.freeze, [">= 1.0.0"])
    else
      s.add_dependency(%q<ffi>.freeze, [">= 1.0.0"])
    end
  else
    s.add_dependency(%q<ffi>.freeze, [">= 1.0.0"])
  end
end
