
# -*- ruby -*-

require 'rubygems'
require 'rubygems/package_task'
require 'rake/testtask'
require 'rdoc/task'
require 'bundler/gem_tasks'

$:.push File.expand_path(File.dirname(__FILE__), 'lib')

version = Geos::VERSION

desc 'Test GEOS interface'
Rake::TestTask.new(:test) do |t|
  t.libs << "#{File.dirname(__FILE__)}/test"
  t.test_files = FileList['test/**/*_tests.rb']
  t.verbose = !!ENV['VERBOSE_TESTS']
  t.warning = !!ENV['WARNINGS']
end

task :default => :test

begin
  desc 'Build docs'
  Rake::RDocTask.new do |t|
    t.title = "ffi-geos #{version}"
    t.main = 'README.rdoc'
    t.rdoc_dir = 'doc'
    t.rdoc_files.include('README.rdoc', 'MIT-LICENSE', 'lib/**/*.rb')
  end
rescue LoadError
  puts 'Rake::RDocTask is not supported on this platform.'
end
