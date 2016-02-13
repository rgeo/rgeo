# -----------------------------------------------------------------------------
#
# Tests for the GEOS factory
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/factory_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module SphericalGeographic # :nodoc:
      class TestFactory < ::Test::Unit::TestCase # :nodoc:
        def setup
          @factory = ::RGeo::Geographic.spherical_factory
          @srid = 4055
        end

        include ::RGeo::Tests::Common::FactoryTests

        undef_method :test_srid_preserved_through_geom_operations
      end
    end
  end
end
