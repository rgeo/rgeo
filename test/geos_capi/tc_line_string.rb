# -----------------------------------------------------------------------------
#
# Tests for the GEOS line string implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/line_string_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module GeosCAPI # :nodoc:
      class TestLineString < ::Test::Unit::TestCase # :nodoc:
        include ::RGeo::Tests::Common::LineStringTests

        def setup
          @factory = ::RGeo::Geos.factory
        end
      end
    end
  end
end if ::RGeo::Geos.capi_supported?
