# -----------------------------------------------------------------------------
# 
# RGeo Rakefile
# 
# -----------------------------------------------------------------------------
# Copyright 2010 Daniel Azuma
# 
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the copyright holder, nor the names of any other
#   contributors to this software, may be used to endorse or promote products
#   derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# -----------------------------------------------------------------------------
;


require 'rubygems'


module RAKEFILE
  
  DLEXT = ::Config::CONFIG['DLEXT']
  PLATFORM =
    case ::RUBY_DESCRIPTION
    when /^jruby\s/ then :jruby
    when /^ruby\s/ then :mri
    when /^rubinius\s/ then :rubinius
    else :unknown
    end
  PLATFORM_SUFFIX =
    case PLATFORM
    when :mri
      if ::RUBY_VERSION =~ /^1\.8\..*$/
        'mri18'
      elsif ::RUBY_VERSION =~ /^1\.9\..*$/
        'mri19'
      else
        raise "Unknown version of Matz Ruby Interpreter (#{::RUBY_VERSION})"
      end
    when :rubinius then 'rbx'
    when :jruby then 'jruby'
    else 'unknown'
    end
  
  PRODUCT_NAME = 'rgeo'
  PRODUCT_VERSION = ::File.read(::File.dirname(__FILE__)+'/Version').strip.freeze
  RUBYFORGE_PROJECT = 'virtuoso'
  
  SOURCE_FILES = ::Dir.glob('lib/**/*.rb')
  
  EXTRA_RDOC_FILES = ::Dir.glob('*.rdoc')
  ALL_RDOC_FILES = SOURCE_FILES + EXTRA_RDOC_FILES
  MAIN_RDOC_FILE = 'README.rdoc'
  RDOC_TITLE = "RGeo #{PRODUCT_VERSION} Documentation"
  
  TESTCASE_FILES = ::Dir.glob('test/**/tc_*.rb')
  ALL_TEST_FILES = ::Dir.glob('test/**/*.{rb,txt,shp,shx,dbf}')
  
  DOC_DIRECTORY = 'doc'
  PKG_DIRECTORY = 'pkg'
  
  CLEAN_PATTERNS = [DOC_DIRECTORY, PKG_DIRECTORY, 'tmp', 'ext/**/Makefile*', 'ext/**/*.{o,class,log,dSYM}', "**/*.#{DLEXT}", '**/*.rbc', '**/*.jar']
  
  EXT_INFO = {
    'geos_c_impl' => 'lib/rgeo/geos/geos_c_impl',
    'proj4_c_impl' => 'lib/rgeo/coord_sys/proj4_c_impl',
  }
  
  GEMSPEC = ::Gem::Specification.new do |s_|
    s_.name = PRODUCT_NAME
    s_.summary = "RGeo is a spatial data library for Ruby."
    s_.description = "RGeo is a spatial data library for Ruby. It provides an implementation of the Open Geospatial Consortium's Simple Features Specification, used by most standard spatial/geographic data storage systems such as PostGIS. A number of add-on modules are also available to help with writing location-based applications using Ruby-based frameworks such as Ruby On Rails."
    s_.version = "#{PRODUCT_VERSION}"
    s_.author = 'Daniel Azuma'
    s_.email = 'dazuma@gmail.com'
    s_.homepage = "http://#{RUBYFORGE_PROJECT}.rubyforge.org/#{PRODUCT_NAME}"
    s_.rubyforge_project = RUBYFORGE_PROJECT
    s_.required_ruby_version = '>= 1.8.7'
    s_.files = SOURCE_FILES + EXTRA_RDOC_FILES + ALL_TEST_FILES + ::Dir.glob('ext/**/*.{rb,c,h}') + ['Version']
    s_.extra_rdoc_files = EXTRA_RDOC_FILES
    s_.has_rdoc = true
    s_.test_files = TESTCASE_FILES
    s_.platform = ::Gem::Platform::RUBY
    s_.extensions = ::Dir.glob('ext/**/extconf.rb')
  end
  
end


