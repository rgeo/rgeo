require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'rake/javaextensiontask'
require 'rbconfig'

describe Rake::JavaExtensionTask do
  context '#new' do
    context '(basic)' do
      it 'should raise an error if no name is provided' do
        lambda {
          Rake::JavaExtensionTask.new
        }.should raise_error(RuntimeError, /Extension name must be provided/)
      end

      it 'should allow string as extension name assignation' do
        ext = Rake::JavaExtensionTask.new('extension_one')
        ext.name.should == 'extension_one'
      end

      it 'should allow string as extension name using block assignation' do
        ext = Rake::JavaExtensionTask.new do |ext|
          ext.name = 'extension_two'
        end
        ext.name.should == 'extension_two'
      end

      it 'should return itself for the block' do
        from_block = nil
        from_lasgn = Rake::JavaExtensionTask.new('extension_three') do |ext|
          from_block = ext
        end
        from_block.should == from_lasgn
      end

      it 'should accept a gem specification as parameter' do
        spec = mock_gem_spec
        ext = Rake::JavaExtensionTask.new('extension_three', spec)
        ext.gem_spec.should == spec
      end

      it 'should allow gem specification be defined using block assignation' do
        spec = mock_gem_spec
        ext = Rake::JavaExtensionTask.new('extension_four') do |ext|
          ext.gem_spec = spec
        end
        ext.gem_spec.should == spec
      end

      it 'should allow forcing of platform' do
        ext = Rake::JavaExtensionTask.new('weird_extension') do |ext|
          ext.platform = 'java-128bit'
        end
        ext.platform.should == 'java-128bit'
      end
    end
  end

  context '(defaults)' do
    before :each do
      @ext = Rake::JavaExtensionTask.new('extension_one')
    end

    it 'should dump intermediate files to tmp/' do
      @ext.tmp_dir.should == 'tmp'
    end

    it 'should copy build extension into lib/' do
      @ext.lib_dir.should == 'lib'
    end

    it 'should look for Java files pattern (.java)' do
      @ext.source_pattern.should == "**/*.java"
    end

    it 'should have no configuration options preset to delegate' do
      @ext.config_options.should be_empty
    end

    it 'should have no lint option preset to delegate' do
      @ext.lint_option.should be_falsey
    end

    it 'should default to Java platform' do
      @ext.platform.should == 'java'
    end
  end

  context '(tasks)' do
    before :each do
      Rake.application.clear
      CLEAN.clear
      CLOBBER.clear
    end

    context '(one extension)' do
      before :each do
        allow(Rake::FileList).to receive(:[]).and_return(["ext/extension_one/source.java"])
        @ext = Rake::JavaExtensionTask.new('extension_one')
        @ext_bin = ext_bin('extension_one')
        @platform = 'java'
      end

      context 'compile' do
        it 'should define as task' do
          Rake::Task.task_defined?('compile').should == true
        end

        it "should depend on 'compile:{platform}'" do
          pending 'needs fixing'
          Rake::Task['compile'].prerequisites.should include("compile:#{@platform}")
        end
      end

      context 'compile:extension_one' do
        it 'should define as task' do
          Rake::Task.task_defined?('compile:extension_one').should == true
        end

        it "should depend on 'compile:extension_one:{platform}'" do
          pending 'needs fixing'
          Rake::Task['compile:extension_one'].prerequisites.should include("compile:extension_one:#{@platform}")
        end
      end

      context 'lib/extension_one.jar' do
        it 'should define as task' do
          pending 'needs fixing'
          Rake::Task.task_defined?("lib/#{@ext_bin}").should be_true
        end

        it "should depend on 'copy:extension_one:{platform}'" do
          pending 'needs fixing'
          Rake::Task["lib/#{@ext_bin}"].prerequisites.should include("copy:extension_one:#{@platform}")
        end
      end

      context 'tmp/{platform}/extension_one/extension_one.jar' do
        it 'should define as task' do
          Rake::Task.task_defined?("tmp/#{@platform}/extension_one/#{@ext_bin}").should == true
        end

        it "should depend on checkpoint file" do
          Rake::Task["tmp/#{@platform}/extension_one/#{@ext_bin}"].prerequisites.should include("tmp/#{@platform}/extension_one/.build")
        end
      end

      context 'tmp/{platform}/extension_one/.build' do
        it 'should define as task' do
          Rake::Task.task_defined?("tmp/#{@platform}/extension_one/.build").should == true
        end

        it 'should depend on source files' do
          Rake::Task["tmp/#{@platform}/extension_one/.build"].prerequisites.should include("ext/extension_one/source.java")
        end
      end

      context 'clean' do
        it "should include 'tmp/{platform}/extension_one' in the pattern" do
          CLEAN.should include("tmp/#{@platform}/extension_one")
        end
      end

      context 'clobber' do
        it "should include 'lib/extension_one.jar'" do
          CLOBBER.should include("lib/#{@ext_bin}")
        end

        it "should include 'tmp'" do
          CLOBBER.should include('tmp')
        end
      end
    end

    context 'A custom extension' do
      let(:extension) do
        Rake::JavaExtensionTask.new('extension_two') do |ext|
          ext.lint_option = lint_option if lint_option
          ext.release = release if release
        end
      end

      context 'without a specified lint option' do
        let(:lint_option) { nil }
        let(:release) { nil }

        it 'should honor the lint option' do
          (extension.lint_option).should be_falsey
          (extension.send :java_lint_arg).should eq '-Xlint'
        end
      end

      context "with a specified lint option of 'deprecated'" do
        let(:lint_option) { 'deprecated'.freeze }
        let(:release) { nil }

        it 'should honor the lint option' do
          (extension.lint_option).should eq lint_option
          (extension.send :java_lint_arg).should eq '-Xlint:deprecated'
        end
      end

      context "without release option" do
        let(:lint_option) { nil }
        let(:release) { nil }

        it 'should generate -target and -source build options' do
          extension.target_version = "1.8"
          extension.source_version = "1.8"
          (extension.send :java_target_args).should eq ["-target", "1.8", "-source", "1.8"]
        end
      end

      context "with release option" do
        let(:lint_option) { nil }
        let(:release) { '8' }

        it 'should generate --release option even with target_version/source_version' do
          extension.target_version = "1.8"
          extension.source_version = "1.8"
          (extension.send :java_target_args).should eq ["--release=8"]
        end
      end
    end
  end
  private

  def ext_bin(extension_name)
    "#{extension_name}.jar"
  end

  def mock_gem_spec(stubs = {})
    double(Gem::Specification,
      { :name => 'my_gem', :platform => 'ruby' }.merge(stubs)
    )
  end

end
