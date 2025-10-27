# frozen_string_literal: true

require 'test_helper'

class GeometryMiscTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_empty_geometry_has_0_area
    assert_equal(0, read('POLYGON EMPTY').area)
  end

  def test_empty_geometry_has_0_length
    assert_equal(0, read('POLYGON EMPTY').length)
  end

  def test_to_s
    assert_match(/^\#<Geos::Point: .+>$/, read('POINT(0 0)').to_s)
  end
end
