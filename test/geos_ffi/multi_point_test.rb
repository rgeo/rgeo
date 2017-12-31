# -----------------------------------------------------------------------------
#
# Tests for the GEOS multi point implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

module RGeo
  module Tests # :nodoc:
    module GeosFFI # :nodoc:
      class TestMultiPoint < ::Test::Unit::TestCase # :nodoc:
        include RGeo::Tests::Common::MultiPointTests

        def create_factory(opts_ = {})
          ::RGeo::Geos.factory(opts_.merge(native_interface: :ffi))
        end
      end
    end
  end
end if ::RGeo::Geos.ffi_supported?