internal_ext_info_ = ::RAKEFILE::EXT_INFO.map do |name_, path_|
  {
    :name => name_,
    :source_dir => "ext/#{name_}",
    :extconf_path => "ext/#{name_}/extconf.rb",
    :source_glob => "ext/#{name_}/*.[ch]",
    :obj_glob => "ext/#{name_}/*.[o]",
    :suffix_makefile_path => "ext/#{name_}/Makefile_#{::RAKEFILE::PLATFORM_SUFFIX}",
    :built_lib_path => "ext/#{name_}/#{name_}.#{::RAKEFILE::DLEXT}",
    :staged_lib_path => "ext/#{name_}/#{name_}_#{::RAKEFILE::PLATFORM_SUFFIX}.#{::RAKEFILE::DLEXT}",
    :installed_lib_path => "#{path_}.#{::RAKEFILE::DLEXT}",
  }
end

internal_ext_info_.each do |info_|
  file info_[:staged_lib_path] => [info_[:suffix_makefile_path]] + ::Dir.glob(info_[:source_glob]) do
    ::Dir.chdir(info_[:source_dir]) do
      cp "Makefile_#{::RAKEFILE::PLATFORM_SUFFIX}", 'Makefile'
      sh 'make'
      rm 'Makefile'
    end
    mv info_[:built_lib_path], info_[:staged_lib_path]
    rm ::Dir.glob(info_[:obj_glob])
  end
  file info_[:suffix_makefile_path] => info_[:extconf_path] do
    ::Dir.chdir(info_[:source_dir]) do
      ruby 'extconf.rb'
      mv 'Makefile', "Makefile_#{::RAKEFILE::PLATFORM_SUFFIX}"
    end
  end
end

task :build_ext => internal_ext_info_.map{ |info_| info_[:staged_lib_path] } do
  internal_ext_info_.each do |info_|
    cp info_[:staged_lib_path], info_[:installed_lib_path]
  end
end


task :clean do
  ::RAKEFILE::CLEAN_PATTERNS.each do |pattern_|
    ::Dir.glob(pattern_) do |path_|
      rm_r path_ rescue nil
    end
  end
end


task :build_rdoc => "#{::RAKEFILE::DOC_DIRECTORY}/index.html"
file "#{::RAKEFILE::DOC_DIRECTORY}/index.html" => ::RAKEFILE::ALL_RDOC_FILES do
  rm_r ::RAKEFILE::DOC_DIRECTORY rescue nil
  args_ = []
  args_ << '-o' << ::RAKEFILE::DOC_DIRECTORY
  args_ << '--main' << ::RAKEFILE::MAIN_RDOC_FILE
  args_ << '--title' << ::RAKEFILE::RDOC_TITLE
  args_ << '-f' << 'darkfish'
  args_ << '--verbose' if ::ENV['VERBOSE']
  require 'rdoc'
  require 'rdoc/rdoc'
  require 'rdoc/generator/darkfish'
  ::RDoc::RDoc.new.document(args_ + ::RAKEFILE::ALL_RDOC_FILES)
end


task :publish_rdoc => :build_rdoc do
  config_ = ::YAML.load(::File.read(::File.expand_path("~/.rubyforge/user-config.yml")))
  username_ = config_['username']
  sh "rsync -av --delete #{::RAKEFILE::DOC_DIRECTORY}/ #{username_}@rubyforge.org:/var/www/gforge-projects/#{::RAKEFILE::RUBYFORGE_PROJECT}/#{::RAKEFILE::PRODUCT_NAME}"
end


task :build_gem do
  ::Gem::Builder.new(::RAKEFILE::GEMSPEC).build
  mkdir_p ::RAKEFILE::PKG_DIRECTORY
  mv "#{::RAKEFILE::PRODUCT_NAME}-#{::RAKEFILE::PRODUCT_VERSION}.gem", "#{::RAKEFILE::PKG_DIRECTORY}/"
end


task :release_gem => [:build_gem] do
  ::Dir.chdir(::RAKEFILE::PKG_DIRECTORY) do
    sh "#{::RbConfig::TOPDIR}/bin/gem push #{::RAKEFILE::PRODUCT_NAME}-#{::RAKEFILE::PRODUCT_VERSION}.gem"
  end
end


task :test => :build_ext do
  $:.unshift(::File.expand_path('lib', ::File.dirname(__FILE__)))
  if ::ENV['TESTCASE']
    test_files_ = ::Dir.glob("test/#{::ENV['TESTCASE']}.rb")
  else
    test_files_ = ::RAKEFILE::TESTCASE_FILES
  end
  test_files_.each do |path_|
    load path_
    puts "Loaded testcase #{path_}"
  end
end


task :default => [:clean, :build_rdoc, :build_gem, :test]
