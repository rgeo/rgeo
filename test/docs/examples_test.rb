# frozen_string_literal: true

require_relative '../test_helper'
require 'tempfile'

# Ensure that the Examples.md document contains valid code.
# If this test raises an error, then the Examples.md file should
# be updated.

class ExamplesTest < MiniTest::Test
  def test_examples
    unless RGeo::Geos.ffi_supported? && RGeo::Geos.capi_supported?
      skip 'Examples can only be run with FFI and CAPI support'
    end

    file = Tempfile.new('examples.rb')
    original_stdout = $stdout
    $stdout = File.open(File::NULL, 'w')
    begin
      codeblock = read_examples
      file.write(codeblock)
      load(file.path)
    ensure
      $stdout = original_stdout
      file.close
      file.unlink
    end
  end

  private

  def examples_path
    "#{__dir__}/../../doc/Examples.md"
  end

  # read markdown line by line and if in a code block,
  # add line to string to be eval'd.
  def read_examples
    code = ''

    File.open(examples_path, 'r') do |file|
      in_code_block = false
      file.each_line do |line|
        if !in_code_block && line.include?('```ruby')
          in_code_block = true
        elsif in_code_block && line.include?('```')
          in_code_block = false
        elsif in_code_block
          code += line
        end
      end
    end
    code
  end
end
