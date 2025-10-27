# frozen_string_literal: true

require 'test_helper'

class GeometryNodeTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_node
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:node)

    simple_tester(
      :node,
      'MULTILINESTRING ((0 0, 5 0), (5 0, 10 0, 5 -5, 5 0), (5 0, 5 5))',
      'LINESTRING(0 0, 10 0, 5 -5, 5 5)'
    )
  end
end
