# -----------------------------------------------------------------------------
#
# Tests for the GEOS geometry collection implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/geometry_collection_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module GeosFFI # :nodoc:
      class TestGeometryCollection < ::Test::Unit::TestCase # :nodoc:
        def create_factory
          ::RGeo::Geos.factory(native_interface: :ffi)
        end

        include ::RGeo::Tests::Common::GeometryCollectionTests
      end
    end
  end
end if ::RGeo::Geos.ffi_supported?
