# frozen_string_literal: true

require 'test_helper'

class GeometryGetGeometryNTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  # get_geometry_n is segfaulting in the binary GEOS build
  def test_get_geometry_n
    skip unless defined?(Geos::FFIGeos)

    simple_tester(:get_geometry_n, 'POINT (0 1)', 'MULTIPOINT (0 1, 2 3)', 0)
    simple_tester(:get_geometry_n, 'POINT (2 3)', 'MULTIPOINT (0 1, 2 3)', 1)
    simple_tester(:get_geometry_n, nil, 'MULTIPOINT (0 1, 2 3)', 2)
  end
end
