# frozen_string_literal: true

require 'test_helper'

class GeometryEnvelopeTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_envelope
    simple_tester(
      :envelope,
      'POINT (0 0)',
      'POINT(0 0)'
    )

    simple_tester(
      :envelope,
      'POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0))',
      'LINESTRING(0 0, 10 10)'
    )
  end
end
