# -----------------------------------------------------------------------------
#
# Tests for the GEOS multi point implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/multi_point_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module GeosFFI # :nodoc:
      class TestMultiPoint < ::Test::Unit::TestCase # :nodoc:
        def create_factory(opts_ = {})
          ::RGeo::Geos.factory(opts_.merge(native_interface: :ffi))
        end

        include ::RGeo::Tests::Common::MultiPointTests
      end
    end
  end
end if ::RGeo::Geos.ffi_supported?
