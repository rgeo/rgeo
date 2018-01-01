# -----------------------------------------------------------------------------
#
# Tests for the GEOS factory
#
# -----------------------------------------------------------------------------

require "test_helper"

class SphericalFactoryTest < Test::Unit::TestCase # :nodoc:
  include RGeo::Tests::Common::FactoryTests

  def setup
    @factory = RGeo::Geographic.spherical_factory
    @srid = 4055
  end

  undef_method :test_srid_preserved_through_geom_operations
end
