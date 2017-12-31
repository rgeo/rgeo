# -----------------------------------------------------------------------------
#
# Tests for the GEOS multi point implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

module RGeo
  module Tests # :nodoc:
    module GeosCAPI # :nodoc:
      class TestMultiPoint < ::Test::Unit::TestCase # :nodoc:
        include RGeo::Tests::Common::MultiPointTests

        def create_factory(opts_ = {})
          ::RGeo::Geos.factory(opts_)
        end
      end
    end
  end
end if ::RGeo::Geos.capi_supported?
