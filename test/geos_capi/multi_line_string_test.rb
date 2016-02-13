# -----------------------------------------------------------------------------
#
# Tests for the GEOS multi line string implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/multi_line_string_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module GeosCAPI # :nodoc:
      class TestMultiLineString < ::Test::Unit::TestCase # :nodoc:
        def create_factory
          ::RGeo::Geos.factory
        end

        include ::RGeo::Tests::Common::MultiLineStringTests
      end
    end
  end
end if ::RGeo::Geos.capi_supported?
