# frozen_string_literal: true

require "rake/testtask"
require "rake/extensiontask"
require "ruby_memcheck"
require "bundler/gem_tasks"
require "yard"

RubyMemcheck.config(binary_name: "geos_c_impl")

# Build tasks

if RUBY_DESCRIPTION.match(/^jruby/)
  task :compile
else
  Rake::ExtensionTask.new "geos_c_impl" do |ext|
    ext.lib_dir = "lib/rgeo/geos"
  end
end

Rake::TestTask.new(:test) do |task|
  task.libs << "test"
  task.libs << "lib"
  task.test_files = FileList["test/**/*_test.rb"]
end

namespace :test do
  RubyMemcheck::TestTask.new(valgrind: :compile) do |task|
    task.libs << "test"
    task.libs << "lib"
    task.test_files = FileList["test/geos_capi/*_test.rb"]
  end
end

YARD::Rake::YardocTask.new do |t|
  # Runs a server to appreciate doc after having it running
  t.after = proc do
    exec "ruby", "-run", "-e", "httpd", File.join(__dir__, "yardoc")
  end
end

task test: :compile
task default: %i[clean test]
