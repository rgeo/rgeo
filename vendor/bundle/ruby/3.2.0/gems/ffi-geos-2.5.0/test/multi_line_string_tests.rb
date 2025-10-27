# frozen_string_literal: true

require 'test_helper'

class MultiLineStringTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_closed
    skip unless ENV['FORCE_TESTS'] || Geos::MultiLineString.method_defined?(:closed?)

    simple_tester(:closed?, false, 'MULTILINESTRING ((1 1, 1 2, 2 2, 1 1), (0 0, 0 1, 1 1))')
    simple_tester(:closed?, true, 'MULTILINESTRING ((1 1, 1 2, 2 2, 1 1), (0 0, 0 1, 1 1, 0 0))')
  end
end
