# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the Simple Mercator validity implementation
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"

class MercatorValidityTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::ValidityTests

  def setup
    @factory = RGeo::Geographic.simple_mercator_factory
  end
end
