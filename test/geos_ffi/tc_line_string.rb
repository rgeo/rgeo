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
    module GeosFFI # :nodoc:
      class TestLineString < ::Test::Unit::TestCase # :nodoc:
        def setup
          @factory = ::RGeo::Geos.factory(native_interface: :ffi)
        end

        include ::RGeo::Tests::Common::LineStringTests
      end
    end
  end
end if ::RGeo::Geos.ffi_supported?
