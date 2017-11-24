require "rake/testtask"
require "rake/extensiontask"
require "rdoc/task"
# Load config if present

config_path = ::File.expand_path("rakefile_config.rb", ::File.dirname(__FILE__))
load(config_path) if ::File.exist?(config_path)
RAKEFILE_CONFIG = {} unless defined?(::RAKEFILE_CONFIG)

# Gemspec

gemspec = eval(::File.read(::Dir.glob("*.gemspec").first))
release_gemspec = eval(::File.read(::Dir.glob("*.gemspec").first))
release_gemspec.version = gemspec.version.to_s.sub(/\.nonrelease$/, "")

require "bundler/gem_tasks"

# Directories

doc_directory = ::RAKEFILE_CONFIG[:doc_directory] || "doc"
pkg_directory = ::RAKEFILE_CONFIG[:pkg_directory] || "pkg"
tmp_directory = ::RAKEFILE_CONFIG[:tmp_directory] || "tmp"

# Build tasks

if ::RUBY_DESCRIPTION.match /^jruby/
  task :compile
else
  Rake::ExtensionTask.new "geos_c_impl" do |ext|
    ext.lib_dir = "lib/rgeo/geos"
  end
end

# Clean task

clean_files = [doc_directory, pkg_directory, tmp_directory] +
  ::Dir.glob("ext/**/Makefile*") +
  ::Dir.glob("ext/**/*.{o,class,log,dSYM}") +
  ::Dir.glob("**/*.{bundle,so,dll,rbc,jar}") +
  ::Dir.glob("**/.rbx") +
  (::RAKEFILE_CONFIG[:extra_clean_files] || [])

task :clean do
  clean_files.each { |path| rm_rf path }
end
#
# RDoc tasks


RDoc::Task.new do |rdoc|
  rdoc.rdoc_files.include("lib/**/*.rb")
  # rdoc.options << "--all"
  rdoc.title = "#{::RAKEFILE_CONFIG[:product_visible_name] || gemspec.name.capitalize} #{release_gemspec.version} Documentation"
  rdoc.rdoc_dir = "doc"
end

task build_other: [:build]

# Unit test task

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task test: :compile

task default: [:clean, :test]
