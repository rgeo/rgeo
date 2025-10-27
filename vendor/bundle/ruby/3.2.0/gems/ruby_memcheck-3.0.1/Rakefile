# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "rake/extensiontask"

Rake::TestTask.new(test: "test:compile") do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

namespace :test do
  Rake::ExtensionTask.new("ruby_memcheck_c_test_one") do |ext|
    ext.ext_dir = "test/ruby_memcheck/ext"
    ext.lib_dir = "test/ruby_memcheck/ext"
    ext.config_script = "extconf_one.rb"
  end

  Rake::ExtensionTask.new("ruby_memcheck_c_test_two") do |ext|
    ext.ext_dir = "test/ruby_memcheck/ext"
    ext.lib_dir = "test/ruby_memcheck/ext"
    ext.config_script = "extconf_two.rb"
  end
end

task default: :test
