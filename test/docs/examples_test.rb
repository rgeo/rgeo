# frozen_string_literal: true

require_relative "../test_helper"

# Ensure that the Examples.md document contains valid code.
# If this test raises an error, then the Examples.md file should
# be updated.

class ExamplesTest < MiniTest::Test
  def test_examples
    unless RGeo::Geos.ffi_supported? && RGeo::Geos.capi_supported?
      skip "Examples can only be run with FFI and CAPI support"
    end
    read_examples do |example, line_no|
      _out, err = capture_io do
        eval example # rubocop:disable Security/Eval
      rescue StandardError => e
        warn e
      end
      assert(
        err.empty?,
        "Example block doc/Examples.md:#{line_no} failed. See error below.\n#{err}"
      )
    end
  end

  private

  def examples_path
    "#{__dir__}/../../doc/Examples.md"
  end

  # read markdown line by line and if in a code block,
  # add line to string to be eval'd.
  def read_examples
    code = nil
    line_no = nil

    File.open(examples_path, "r") do |file|
      in_code_block = false
      file.each_line do |line|
        if !in_code_block && line.include?("```ruby")
          code = ""
          line_no = file.lineno
          in_code_block = true
        elsif in_code_block && line.include?("```")
          yield(code, line_no)
          in_code_block = false
        elsif in_code_block
          code += line
        end
      end
    end
    code
  end
end
