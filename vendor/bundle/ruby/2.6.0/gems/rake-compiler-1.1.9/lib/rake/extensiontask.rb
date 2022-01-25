require "rbconfig"

require 'rake/baseextensiontask'
require "rubygems/package_task"

# Define a series of tasks to aid in the compilation of C extensions for
# gem developer/creators.

module Rake
  class ExtensionTask < BaseExtensionTask
    attr_accessor :config_script
    attr_accessor :cross_compile
    attr_writer :cross_platform
    attr_writer :cross_config_options
    attr_accessor :no_native
    attr_accessor :config_includes

    def init(name = nil, gem_spec = nil)
      super
      @config_script = 'extconf.rb'
      @source_pattern = "*.{c,cc,cpp}"
      @compiled_pattern = "*.{o,obj,so,bundle,dSYM}"
      @cross_compile = false
      @cross_config_options = []
      @cross_compiling = nil
      @no_native = (ENV["RAKE_EXTENSION_TASK_NO_NATIVE"] == "true")
      @config_includes = []
      # Default to an empty list of ruby versions for each platform
      @ruby_versions_per_platform = Hash.new { |h, k| h[k] = [] }
      @make = nil
    end

    def cross_platform
      @cross_platform ||= 'i386-mingw32'
    end

    def cross_compiling(&block)
      @cross_compiling = block if block_given?
    end

    def binary(platform = nil)
      if platform == "java"
        "#{name}.#{RbConfig::MAKEFILE_CONFIG['DLEXT']}"
      else
        super
      end
    end

    def define
      super

      unless compiled_files.empty?
        warn "WARNING: rake-compiler found compiled files in '#{@ext_dir}' directory. Please remove them."
      end

      # only gems with 'ruby' platforms are allowed to define native tasks
      define_native_tasks if !@no_native && (@gem_spec && @gem_spec.platform == 'ruby')

      # only define cross platform functionality when enabled
      return unless @cross_compile

      if cross_platform.is_a?(Array) then
        cross_platform.each { |platf| define_cross_platform_tasks(platf) }
      else
        define_cross_platform_tasks(cross_platform)
      end
    end

    def cross_config_options(for_platform=nil)
      return @cross_config_options unless for_platform

      # apply options for this platform, only
      @cross_config_options.map do |option|
        if option.kind_of?(Hash)
          option[for_platform] || []
        else
          option
        end
      end.flatten
    end

    private
    # copy other gem files to staging directory
    def define_staging_file_tasks(files, lib_path, stage_path, platf, ruby_ver)
      # lib_binary_path
      lib_binary_path = "#{lib_path}/#{File.basename(binary(platf))}"

      files.each do |gem_file|
        # ignore directories and the binary extension
        next if File.directory?(gem_file) || gem_file == lib_binary_path
        stage_file = "#{stage_path}/#{gem_file}"

        # copy each file from base to stage directory
        unless Rake::Task.task_defined?(stage_file) then
          directory File.dirname(stage_file)
          file stage_file => [File.dirname(stage_file), gem_file] do
            cp gem_file, stage_file
          end
        end

        # append each file to the copy task
        task "copy:#{@name}:#{platf}:#{ruby_ver}" => [stage_file]
      end
    end

    def define_compile_tasks(for_platform = nil, ruby_ver = RUBY_VERSION)
      # platform usage
      platf = for_platform || platform

      binary_path = binary(platf)
      binary_base_name = File.basename(binary_path)

      # lib_path
      lib_path = lib_dir

      # lib_binary_path
      lib_binary_path = "#{lib_path}/#{binary_base_name}"

      # tmp_path
      tmp_path = "#{@tmp_dir}/#{platf}/#{@name}/#{ruby_ver}"
      stage_path = "#{@tmp_dir}/#{platf}/stage"

      siteconf_path = "#{tmp_path}/.rake-compiler-siteconf.rb"
      tmp_binary_path = "#{tmp_path}/#{binary_path}"
      tmp_binary_dir_path = File.dirname(tmp_binary_path)
      stage_binary_path = "#{stage_path}/#{lib_binary_path}"
      stage_binary_dir_path = File.dirname(stage_binary_path)

      # cleanup and clobbering
      CLEAN.include(tmp_path)
      CLEAN.include(stage_path)
      CLOBBER.include(lib_binary_path)
      CLOBBER.include("#{@tmp_dir}")

      # directories we need
      directory tmp_path
      directory tmp_binary_dir_path
      directory lib_path
      directory stage_binary_dir_path

      directory File.dirname(siteconf_path)
      # Set paths for "make install" destinations
      file siteconf_path => File.dirname(siteconf_path) do
        File.open(siteconf_path, "w") do |siteconf|
          siteconf.puts "require 'rbconfig'"
          siteconf.puts "require 'mkmf'"
          siteconf.puts "dest_path = mkintpath(#{File.expand_path(lib_path).dump})"
          %w[sitearchdir sitelibdir].each do |dir|
            siteconf.puts "RbConfig::MAKEFILE_CONFIG['#{dir}'] = dest_path"
            siteconf.puts "RbConfig::CONFIG['#{dir}'] = dest_path"
          end
        end
      end

      # copy binary from temporary location to final lib
      # tmp/extension_name/extension_name.{so,bundle} => lib/
      task "copy:#{@name}:#{platf}:#{ruby_ver}" => [lib_path, tmp_binary_path, "#{tmp_path}/Makefile"] do
        # install in lib for native platform only
        unless for_platform
          sh "#{make} install target_prefix=", chdir: tmp_path
        end
      end
      # copy binary from temporary location to staging directory
      task "copy:#{@name}:#{platf}:#{ruby_ver}" => [stage_binary_dir_path, tmp_binary_path] do
        cp tmp_binary_path, stage_binary_path
      end

      # copy other gem files to staging directory
      define_staging_file_tasks(@gem_spec.files, lib_path, stage_path, platf, ruby_ver) if @gem_spec

      # binary in temporary folder depends on makefile and source files
      # tmp/extension_name/extension_name.{so,bundle}
      file tmp_binary_path => [tmp_binary_dir_path, "#{tmp_path}/Makefile"] + source_files do
        jruby_compile_msg = <<-EOF
