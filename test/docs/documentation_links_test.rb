# frozen_string_literal: true

require "pathname"
require "set"

require_relative "../test_helper"

class DocumentationLinksTest < Minitest::Test # :nodoc:
  def test_every_markdown_documents_linked
    root_path = File.join(__dir__, "..", "..")
    by_files = Dir[File.join(root_path, "doc", "*.md")]
               .to_set { |path| Pathname.new(path).relative_path_from(Pathname.new(root_path)) }
               .to_set { |file| "https://github.com/rgeo/rgeo/blob/main/#{file}" }

    in_readme = File
                .foreach(File.join(root_path, "README.md"))
                .grep(%r{https://github\.com/rgeo/rgeo/blob/main/doc})
                .to_set { |line| line[%r{https://github\.com/rgeo/rgeo/blob/main/doc/.*?\.md}] }

    assert(
      (by_files - in_readme).size == 0,
      "Missing reference to documentation files in README.md (#{(by_files - in_readme).to_a.join(', ')})"
    )
    assert(
      (in_readme - by_files).size == 0,
      "Deprecated reference to documentation files in README.md (#{(in_readme - by_files).to_a.join(', ')})"
    )
  end
end
