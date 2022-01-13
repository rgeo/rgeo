# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the Simple Mercator validity implementation
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"
require_relative "../common/validity_tests"

class MercatorValidityTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::ValidityTests

  def setup
    @factory = RGeo::Geographic.simple_mercator_factory
  end

  # Taken from RGeo::Tests::Common::ValidityTests, but adapted to have a
  # correct area.
  def square_polygon_expected_area
    12_392_658_216.374474
  end
end
