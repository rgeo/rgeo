# frozen_string_literal: true

require 'test_helper'

class GeometryLineStringEnumeratorTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_line_string_enumerator
    geom = read('LINESTRING(0 0, 10 10)')

    assert_kind_of(Enumerable, geom.each)
    assert_kind_of(Enumerable, geom.to_enum)
    assert_equal(geom, geom.each(&EMPTY_BLOCK))
  end
end
