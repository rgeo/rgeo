# Load config if present

config_path_ = ::File.expand_path('rakefile_config.rb', ::File.dirname(__FILE__))
load(config_path_) if ::File.exists?(config_path_)
RAKEFILE_CONFIG = {} unless defined?(::RAKEFILE_CONFIG)


# Gemspec

require 'rubygems'
gemspec_ = eval(::File.read(::Dir.glob('*.gemspec').first))
release_gemspec_ = eval(::File.read(::Dir.glob('*.gemspec').first))
release_gemspec_.version = gemspec_.version.to_s.sub(/\.nonrelease$/, '')


# Platform info

dlext_ = ::RbConfig::CONFIG['DLEXT']

platform_ =
  case ::RUBY_DESCRIPTION
  when /^jruby\s/ then :jruby
  when /^ruby\s/ then :mri
  when /^rubinius\s/ then :rubinius
  else :unknown
  end

platform_suffix_ =
  case platform_
  when :mri
    ::RUBY_VERSION.to_s
  when :rubinius then 'rbx'
  when :jruby then 'jruby'
  else 'unknown'
  end


# Directories

doc_directory_ = ::RAKEFILE_CONFIG[:doc_directory] || 'doc'
pkg_directory_ = ::RAKEFILE_CONFIG[:pkg_directory] || 'pkg'
tmp_directory_ = ::RAKEFILE_CONFIG[:tmp_directory] || 'tmp'


# Build tasks

internal_ext_info_ = gemspec_.extensions.map do |extconf_path_|
  source_dir_ = ::File.dirname(extconf_path_)
  name_ = ::File.basename(source_dir_)
  {
    :name => name_,
    :source_dir => source_dir_,
    :extconf_path => extconf_path_,
    :source_glob => "#{source_dir_}/*.{c,h}",
    :obj_glob => "#{source_dir_}/*.{o,dSYM}",
    :suffix_makefile_path => "#{source_dir_}/Makefile_#{platform_suffix_}",
    :built_lib_path => "#{source_dir_}/#{name_}.#{dlext_}",
    :staged_lib_path => "#{source_dir_}/#{name_}_#{platform_suffix_}.#{dlext_}",
  }
end
internal_ext_info_ = [] if platform_ == :jruby

internal_ext_info_.each do |info_|
  file info_[:staged_lib_path] => [info_[:suffix_makefile_path]] + ::Dir.glob(info_[:source_glob]) do
    ::Dir.chdir(info_[:source_dir]) do
      cp "Makefile_#{platform_suffix_}", 'Makefile'
      sh 'make'
      rm 'Makefile'
    end
    mv info_[:built_lib_path], info_[:staged_lib_path]
    rm_r ::Dir.glob(info_[:obj_glob])
  end
  file info_[:suffix_makefile_path] => info_[:extconf_path] do
    ::Dir.chdir(info_[:source_dir]) do
      ruby 'extconf.rb'
      mv 'Makefile', "Makefile_#{platform_suffix_}"
    end
  end
end

task :build_ext => internal_ext_info_.map{ |info_| info_[:staged_lib_path] } do
  internal_ext_info_.each do |info_|
    target_prefix_ = target_name_ = nil
    ::Dir.chdir(info_[:source_dir]) do
      ruby 'extconf.rb'
      ::File.open('Makefile') do |file_|
        file_.each do |line_|
          if line_ =~ /^target_prefix\s*=\s*(\S+)\s/
            target_prefix_ = $1
          elsif line_ =~ /^TARGET\s*=\s*(\S+)\s/
            target_name_ = $1
          end
        end
      end
      rm 'Makefile'
    end
    raise "Could not find target_prefix in makefile for #{info_[:name]}" unless target_prefix_
    raise "Could not find TARGET in makefile for #{info_[:name]}" unless target_name_
    cp info_[:staged_lib_path], "lib#{target_prefix_}/#{target_name_}.#{dlext_}"
  end
end


# Clean task

clean_files_ = [doc_directory_, pkg_directory_, tmp_directory_] +
  ::Dir.glob('ext/**/Makefile*') +
  ::Dir.glob('ext/**/*.{o,class,log,dSYM}') +
  ::Dir.glob("**/*.{bundle,so,dll,rbc,jar}") +
  ::Dir.glob('**/.rbx') +
  (::RAKEFILE_CONFIG[:extra_clean_files] || [])
task :clean do
  clean_files_.each{ |path_| rm_rf path_ }
end


# RDoc tasks

task :build_rdoc => "#{doc_directory_}/index.html"
all_rdoc_files_ = ::Dir.glob("lib/**/*.rb") + gemspec_.extra_rdoc_files
main_rdoc_file_ = ::RAKEFILE_CONFIG[:main_rdoc_file]
main_rdoc_file_ = 'README.rdoc' if !main_rdoc_file_ && ::File.readable?('README.rdoc')
main_rdoc_file_ = ::Dir.glob("*.rdoc").first unless main_rdoc_file_
file "#{doc_directory_}/index.html" => all_rdoc_files_ do
  rm_r doc_directory_ rescue nil
  args_ = []
  args_ << '-o' << doc_directory_
  args_ << '--main' << main_rdoc_file_ if main_rdoc_file_
  args_ << '--title' << "#{::RAKEFILE_CONFIG[:product_visible_name] || gemspec_.name.capitalize} #{release_gemspec_.version} Documentation"
  args_ << '-f' << 'darkfish'
  args_ << '--verbose' if ::ENV['VERBOSE']
  gem 'rdoc'
  require 'rdoc/rdoc'
  ::RDoc::RDoc.new.document(args_ + all_rdoc_files_)
end


# Gem release tasks

task :build_other

task :build_gem => :build_other do
  ::Gem::Builder.new(gemspec_).build
  mkdir_p(pkg_directory_)
  mv "#{gemspec_.name}-#{gemspec_.version}.gem", "#{pkg_directory_}/"
end

task :build_release => :build_other do
  ::Gem::Builder.new(release_gemspec_).build
  mkdir_p(pkg_directory_)
  mv "#{release_gemspec_.name}-#{release_gemspec_.version}.gem", "#{pkg_directory_}/"
end

task :release_gem => :build_release do
  ::Dir.chdir(pkg_directory_) do
    sh "#{::RbConfig::TOPDIR}/bin/gem push #{release_gemspec_.name}-#{release_gemspec_.version}.gem"
  end
end


# Unit test task

task :test => [:build_ext, :build_other] do
  $:.unshift(::File.expand_path('lib', ::File.dirname(__FILE__)))
  if ::ENV['TESTCASE']
    test_files_ = ::Dir.glob("test/#{::ENV['TESTCASE']}.rb")
  else
    test_files_ = ::Dir.glob("test/**/tc_*.rb")
  end
  $VERBOSE = true
  test_files_.each do |path_|
    load path_
    puts "Loaded testcase #{path_}"
  end
end


# Default task

task :default => [:clean, :test]
