# -----------------------------------------------------------------------------
#
# Tests for the GEOS geometry collection implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

module RGeo
  module Tests # :nodoc:
    module GeosFFI # :nodoc:
      class TestGeometryCollection < ::Test::Unit::TestCase # :nodoc:
        include RGeo::Tests::Common::GeometryCollectionTests

        def create_factory
          ::RGeo::Geos.factory(native_interface: :ffi)
        end
      end
    end
  end
end if ::RGeo::Geos.ffi_supported?
