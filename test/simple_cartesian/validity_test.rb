# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the simple cartesian validity implementation
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"

class CartesianValidityTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::ValidityTests

  def setup
    @factory = RGeo::Cartesian.simple_factory
  end
end
