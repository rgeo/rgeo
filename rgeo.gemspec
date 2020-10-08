# frozen_string_literal: true

require "./lib/rgeo/version"

Gem::Specification.new do |spec|
  spec.name = "rgeo"
  spec.summary = "RGeo is a geospatial data library for Ruby."

  spec.description =
    "RGeo is a geospatial data library for Ruby. It provides an implementation " \
    "of the Open Geospatial Consortium's Simple Features Specification, used by " \
    "most standard spatial/geographic data storage systems such as PostGIS. A " \
    "number of add-on modules are also available to help with writing " \
    "location-based applications using Ruby-based frameworks such as Ruby On Rails."

  spec.version = RGeo::VERSION
  spec.authors = ["Daniel Azuma", "Tee Parham"]
  spec.email = ["dazuma@gmail.com", "parhameter@gmail.com", "kfdoggett@gmail.com"]
  spec.homepage = "https://github.com/rgeo/rgeo"
  spec.required_ruby_version = ">= 2.4.0"
  spec.license = "BSD-3-Clause"

  spec.files = Dir["lib/**/*.rb", "ext/**/*.{rb,c,h}", "LICENSE.txt"]
  spec.extensions = Dir["ext/*/extconf.rb"]

  spec.add_development_dependency "ffi-geos", "~> 1.2"
  spec.add_development_dependency "minitest", "~> 5.11"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rake-compiler", "~> 1.0"
  spec.add_development_dependency "rubocop", "~> 0.51"
end