Compiling a native C extension on JRuby. This is discouraged and a
Java extension should be preferred.
        EOF
        warn_once(jruby_compile_msg) if defined?(JRUBY_VERSION)

        chdir tmp_path do
          sh make
          if binary_path != binary_base_name
            cp binary_base_name, binary_path
          end
        end
      end

      # makefile depends of tmp_dir and config_script
      # tmp/extension_name/Makefile
      file "#{tmp_path}/Makefile" => [tmp_path, extconf, siteconf_path] do |t|
        options = @config_options.dup

        # include current directory
        include_dirs = ['.'].concat(@config_includes).uniq.join(File::PATH_SEPARATOR)
        cmd = [Gem.ruby, "-I#{include_dirs}", "-r#{File.basename(siteconf_path)}"]

        # build a relative path to extconf script
        abs_tmp_path = (Pathname.new(Dir.pwd) + tmp_path).realpath
        abs_extconf = (Pathname.new(Dir.pwd) + extconf).realpath

        # now add the extconf script
        cmd << abs_extconf.relative_path_from(abs_tmp_path)

        # fake.rb will be present if we are cross compiling
        if t.prerequisites.include?("#{tmp_path}/fake.rb") then
          options.push(*cross_config_options(platf))
        end

        # add options to command
        cmd.push(*options)

        # add any extra command line options
        unless extra_options.empty?
          cmd.push(*extra_options)
        end

        chdir tmp_path do
          # FIXME: Rake is broken for multiple arguments system() calls.
          # Add current directory to the search path of Ruby
          sh cmd.join(' ')
        end
      end

      # compile tasks
      unless Rake::Task.task_defined?('compile') then
        desc "Compile all the extensions"
        task "compile"
      end

      # compile:name
      unless Rake::Task.task_defined?("compile:#{@name}") then
        desc "Compile #{@name}"
        task "compile:#{@name}"
      end

      # Allow segmented compilation by platform (open door for 'cross compile')
      task "compile:#{@name}:#{platf}" => ["copy:#{@name}:#{platf}:#{ruby_ver}"]
      task "compile:#{platf}" => ["compile:#{@name}:#{platf}"]

      # Only add this extension to the compile chain if current
      # platform matches the indicated one.
      if platf == RUBY_PLATFORM then
        # ensure file is always copied
        file lib_binary_path => ["copy:#{name}:#{platf}:#{ruby_ver}"]

        task "compile:#{@name}" => ["compile:#{@name}:#{platf}"]
        task "compile" => ["compile:#{platf}"]
      end
    end

    def define_native_tasks(for_platform = nil, ruby_ver = RUBY_VERSION, callback = nil)
      platf = for_platform || platform

      # tmp_path
      stage_path = "#{@tmp_dir}/#{platf}/stage"

      # lib_path
      lib_path = lib_dir

      # lib_binary_path
      lib_binary_path = "#{lib_path}/#{File.basename(binary(platf))}"

      # Update compiled platform/version combinations
      @ruby_versions_per_platform[platf] << ruby_ver

      # create 'native:gem_name' and chain it to 'native' task
      unless Rake::Task.task_defined?("native:#{@gem_spec.name}:#{platf}")
        task "native:#{@gem_spec.name}:#{platf}" do |t|
          # FIXME: workaround Gem::Specification limitation around cache_file:
          # http://github.com/rubygems/rubygems/issues/78
          spec = gem_spec.dup
          spec.instance_variable_set(:"@cache_file", nil) if spec.respond_to?(:cache_file)

          # adjust to specified platform
          spec.platform = Gem::Platform.new(platf)

          # set ruby version constraints
          ruby_versions = @ruby_versions_per_platform[platf]
          sorted_ruby_versions = ruby_versions.sort_by do |ruby_version|
            ruby_version.split(".").collect(&:to_i)
          end
          spec.required_ruby_version = [
            ">= #{ruby_api_version(sorted_ruby_versions.first)}",
            "< #{ruby_api_version(sorted_ruby_versions.last).succ}.dev"
          ]

          # clear the extensions defined in the specs
          spec.extensions.clear

          # add the binaries that this task depends on
          ext_files = []

          # go through native prerequisites and grab the real extension files from there
          t.prerequisites.each do |ext|
            # strip stage path and keep lib/... only
            ext_files << ext.sub(stage_path+"/", '')
          end

          # include the files in the gem specification
          spec.files += ext_files

          # expose gem specification for customization
          callback.call(spec) if callback

          # Generate a package for this gem
          pkg = Gem::PackageTask.new(spec) do |p|
            p.need_zip = false
            p.need_tar = false
            # Do not copy any files per PackageTask, because
            # we need the files from the staging directory
            p.package_files.clear
          end

          # copy other gem files to staging directory if added by the callback
          define_staging_file_tasks(spec.files, lib_path, stage_path, platf, ruby_ver)

          # Copy from staging directory to gem package directory.
          # This is derived from the code of Gem::PackageTask
          # but uses stage_path as source directory.
          stage_files = spec.files.map do |gem_file|
            File.join(stage_path, gem_file)
          end
          file pkg.package_dir_path => stage_files do
            mkdir_p pkg.package_dir rescue nil
            spec.files.each do |ft|
              fn = File.join(stage_path, ft)
              f = File.join(pkg.package_dir_path, ft)
              fdir = File.dirname(f)
              mkdir_p(fdir) if !File.exist?(fdir)
              if File.directory?(fn)
                mkdir_p(f)
              else
                rm_f f
                safe_ln(fn, f)
              end
            end
          end
        end
      end

      # add binaries to the dependency chain
      task "native:#{@gem_spec.name}:#{platf}" => ["#{stage_path}/#{lib_binary_path}"]

      # ensure the extension get copied
      unless Rake::Task.task_defined?(lib_binary_path) then
        file lib_binary_path => ["copy:#{@name}:#{platf}:#{ruby_ver}"]
      end
      file "#{stage_path}/#{lib_binary_path}" => ["copy:#{@name}:#{platf}:#{ruby_ver}"]

      # Allow segmented packaging by platform (open door for 'cross compile')
      task "native:#{platf}" => ["native:#{@gem_spec.name}:#{platf}"]

      # Only add this extension to the compile chain if current
      # platform matches the indicated one.
      if platf == RUBY_PLATFORM then
        task "native:#{@gem_spec.name}" => ["native:#{@gem_spec.name}:#{platf}"]
        task "native" => ["native:#{platf}"]
      end
    end

    def define_cross_platform_tasks(for_platform)
      if ruby_vers = ENV['RUBY_CC_VERSION']
        ruby_vers = ENV['RUBY_CC_VERSION'].split(':')
      else
        ruby_vers = [RUBY_VERSION]
      end

      multi = (ruby_vers.size > 1) ? true : false

      ruby_vers.each do |version|
        # save original lib_dir
        orig_lib_dir = @lib_dir

        # tweak lib directory only when targeting multiple versions
        if multi then
          version =~ /(\d+\.\d+)/
          @lib_dir = "#{@lib_dir}/#{$1}"
        end

        define_cross_platform_tasks_with_version(for_platform, version)

        # restore lib_dir
        @lib_dir = orig_lib_dir
      end
    end

    def define_cross_platform_tasks_with_version(for_platform, ruby_ver)
      config_path = File.expand_path("~/.rake-compiler/config.yml")

      # warn the user about the need of configuration to use cross compilation.
      unless File.exist?(config_path)
        define_dummy_cross_platform_tasks
        return
      end

      config_file = YAML.load_file(config_path)

      # tmp_path
      tmp_path = "#{@tmp_dir}/#{for_platform}/#{@name}/#{ruby_ver}"

      # lib_path
      lib_path = lib_dir

      # lib_binary_path
      lib_binary_path = "#{lib_path}/#{File.basename(binary(for_platform))}"

      unless rbconfig_file = config_file["rbconfig-#{for_platform}-#{ruby_ver}"] then
        warn "no configuration section for specified version of Ruby (rbconfig-#{for_platform}-#{ruby_ver})"
        return
      end

      # mkmf
      mkmf_file = File.expand_path(File.join(File.dirname(rbconfig_file), '..', 'mkmf.rb'))

      # define compilation tasks for cross platform!
      define_compile_tasks(for_platform, ruby_ver)

      # chain fake.rb and mkmf.rb to Makefile generation
      file "#{tmp_path}/Makefile" => ["#{tmp_path}/fake.rb",
                                      "#{tmp_path}/mkmf.rb"]

      # copy the rbconfig from the cross-ruby location and
      # genearte fake.rb for different ruby versions
      file "#{tmp_path}/fake.rb" => [rbconfig_file] do |t|
        File.open(t.name, 'w') do |f|
          # Keep the original RbConfig::CONFIG["ENABLE_SHARED"] to use
          # the same RubyGems extension directory. See also
          # Gem::BasicSpecificaion#extenions_dir and
          # Gem.extension_api_version.
          #
          # if RbConfig::CONFIG["ENABLE_SHARED"] == "no"
          #   "extensions/x86_64-linux/2.5.0-static"
          # else
          #   "extensions/x86_64-linux/2.5.0"
          # end
          f.puts("require 'rbconfig'")
          f.puts("original_enable_shared = RbConfig::CONFIG['ENABLE_SHARED']")
          f.puts(fake_rb(for_platform, ruby_ver))
          f.puts(File.read(t.prerequisites.first))
          f.puts("RbConfig::CONFIG['ENABLE_SHARED'] = original_enable_shared")
        end
      end

      # copy mkmf from cross-ruby location
      file "#{tmp_path}/mkmf.rb" => [mkmf_file] do |t|
        File.open(t.name, 'w') do |f|
          content = File.read(t.prerequisites.first)
          content.sub!(/^(require ')rbconfig(')$/, '\\1fake\\2')
          if ruby_ver < "1.9" && "1.9" <= RUBY_VERSION
            content.sub!(/^(      break )\*(defaults)$/, '\\1\\2.first')
            content.sub!(/^(    return )\*(defaults)$/, '\\1\\2.first')
            content.sub!(/^(  mfile\.)print( configuration\(srcprefix\))$/, '\\1puts\\2')
          end
          f.write content
        end
      end

      # now define native tasks for cross compiled files
      if @gem_spec && @gem_spec.platform == 'ruby' then
        define_native_tasks(for_platform, ruby_ver, @cross_compiling)
      end

      # create cross task
      task 'cross' do
        # clear compile dependencies
        Rake::Task['compile'].prerequisites.reject! { |t| !compiles_cross_platform.include?(t) }

        # chain the cross platform ones
        task 'compile' => ["compile:#{for_platform}"]

        # clear lib/binary dependencies and trigger cross platform ones
        # check if lib/binary is defined (damn bundle versus so versus dll)
        if Rake::Task.task_defined?(lib_binary_path) then
          Rake::Task[lib_binary_path].prerequisites.clear
        end

        # FIXME: targeting multiple platforms copies the file twice
        file lib_binary_path => ["copy:#{@name}:#{for_platform}:#{ruby_ver}"]

        # if everything for native task is in place
        if @gem_spec && @gem_spec.platform == 'ruby' then
          # double check: only cross platform native tasks should be here
          # FIXME: Sooo brittle
          Rake::Task['native'].prerequisites.reject! { |t| !natives_cross_platform.include?(t) }
          task 'native' => ["native:#{for_platform}"]
        end
      end
    end

    def define_dummy_cross_platform_tasks
      task 'cross' do
        Rake::Task['compile'].clear
        task 'compile' do
          raise "rake-compiler must be configured first to enable cross-compilation"
        end
      end
    end

    def extconf
      "#{@ext_dir}/#{@config_script}"
    end

    def make
      unless @make
        @make =
          if RUBY_PLATFORM =~ /mswin/ then
            'nmake'
          else
            ENV['MAKE'] || find_make
          end
      end

      unless @make
        raise "Couldn't find a suitable `make` tool. Use `MAKE` env to set an alternative."
      end

      @make
    end

    def find_make
      candidates = ["gmake", "make"]
      paths = (ENV["PATH"] || "").split(File::PATH_SEPARATOR)

      exeext = RbConfig::CONFIG["EXEEXT"]
      candidates.each do |candidate|
        paths.each do |path|
          make = File.join(path, "#{candidate}#{exeext}")
          return make if File.executable?(make)
        end
      end

      nil
    end

    def compiled_files
      FileList["#{@ext_dir}/#{@compiled_pattern}"]
    end

    def compiles_cross_platform
      [*@cross_platform].map { |p| "compile:#{p}" }
    end

    def natives_cross_platform
      [*@cross_platform].map { |p| "native:#{p}" }
    end

    def ruby_api_version(ruby_version)
      ruby_version.split(".")[0, 2].join(".")
    end

    def fake_rb(platform, version)
      <<-FAKE_RB
        # Pre-load resolver library before faking, in order to avoid error
        # "cannot load such file -- win32/resolv" when it is required later on.
        # See also: https://github.com/tjschuck/rake-compiler-dev-box/issues/5
        require 'resolv'
        require 'rbconfig'

        class Object
          remove_const :RbConfig
          remove_const :RUBY_PLATFORM
          remove_const :RUBY_VERSION
          remove_const :RUBY_DESCRIPTION if defined?(RUBY_DESCRIPTION)
          RUBY_PLATFORM = "#{platform}"
          RUBY_VERSION = "#{version}"
          RUBY_DESCRIPTION = "ruby \#{RUBY_VERSION} (\#{RUBY_RELEASE_DATE}) [\#{RUBY_PLATFORM}]"
        end
        if RUBY_PLATFORM =~ /mswin|bccwin|mingw/
          class File
            remove_const :ALT_SEPARATOR
            ALT_SEPARATOR = "\\\\"
          end
        end

        posthook = proc do
          $ruby = "#{Gem.ruby}"
          untrace_var(:$ruby, posthook)
        end
        trace_var(:$ruby, posthook)
FAKE_RB
    end
  end
end
