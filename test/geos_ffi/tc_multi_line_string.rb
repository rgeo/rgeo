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
    module GeosFFI # :nodoc:
      class TestMultiLineString < ::Test::Unit::TestCase # :nodoc:
        def create_factory
          ::RGeo::Geos.factory(native_interface: :ffi)
        end

        include ::RGeo::Tests::Common::MultiLineStringTests
      end
    end
  end
end if ::RGeo::Geos.ffi_supported?
