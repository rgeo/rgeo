require "rake/extensiontask"
# Load config if present

config_path_ = ::File.expand_path("rakefile_config.rb", ::File.dirname(__FILE__))
load(config_path_) if ::File.exist?(config_path_)
RAKEFILE_CONFIG = {} unless defined?(::RAKEFILE_CONFIG)

# Gemspec

gemspec_ = eval(::File.read(::Dir.glob("*.gemspec").first))
release_gemspec_ = eval(::File.read(::Dir.glob("*.gemspec").first))
release_gemspec_.version = gemspec_.version.to_s.sub(/\.nonrelease$/, "")

require "bundler/gem_tasks"

# Directories

doc_directory_ = ::RAKEFILE_CONFIG[:doc_directory] || "doc"
pkg_directory_ = ::RAKEFILE_CONFIG[:pkg_directory] || "pkg"
tmp_directory_ = ::RAKEFILE_CONFIG[:tmp_directory] || "tmp"

# Build tasks

if ::RUBY_DESCRIPTION.match /^jruby/
  task :compile
else
  Rake::ExtensionTask.new "geos_c_impl" do |ext|
    ext.lib_dir = "lib/rgeo/geos"
  end

  Rake::ExtensionTask.new "proj4_c_impl" do |ext|
    ext.lib_dir = "lib/rgeo/coord_sys"
  end
end

# Clean task

clean_files_ = [doc_directory_, pkg_directory_, tmp_directory_] +
  ::Dir.glob("ext/**/Makefile*") +
  ::Dir.glob("ext/**/*.{o,class,log,dSYM}") +
  ::Dir.glob("**/*.{bundle,so,dll,rbc,jar}") +
  ::Dir.glob("**/.rbx") +
  (::RAKEFILE_CONFIG[:extra_clean_files] || [])
task :clean do
  clean_files_.each { |path_| rm_rf path_ }
end
#
# RDoc tasks

task build_rdoc: "#{doc_directory_}/index.html"
all_rdoc_files_ = ::Dir.glob("lib/**/*.rb") + gemspec_.extra_rdoc_files
main_rdoc_file_ = ::RAKEFILE_CONFIG[:main_rdoc_file]
main_rdoc_file_ = "README.rdoc" if !main_rdoc_file_ && ::File.readable?("README.rdoc")
main_rdoc_file_ = ::Dir.glob("*.rdoc").first unless main_rdoc_file_
file "#{doc_directory_}/index.html" => all_rdoc_files_ do
  begin
    rm_r doc_directory_
  rescue
    nil
  end
  args_ = []
  args_ << "-o" << doc_directory_
  args_ << "--main" << main_rdoc_file_ if main_rdoc_file_
  args_ << "--title" << "#{::RAKEFILE_CONFIG[:product_visible_name] || gemspec_.name.capitalize} #{release_gemspec_.version} Documentation"
  args_ << "-f" << "darkfish"
  args_ << "--verbose" if ::ENV["VERBOSE"]
  gem "rdoc"
  require "rdoc/rdoc"
  ::RDoc::RDoc.new.document(args_ + all_rdoc_files_)
end

task build_other: [:build]

# Unit test task

task test: [:compile] do
  $LOAD_PATH.unshift(::File.expand_path("lib", ::File.dirname(__FILE__)))
  if ::ENV["TESTCASE"]
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
task default: [:clean, :test]
