# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../common/validity_tests"

class CartesianMiscTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::ValidityTests

  def setup
    @factory = RGeo::Cartesian.simple_factory
  end
end
