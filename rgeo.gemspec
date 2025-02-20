# frozen_string_literal: true

require_relative "lib/rgeo/version"

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
  spec.email = ["dazuma@gmail.com", "parhameter@gmail.com", "kfdoggett@gmail.com", "buonomo.ulysse@gmail.com"]
  spec.homepage = "https://github.com/rgeo/rgeo"
  spec.required_ruby_version = ">= 3.1.4"
  spec.license = "BSD-3-Clause"

  spec.metadata["funding_uri"] = "https://opencollective.com/rgeo"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["lib/**/*.rb", "ext/**/*.{rb,c,h}", "LICENSE.txt", "README.md", ".yardopts"]
  spec.extensions = Dir["ext/*/extconf.rb"]
end
