# frozen_string_literal: true

require 'test_helper'

class GeometryCoordSeqTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_coord_seq
    tester = lambda { |expected, g|
      geom = read(g)
      cs = geom.coord_seq
      expected.each_with_index do |c, i|
        assert_equal(c[0], cs.get_x(i))
        assert_equal(c[1], cs.get_y(i))
      end
    }

    tester[[[0, 0]], 'POINT(0 0)']
    tester[[[0, 0], [2, 3]], 'LINESTRING (0 0, 2 3)']
    tester[[[0, 0], [0, 5], [5, 5], [5, 0], [0, 0]], 'LINEARRING(0 0, 0 5, 5 5, 5 0, 0 0)']
  end
end
