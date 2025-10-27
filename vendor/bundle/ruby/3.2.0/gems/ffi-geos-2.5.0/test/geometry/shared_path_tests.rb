# frozen_string_literal: true

require 'test_helper'

class GeometrySharedPathTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_shared_paths
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:shared_paths)

    geom_a = read('LINESTRING(0 0, 50 0)')
    geom_b = read('MULTILINESTRING((5 0, 15 0),(40 0, 30 0))')

    paths = geom_a.shared_paths(geom_b)

    assert_equal(2, paths.length)
    assert_equal(
      'MULTILINESTRING ((5 0, 15 0))',
      write(paths[0])
    )
    assert_equal(
      'MULTILINESTRING ((30 0, 40 0))',
      write(paths[1])
    )
  end
end
