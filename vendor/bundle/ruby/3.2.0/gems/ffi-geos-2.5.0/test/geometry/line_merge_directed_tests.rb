# frozen_string_literal: true

require 'test_helper'

describe '#line_merge_directed' do
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  it 'merges lines in MULTILINESTRINGs' do
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:line_merge_directed)

    simple_tester(
      :line_merge_directed,
      'LINESTRING (0 -5, 0 0, 0 100)',
      'MULTILINESTRING ((0 0, 0 100), (0 -5, 0 0))'
    )

    simple_tester(
      :line_merge_directed,
      'MULTILINESTRING ((0 0, 0 100), (0 0, 0 -5))',
      'MULTILINESTRING ((0 0, 0 100), (0 0, 0 -5))'
    )
  end
end
