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

  def test_ring_has_lenient_assertions
    ring = lambda do |factory|
      factory.linear_ring([
                            factory.point(0, 0),
                            factory.point(1, 1),
                            factory.point(0, 1),
                            factory.point(1, 0)
                          ])
    end

    assert_raises { ring.call RGeo::Geographic.simple_mercator_factory }

    ring.call RGeo::Geographic.simple_mercator_factory(uses_lenient_assertions: true)
  end
end
