# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the Simple Spherical validity implementation
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"

class SphericalValidityTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::ValidityTests

  def setup
    @factory = RGeo::Geographic.spherical_factory
  end
end
