# frozen_string_literal: true

require "rake/testtask"
require "rake/extensiontask"
require "ruby_memcheck"
require "bundler/gem_tasks"
require "yard"

RubyMemcheck.config(
  binary_name: "geos_c_impl",
  # valgrind_generate_suppressions: true,
  valgrind_suppressions_dir: "test/valgrind/suppressions"
)

# Build tasks

if RUBY_DESCRIPTION.match(/^jruby/)
  task :compile
else
  Rake::ExtensionTask.new "geos_c_impl" do |ext|
    ext.lib_dir = "lib/rgeo/geos"
  end
end

task :clean do
  clean_files = %w[pkg tmp] +
    Dir.glob("ext/**/Makefile*") +
    Dir.glob("ext/**/*.{o,class,log,dSYM}") +
    Dir.glob("**/*.{bundle,so,dll,rbc,jar}") +
    Dir.glob("**/.rbx")

  clean_files.each { |path| rm_rf path }
end

test_config = proc do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

Rake::TestTask.new(:test, &test_config)

namespace :test do
  RubyMemcheck::TestTask.new(valgrind: :compile, &test_config)
end

YARD::Rake::YardocTask.new do |t|
  # Runs a server to appreciate doc after having it running
  t.after = proc do
    exec "ruby", "-run", "-e", "httpd", File.join(__dir__, "yardoc")
  end
end

task test: :compile
task default: [:clean, :test]
