# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the simple mercator line string implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class MercatorLineStringTest < Test::Unit::TestCase # :nodoc:
  include RGeo::Tests::Common::LineStringTests

  def setup
    @factory = RGeo::Geographic.simple_mercator_factory
  end
end
