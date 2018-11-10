require "rake/testtask"
require "rake/extensiontask"
require "bundler/gem_tasks"

# Load config if present

config_path = File.expand_path("rakefile_config.rb", File.dirname(__FILE__))
load(config_path) if File.exist?(config_path)
RAKEFILE_CONFIG ||= {}

gemspec = eval(File.read(Dir.glob("*.gemspec").first))
release_gemspec = eval(File.read(Dir.glob("*.gemspec").first))
release_gemspec.version = gemspec.version.to_s.sub(/\.nonrelease$/, "")

pkg_directory = RAKEFILE_CONFIG[:pkg_directory] || "pkg"
tmp_directory = RAKEFILE_CONFIG[:tmp_directory] || "tmp"

# Build tasks

if RUBY_DESCRIPTION.match /^jruby/
  task :compile
else
  Rake::ExtensionTask.new "geos_c_impl" do |ext|
    ext.lib_dir = "lib/rgeo/geos"
  end
end

task :clean do
  clean_files = [pkg_directory, tmp_directory] +
    Dir.glob("ext/**/Makefile*") +
    Dir.glob("ext/**/*.{o,class,log,dSYM}") +
    Dir.glob("**/*.{bundle,so,dll,rbc,jar}") +
    Dir.glob("**/.rbx") +
    (RAKEFILE_CONFIG[:extra_clean_files] || [])

  clean_files.each { |path| rm_rf path }
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task test: :compile
task default: [:clean, :test]
