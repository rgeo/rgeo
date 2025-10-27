# frozen_string_literal: true

require File.expand_path('lib/ffi-geos/version', __dir__)

Gem::Specification.new do |s|
  s.name = 'ffi-geos'
  s.version = Geos::VERSION

  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = '>= 2.7'

  s.authors = ['J Smith']
  s.description = 'An ffi wrapper for GEOS, a C++ port of the Java Topology Suite (JTS).'
  s.summary = s.description
  s.email = 'dark.panda@gmail.com'
  s.license = 'MIT'
  s.extra_rdoc_files = [
    'README.rdoc'
  ]
  s.files = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  s.executables = s.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.homepage = 'https://github.com/dark-panda/ffi-geos'
  s.require_paths = ['lib']

  s.add_dependency('ffi', ['>= 1.0.0'])
  s.metadata = {
    'rubygems_mfa_required' => 'true'
  }
end
