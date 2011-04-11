::Gem::Specification.new do |s_|
  s_.name = 'rgeo'
  s_.summary = 'RGeo is a geospatial data library for Ruby.'
  s_.description = "RGeo is a geospatial data library for Ruby. It provides an implementation of the Open Geospatial Consortium's Simple Features Specification, used by most standard spatial/geographic data storage systems such as PostGIS. A number of add-on modules are also available to help with writing location-based applications using Ruby-based frameworks such as Ruby On Rails."
  s_.version = "#{::File.read('Version').strip}.build#{::Time.now.utc.strftime('%Y%m%d%H%M%S')}"
  s_.author = 'Daniel Azuma'
  s_.email = 'dazuma@gmail.com'
  s_.homepage = "http://virtuoso.rubyforge.org/rgeo"
  s_.rubyforge_project = 'virtuoso'
  s_.required_ruby_version = '>= 1.8.7'
  s_.files = ::Dir.glob("lib/**/*.rb") +
    ::Dir.glob("ext/**/*.{rb,c,h}") +
    ::Dir.glob("test/**/*.rb") +
    ::Dir.glob("*.rdoc") +
    ['Version']
  s_.extra_rdoc_files = ::Dir.glob("*.rdoc")
  s_.test_files = ::Dir.glob("test/**/tc_*.rb")
  s_.platform = ::Gem::Platform::RUBY
  s_.extensions = ::Dir.glob("ext/*/extconf.rb")
end
