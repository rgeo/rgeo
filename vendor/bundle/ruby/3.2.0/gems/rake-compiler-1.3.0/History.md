### 1.3.0 / 2025-04-13

* Improvements:
  * GH-247: Java: Added support for the `JAVA_HOME` environment variable.
    * Patch by MSP-Greg

* Thanks:
  * MSP-Greg

### 1.2.9 / 2024-12-31

* Improvements:
  * GH-242: Java: Changed to the default target Java to 8.
    * Patch by Charles Oliver Nutter

  * GH-244: Added support for double-digit version segments in Ruby
    version such as "2.6.10".
    * Patch by Mike Dalessio

  * GH-240: Reverted "stopped to generate tasks for nonexistent files"
    in 1.2.8. Users must specify valid `spec.files`.

* Thanks:
  * Charles Oliver Nutter
  * Mike Dalessio

### 1.2.8 / 2024-10-04

* Improvements:
  * GH-240: Stopped to generate tasks for nonexistent files.
    * Patch by y-yagi

* Thanks:
  * y-yagi

### 1.2.7 / 2024-01-31

* Improvements:
  * GH-236: Added support for setting `required_rubygems_version` for
    fat-gems that specify the Linux libc.
    [Patch by Mike Dalessio]

* Thanks:
  * Mike Dalessio

### 1.2.6 / 2024-01-23

* Improvements:
  * GH-232 GH-233: Changed to use `require` instead of copying content
    of `rbconfig.rb` for `__FILE__` in `rbconfig.rb`.
    [Patch by ParadoxV5]

* Thanks:
  * ParadoxV5

### 1.2.5 / 2023-08-03

* Fixes:
  * GH-225: Fixed a bug that `rake compile` may not work on Windows.
    [Reported by Lukasz Suleja]
  * GH-224 GH-226: Fixed a bug that 1.2.4 doesn't work on Ruby < 2.6.
    [Reported by Ivo Anjo]
    [Patch by Mike Dalessio and Akira Matsuda separately]

* Thanks:
  * Lukasz Suleja
  * Ivo Anjo
  * Mike Dalessio
  * Akira Matsuda

### 1.2.4 / 2023-08-01

* Enhancements:
  * GH-221: Enabled syntax highlighting in documents.
    [Patch by Ryo Nakamura]
  * GH-202 GH-222: Use environment variables to set install paths.
    [Reported by Brandon Fish]
    [Patch by Michael Go]

* Thanks:
  * Ryo Nakamura
  * Brandon Fish
  * Michael Go

### 1.2.3 / 2023-05-30

* Enhancements:
  * GH-217: Added support for `nil` in build options again.
    [Patch by Mike Dalessio]

* Fixes:
  * GH-219: Fixed a typo in documentation.
    [Patch by y-yagi]

* Thanks:
  * Mike Dalessio
  * y-yagi

### 1.2.2 / 2023-05-25

* Enhancements:
  * GH-211: Added `extra_sources` that is for dynamic sources.
    [Patch by James Tucker]
  * GH-213: Stopped using `--release` on Java 8.
    [Patch by James Pavel Rosický]
  * GH-215: Added support for extra options with space.
    [Reported by Jun Aruga]

* Fixes:
  * GH-212: Fixed a typo in documentation.
    [Patch by Jan-Benedikt Jagusch]

* Thanks:
  * James Tucker
  * Jan-Benedikt Jagusch
  * Pavel Rosický
  * Jun Aruga

### 1.2.1 / 2022-12-16

* Enhancements:
  * GH-209: Added support for RubyGems 3.3.21 or later.
    [Patch by Mike Dalessio]

* Fixes:
  * GH-208: Fixed a typo in documentation.
    [Patch by Garen Torikian]

* Thanks:
  * Garen Torikian
  * Mike Dalessio

### 1.2.0 / 2022-04-15

