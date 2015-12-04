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
    module GeosFFI # :nodoc:
      class TestFactory < ::Test::Unit::TestCase # :nodoc:
        def setup
          @factory = ::RGeo::Geos.factory(srid: 1000, native_interface: :ffi)
          @srid = 1000
        end

        include ::RGeo::Tests::Common::FactoryTests

        def test_is_geos_factory
          assert_equal(true, ::RGeo::Geos.is_geos?(@factory))
          assert_equal(false, ::RGeo::Geos.is_capi_geos?(@factory))
          assert_equal(true, ::RGeo::Geos.is_ffi_geos?(@factory))
        end
      end
    end
  end
end if ::RGeo::Geos.ffi_supported?
