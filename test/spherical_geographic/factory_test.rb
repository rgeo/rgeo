# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS factory
#
# -----------------------------------------------------------------------------

require "test_helper"

class SphericalFactoryTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::FactoryTests

  def setup
    @factory = RGeo::Geographic.spherical_factory
    @srid = 4055
  end

  def test_uses_decimal
    decm_factory = RGeo::Geographic.spherical_factory(uses_decimals: true)
    assert_equal(true, decm_factory.property(:uses_decimals))

    point = decm_factory.point(1, 0)
    assert_equal(Float, point.x.class)
    assert_equal(BigDecimal, point.xyz.x.class)
  end

  undef_method :test_srid_preserved_through_geom_operations
end
