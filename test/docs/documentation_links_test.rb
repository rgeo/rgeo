# frozen_string_literal: true

require "pathname"
require "set"

require_relative "../test_helper"

class DocumentationLinksTest < MiniTest::Test # :nodoc:
  def test_every_markdown_documents_linked
    root_path = File.join(__dir__, "..", "..")
    by_files = Dir[File.join(root_path, "doc", "*.md")]
               .map { |path| Pathname.new(path).relative_path_from(Pathname.new(root_path)) }
               .map { |file| "https://github.com/rgeo/rgeo/blob/master/#{file}" }
               .to_set

    in_readme = IO
                .foreach(File.join(root_path, "README.md"))
                .grep(%r{https://github\.com/rgeo/rgeo/blob/master/doc})
                .map { |line| line[%r{https://github\.com/rgeo/rgeo/blob/master/doc/.*?\.md}] }
                .to_set

    assert(
      (by_files - in_readme).size == 0,
      "Missing reference to documentation files (#{(by_files - in_readme).to_a.join(', ')})"
    )
    assert(
      (in_readme - by_files).size == 0,
      "Deprecated reference to documentation files (#{(in_readme - by_files).to_a.join(', ')})"
    )
  end
end
