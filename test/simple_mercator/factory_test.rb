# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS factory
#
# -----------------------------------------------------------------------------

require "test_helper"

class MercatorFactoryTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::FactoryTests

  def setup
    @factory = RGeo::Geographic.simple_mercator_factory
    @srid = 4326
  end

  def test_has_uses_lenient_assertions
    factory = RGeo::Geographic.simple_mercator_factory(uses_lenient_assertions: true)

    assert_equal(true, factory.property(:uses_lenient_assertions))
  end
end
