# -----------------------------------------------------------------------------
#
# Tests for the GEOS factory
#
# -----------------------------------------------------------------------------

require "test_helper"

class CartesianFactoryTest < Test::Unit::TestCase # :nodoc:
  include RGeo::Tests::Common::FactoryTests

  def setup
    @factory = ::RGeo::Cartesian.simple_factory(srid: 1000)
    @srid = 1000
  end

  undef_method :test_srid_preserved_through_geom_operations
end