* Enhancements:
  * Defer requiring `yaml`.
    [ruby/stringio#21](https://github.com/ruby/stringio/issues/21)

### 1.1.9 / 2022-01-22

* Enhancements:
  * Add support for `--release` option to build JRuby extension.
    [#200](https://github.com/rake-compiler/rake-compiler/issues/200) [Reported by Pavel Rosický]
    [#201](https://github.com/rake-compiler/rake-compiler/issues/201) [Patch by Satoshi Tagomori]

### 1.1.8 / 2022-01-18

* Fixes:
  * Fix wrong `required_ruby_version` when some `RUBY_CC_VERSION`s are missing.
    [#198](https://github.com/rake-compiler/rake-compiler/issues/198) [Patch by Lars Kanis]

### 1.1.7 / 2022-01-04

* Fixes:
  * Fix binary paths for staging and clobber.
    [#197](https://github.com/rake-compiler/rake-compiler/issues/197) [Patch by konsolebox]

### 1.1.6 / 2021-12-12

* Fixes:
  * Fix a regression bug that `Symbol` can't be used for `name` of `Rake::ExtensionTask.new`.

### 1.1.5 / 2021-12-12

* Fixes:
  * Fix a regression bug that wrong install location is used when name that includes `/` is specified to `Rake::ExtensionTask.new`.
    [#196](https://github.com/rake-compiler/rake-compiler/issues/196) [Reported by konsolebox]

### 1.1.4 / 2021-12-11

* Fixes:
  * Fix a regression bug that installed gem can't be found on cross compile.
    [#195](https://github.com/rake-compiler/rake-compiler/issues/195) [Reported by Mike Dalessio]

### 1.1.3 / 2021-12-08

* Fixes:
  * Fix a regression bug that wrong install location is used.
    [#194](https://github.com/rake-compiler/rake-compiler/issues/194) [Reported by Andrew Kane]

### 1.1.2 / 2021-12-07

* Changes:
  * Use .tar.gz instead of .tar.bz2 for Ruby archive.
    [#179](https://github.com/rake-compiler/rake-compiler/pull/179) [Patch by Masaki Hara]
  * Stop removing `CC`, `CXX`, `CPPFLAGS` and `LDFLAGS` environment variables for cross-build.
    [#182](https://github.com/rake-compiler/rake-compiler/pull/182) [Patch by Lars Kanis]
  * Remove IronRuby related message.
    [#184](https://github.com/rake-compiler/rake-compiler/pull/184) [Patch by Thomas E Enebo]
  * Suppress a warning.
    [#185](https://github.com/rake-compiler/rake-compiler/pull/185) [Patch by Olle Jonsson]
  * Rename `History.txt` to `History.md`.
    [#174](https://github.com/rake-compiler/rake-compiler/pull/174) [Patch by MSP-Greg]
  * Use `make install` instead of copying artifacts manually.
    [#191](https://github.com/rake-compiler/rake-compiler/pull/191) [Patch by Lars Kanis]

* Enhancements:
  * Add support for building cross rubies in parallel.
    [#169](https://github.com/rake-compiler/rake-compiler/pull/169) [Patch by Lars Kanis]
  * Use `RAKE_EXTENSION_TASK_NO_NATIVE` environment variable as the default `no_native` value.
  * Add support for `rake native gem` without `cross`.
    [#166](https://github.com/rake-compiler/rake-compiler/pull/166) [Patch by Lars Kanis]

### 1.1.1 / 2020-07-10

* Changes:
  * Bump the default Java bytecode to 1.7.
    [#172](https://github.com/rake-compiler/rake-compiler/pull/172) [Patch by Charles Oliver Nutter]

* Enhancements:
  * Add support for finding x86_64 MinGW GCC.
    [#164](https://github.com/rake-compiler/rake-compiler/pull/164) [Patch by Lars Kanis]
  * Strip cross compiled shared library automatically.
    [#165](https://github.com/rake-compiler/rake-compiler/pull/165) [Patch by Lars Kanis]

### 1.1.0 / 2019-12-25

* Bugfixes:
  * Fix a bug that JavaExtenstionTask can't build anything.
    [#163](https://github.com/rake-compiler/rake-compiler/issues/163) [Reported by Kai Kuchenbecker]

### 1.0.9 / 2019-12-23

* Changes:
  * Use "-Xlint" option for JRuby native extension by default.
    [#158](https://github.com/rake-compiler/rake-compiler/pull/158) [Patch by Stephen George]

* Enhancements:
  * Make customizable compiler Xlint option for JRuby native extension.
    [#118](https://github.com/rake-compiler/rake-compiler/pull/118) [Patch by Hiroshi Hatake]
  * Add support for Ruby 2.7.
    [#161](https://github.com/rake-compiler/rake-compiler/pull/161) [Reported by Masaki Hara]

### 1.0.8 / 2019-09-21

* Enhancements:
  * Added Rake::JavaExtensionTask#encoding= to pass the -encoding option to
    javac.
    [#157](https://github.com/rake-compiler/rake-compiler/pull/157) [Patch by Tiago Dias]

* Bugfixes:
  * Drop EOL'd rubyforge_project directive from .gemspec.
    [#155](https://github.com/rake-compiler/rake-compiler/pull/155) [Patch by Olle Jonsson]

### 1.0.7 / 2019-01-04

* Bugfixes:
  * Fix a bug that JRuby class path detection is failed on
    cross-compilation.
    [#149](https://github.com/rake-compiler/rake-compiler/issues/149) [#151](https://github.com/rake-compiler/rake-compiler/pull/151) [Reported by Chalupa Petr][Patch by Prashant Vithani]

### 1.0.6 / 2018-12-23

* Enhancements:
  * Stop to make unreleased Ruby installable.
    [#150](https://github.com/rake-compiler/rake-compiler/issues/150) [Reported by MSP-Greg]

### 1.0.5 / 2018-08-31

* Enhancements:
  * Improve JRuby class pass detection.
    [#147](https://github.com/rake-compiler/rake-compiler/pull/147) [Patch by Prashant Vithani]
  * Update the default source and target versions to Java 6.
    [#148](https://github.com/rake-compiler/rake-compiler/pull/148) [Patch by Prashant Vithani]

### 1.0.4 / 2017-05-27

* Enhancements:
  * Migrate to RSpec 3 from RSpec 2.
  * Add more tests.
    [#140](https://github.com/rake-compiler/rake-compiler/pull/140) [Patch by Lars Kanis]
  * Support C++ source files by default.
    [#141](https://github.com/rake-compiler/rake-compiler/pull/141) [Patch by Takashi Kokubun]
  * Suppress warnings.
    [#142](https://github.com/rake-compiler/rake-compiler/pull/142) [Patch by Akira Matsuda]

### 1.0.3 / 2016-12-02

* Enhancements:
  * Support specifying required Ruby versions.
    [#137](https://github.com/rake-compiler/rake-compiler/pull/137) [Patch by Lars Kanis]

### 1.0.2 / 2016-11-13

* Bugfixes:
  * Fix Ruby version detection example code in README.
    [#135](https://github.com/rake-compiler/rake-compiler/pull/135) [Patch by Nicolas Noble]
  * Fix version detection.
    [#136](https://github.com/rake-compiler/rake-compiler/pull/136) [Patch by Lars Kanis]

### 1.0.1 / 2016-06-21

* Bugfixes:
  * Add missing dependency.

### 1.0.0 / 2016-06-21

* Enhancements:
  * Really support extension in sub directory.

### 0.9.9 / 2016-05-10

* Bugfixes:
  * Support Symbol as extension name again.
    [#134](https://github.com/rake-compiler/rake-compiler/pull/134) [Patch by Takashi Kokubun]

### 0.9.8 / 2016-04-29

* Enhancements:
  * Support extension in sub directory.
    [#128](https://github.com/rake-compiler/rake-compiler/pull/128), [#129](https://github.com/rake-compiler/rake-compiler/pull/129) [Patch by Kenta Murata]

### 0.9.7 / 2016-03-16

* Bugfixes:
  * May fix "make" detection on Windows.
    [#123](https://github.com/rake-compiler/rake-compiler/issues/123) [Reported by Aaron Stone]

### 0.9.6 / 2016-03-04

* Enhancements:
  * Add more descriptions into README.
    Closes [#105](https://github.com/rake-compiler/rake-compiler/pull/105) [Patch by Aaron Stone]
  * Remove needless executable bits.
    Closes [#107](https://github.com/rake-compiler/rake-compiler/pull/107) [Patch by Thibault Jouan]
  * Update .gitignore.
    Closes [#108](https://github.com/rake-compiler/rake-compiler/pull/108) [Patch by Thibault Jouan]
  * Improve "make" detection on some platforms such as FreeBSD.
    Closes [#109](https://github.com/rake-compiler/rake-compiler/pull/109) [Patch by Thibault Jouan]
  * Enable cucumber steps for POSIX on *BSD.
    Closes [#110](https://github.com/rake-compiler/rake-compiler/pull/110) [Patch by Thibault Jouan]
  * Stop to build bundled extensions.
  * Add description about CLI option into README.
    Closes [#115](https://github.com/rake-compiler/rake-compiler/pull/115) [Patch by Richard Michael]
  * Update description about using rake-compiler on virtual machine in
    README.
    Closes [#116](https://github.com/rake-compiler/rake-compiler/pull/116), [#117](https://github.com/rake-compiler/rake-compiler/pull/117) [Patch by Lars Kanis]
  * Update fake mechanism to be compatible with Bundler.
    Closes [#121](https://github.com/rake-compiler/rake-compiler/pull/121) [Patch by Lars Kanis]

* Bugfixes:
  * Fix typos in README.
    Closes [#102](https://github.com/rake-compiler/rake-compiler/pull/102), [#103](https://github.com/rake-compiler/rake-compiler/pull/103) [Patch by Robert Fletcher]

### 0.9.5 / 2015-01-03

* Enhancements:
  * Support adding bundled files in cross_compiling block.
    Closes [#100](https://github.com/rake-compiler/rake-compiler/pull/100) [Patch by Aaron Stone]

### 0.9.4 / 2014-12-28

* Notes:
  * Change maintainer to Kouhei Sutou from Luis Lavena.
    Thanks Luis Lavena for your great works!
  * Change repository to https://github.com/rake-compiler/rake-compiler
    from https://github.com/luislavena/rake-compiler .

* Bugfixes:
  * Loose RubyGems dependency a little bit to ease old Debian/Ubuntu.
    Closes [#93](https://github.com/rake-compiler/rake-compiler/issues/93)

### 0.9.3 / 2014-08-03

* Bugfixes:
  * Fix specs to run (and pass) on Ruby 2.1 and beyond.
    Pull [#94](https://github.com/rake-compiler/rake-compiler/pull/94) [hggh]

### 0.9.2 / 2013-11-14

* Bugfixes:
  * Pre-load resolver to avoid Bundler blow up during cross-compilation
    Pull [#83](https://github.com/rake-compiler/rake-compiler/pull/83) [larskanis]

### 0.9.1 / 2013-08-03

* Bugfixes:
  * Restore compatibility with RubyGems platforms for cross-compilation
    (i386-mingw32 and x86-mingw32 are the same and supported)

### 0.9.0 / 2013-08-03

* Enhancements:
  * Add support for cross-builds and multiple platforms (x86/x64).
    Pull [#74](https://github.com/rake-compiler/rake-compiler/pull/74) [larskanis]

    ```text
    $ rake-compiler cross-ruby VERSION=1.8.7-p371
    $ rake-compiler cross-ruby VERSION=1.9.3-p392
    $ rake-compiler cross-ruby VERSION=2.0.0-p0
    $ rake-compiler cross-ruby VERSION=2.0.0-p0 HOST=x86_64-w64-mingw32
    $ rake cross compile RUBY_CC_VERSION=1.8.7:1.9.3:2.0.0

    # Rakefile
    ext.cross_platform = %w[i386-mingw32 x64-mingw32]
    ```

  * Support for cross-platform specific options. Pull [#74](https://github.com/rake-compiler/rake-compiler/pull/74) [larskanis]

    ```ruby
    # Rakefile
    ext.cross_config_options << "--with-common-option"
    ext.cross_config_options << {"x64-mingw32" => "--enable-64bits"}
    ```

* Bugfixes:
  * Correct fat-gems support caused by RubyGems issues. Pull [#76](https://github.com/rake-compiler/rake-compiler/pull/76) [knu]

* Deprecations:
  * Requires minimum Ruby 1.8.7 and RubyGems 1.8.25
  * Usage of 'i386-mswin32' needs to be changed to 'i386-mswin32-60'

### 0.9.0.pre.1 / 2013-05-05

See 0.9.0 changes.

### 0.8.3 / 2013-02-16

* Bugfixes:
  * Support FreeBSD 'mingw32-gcc' cross compiler. Closes [#72](https://github.com/rake-compiler/rake-compiler/pull/72) [knu]

### 0.8.2 / 2013-01-11

* Bugfixes:
  * Unset CC, LDFLAGS and CPPFLAGS prior cross-compiling. Closes [#55](https://github.com/rake-compiler/rake-compiler/issues/55)

### 0.8.1 / 2012-04-15

* Bugfixes:
  * Raise error when either make or gmake could be found. Closes [#53](https://github.com/rake-compiler/rake-compiler/issues/53), [#54](https://github.com/rake-compiler/rake-compiler/pull/54)

### 0.8.0 / 2012-01-08

* Enhancements:
  * Invocation from command line now support extra options similar to RubyGems.
    Closes [#4](https://github.com/rake-compiler/rake-compiler/issues/4) from Pull [#47](https://github.com/rake-compiler/rake-compiler/pull/47) [jonforums]

        $ rake compile -- --with-opt-dir=/opt/local

* Bugfixes:
  * Only emit cross-compilation warnings for C when `cross` is invoked.
    Closes [#16](https://github.com/rake-compiler/rake-compiler/issues/16) from Pull [#48](https://github.com/rake-compiler/rake-compiler/pull/48) [mvz]
  * Only emit warnings when invoking cross-compilation tasks for JRuby.
    Pull [#45](https://github.com/rake-compiler/rake-compiler/pull/45) [jfirebaugh]
  * Use x86 MinGW cross-compiler. Pull [#49](https://github.com/rake-compiler/rake-compiler/pull/49) [larskanis]

### 0.7.9 / 2011-06-08

* Enhancements:
  * Consistently use RubyGems features available since version 1.3.2 and avoid
    deprecation warnings with Rake > 0.8.7.

* Bugfixes:
  * Use correct platform in fake.rb. Pull [#39](https://github.com/rake-compiler/rake-compiler/pull/39) [kou]
  * Workaround Gem::Specification and Gem::PackageTask limitations. Closes [#43](https://github.com/rake-compiler/rake-compiler/issues/43)

### 0.7.8 / 2011-04-26

* Enhancements:
  * Bump default cross-ruby version to 1.8.7-p334.
  * ExtensionTask now support config_includes to load additional directories.
    [jfinkhaeuser]

    ```ruby
    Rake::ExtensionTask.new("myext", GEM_SPEC) do |ext|
      ext.config_includes << File.expand_path("my", "custom", "dir")
    end
    ```

* Bugfixes:
  * Warn if compiled files exists in extension's source directory. Closes [#35](https://github.com/rake-compiler/rake-compiler/issues/35)
  * Workaround issue with WINE using proper build option. Closes [#37](https://github.com/rake-compiler/rake-compiler/issues/37)
  * Use FileUtils#install instead of cp. Closes [#33](https://github.com/rake-compiler/rake-compiler/issues/33) [Eric Wong]
  * Update README instructions for OSX. Closes [#29](https://github.com/rake-compiler/rake-compiler/issues/29) [tmm1]

### 0.7.7 / 2011-04-04

* Bugfixes:
  * Use Winsock2 as default to match Ruby 1.9.2 library linking.

### 0.7.6 / 2011-02-04

* Bugfixes:
  * Prefer Psych over Syck for YAML parsing on Ruby 1.9.2. [tenderlove]

### 0.7.5 / 2010-11-25

* Enhancements:
  * Promoted stable version for cross-compilation to 1.8.6-p398. Closes [#19](https://github.com/rake-compiler/rake-compiler/issues/19)

* Bugfixes:
  * Generate a fake.rb compatible with Ruby 1.9.2. Closes [#25](https://github.com/rake-compiler/rake-compiler/issues/25)
  * fake.rb will not try to mimic Ruby's own fake to the letter. Closes [#28](https://github.com/rake-compiler/rake-compiler/issues/28)
  * Expand symlinks for tmp_dir. Closes [#24](https://github.com/rake-compiler/rake-compiler/issues/24)
  * Silence make output during rake-compiler invocation.
  * Usage of Gem.ruby instead of RbConfig ruby_install_name
    This solve issues with ruby vs. ruby.exe and jruby.exe

* Experimental:
  * Allow setting of HOST during cross-compilation. This enable usage
    of mingw-w64 compiler and not the first one found in the PATH.

        rake-compiler cross-ruby VERSION=1.9.2-p0 HOST=i686-w64-mingw32
        rake-compiler cross-ruby HOST=i386-mingw32 (OSX mingw32 port)
        rake-compiler cross-ruby HOST=i586-pc-mingw32 (Debian/Ubuntu mingw32)

### 0.7.1 / 2010-08-07

* Bugfixes:
  * Update gem files to make "gem install -t" works. Closes [#14](https://github.com/rake-compiler/rake-compiler/issues/14)
  * Update mocks to work under 1.8.7. Closes [#15](https://github.com/rake-compiler/rake-compiler/issues/15) [luisparravicini]
  * Do not allow cross-ruby be executed under Windows. Closes [#22](https://github.com/rake-compiler/rake-compiler/issues/22)

* Experimental:
  * Allow JRuby to compile C extensions [timfel].
    It is now possible compile C extensions using latest JRuby. Offered
    in experimental mode since JRuby cext hasn't been officially released.

### 0.7.0 / 2009-12-08

* Enhancements
  * Allow generation of JRuby extensions. Thanks to Alex Coles (myabc) for the
    contribution.
    This will allow, with proper JDK tools, cross compilation of JRuby gems
    from MRI.

    ```ruby
      Rake::JavaExtensionTask.new('my_java_extension', GEM_SPEC) do |ext|
        # most of ExtensionTask options can be used
        # plus, java_compiling:
        ext.java_compiling do |gem_spec|
          gem_spec.post_install_message = "This is a native JRuby gem!"
        end
      end
    ```

    Please note that cross-compiling JRuby gems requires either JRUBY_HOME or
    JRUBY_PARENT_CLASSPATH environment variables being properly set.

  * Allow alteration of the Gem Specification when cross compiling. Closes [#3](https://github.com/rake-compiler/rake-compiler/issues/3)
    This is useful to indicate a custom requirement message, like DLLs
    installation or similar.

    ```ruby
    Rake::ExtensionTask.new('my_extension', GEM_SPEC) do |ext|
      ext.cross_compile = true
      # ...
      ext.cross_compiling do |gem_spec|
        gem_spec.post_install_message = "You've installed a binary version of this gem"
      end
    end
    ```

* Bugfixes
  * Detect GNU make independently of distribution based naming.
    Thanks to flori for patches.
  * Usage of #dup to duplicate gemspec instead of YAML dumping.
  * No longer support Ruby older than 1.8.6
  * No longer support RubyGems older than 1.3.5
  * Force definition of binary directory and executables. Closes [#11](https://github.com/rake-compiler/rake-compiler/issues/11)
  * Workaround path with spaces issues using relative paths. Closes [#6](https://github.com/rake-compiler/rake-compiler/issues/6)
  * Removed gemspec, GitHub gems no more

* Known issues
  * Usage of rake-compiler under projects with Jeweler requires some tweaks
    Please read issue 73) for Jeweler:
    http://github.com/technicalpickles/jeweler/issues/73

    For a workaround, look here:
    http://gist.github.com/251663

### 0.6.0 / 2009-07-25

* Enhancements
  * Implemented 'fat-binaries' generation for cross compiling
    (for now). Thanks to Aaron Patterson for the suggestion and
    original idea.

        rake cross native gem RUBY_CC_VERSION=1.8.6:1.9.1

    Will package extensions for 1.8 and 1.9 versions of Ruby.
  * Can now cross compile extensions for 1.9 using 1.8.x as base.
    Be warned: works from 1.8 to 1.9, but not if your default ruby is 1.9

        rake cross compile RUBY_CC_VERSION=1.9.1

  * Allow simultaneous versions of Ruby to compile extensions.
    This change allow 1.8.x compiles co-exist with 1.9.x ones
    and don't override each other.

    Please perform <tt>rake clobber</tt> prior compiling again.
  * Allow optional source file URL for cross-compile tasks.
    (Thanks to deepj for the patches)

        rake-compiler cross-ruby VERSION=1.9.1-p0 SOURCE=http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.1-p0.tar.bz2

* Bugfixes
  * Removed strict versioning for gems since it clash with fat binaries.
    From now on, if your gem only targets a specific version of Ruby, please
    indicate it in the Gem::Specification (<tt>required_ruby_version</tt>)

### 0.5.0 / 2009-04-25

* Enhancements
  * Allow generation of multiple gems for Windows (EXPERIMENTAL)
    This allows build gems for both VC6 and MinGW builts of Ruby
    (Thanks to Jonathan Stott for the suggestion)

    ```ruby
    Rake::ExtensionTask.new('my_extension', GEM_SPEC) do |ext|
      ext.cross_compile = true
      ext.cross_platform = ['i386-mswin32', 'i386-mingw32']
    end
    ```

### 0.4.1 / 2009-04-09

* Enhancements
  * Target specific versions of Ruby when generating binaries.
    This avoids installing a 1.8.x binary gem in 1.9.x and viceversa.
    (Thanks to Aaron Patterson for the patches)

* Bugfixes
  * No longer raises error if rake-compiler configuration is missing.
    Not all users of a project would have it installed.
    (Thanks to Aaron Patterson for the patch)

### 0.4.0 / 2009-04-03

* Enhancements
  * Bended the convention for extension folder.
    Defining <tt>ext_dir</tt> for custom extension location.

    ```ruby
    Rake::ExtensionTask.new('my_extension') do |ext|
      ext.ext_dir = 'custom/location'         # look into custom/location
    end                                       # instead of ext/my_extension
    ```

  * Better detection of mingw target across Linux/OSX.
    Exposed it as Rake::ExtensionCompiler
  * Display list of available tasks when calling rake-compiler script
  * Track Ruby full versioning (x.y.z).
    This will help the compilation of extensions targetting 1.8.6/7 and 1.9.1

* Bugfixes
  * Better output of Rake development tasks (Thanks to Luis Parravicini).
  * Proper usage of Gem::Platform for native gems (Thanks to Dirkjan Bussink).
  * Don't use autoload for YAML (present problems with Ruby 1.9.1).

### 0.3.1 / 2009-01-09

* Enhancements
  * Download cross-ruby source code using HTTP instead of FTP.
  * Disabled Tcl/Tk extension building on cross-ruby (helps with 1.9).

* Bugfixes
  * Workaround bug introduced by lack of Gem::Specification cloning. Fixes DM LH #757.
  * Use proper binary extension on OSX (reported by Dirkjan Bussink).
  * Ensure lib/binary task is defined prior clear of requisites.

### 0.3.0 / 2008-12-07

* New features
  * Let you specify the Ruby version used for cross compilation instead
    of default one.

        rake cross compile RUBY_CC_VERSION=1.8

* Enhancements
  * Properly update rake-compiler configuration when new version is installed.
  * Automated release process to RubyForge, yay!

* Bugfixes
  * Corrected documentation to reflect the available options

### 0.2.1 / 2008-11-30

* New features

  * Allow cross compilation (cross compile) using mingw32 on Linux or OSX.
  * Allow packaging of gems for Windows on Linux or OSX.

* Enhancements

  * Made generation of extensions safe and target folders per-platform

* Bugfixes

  * Ensure binaries for the specific platform are copied before packaging.
