# -----------------------------------------------------------------------------
#
# Tests for the GEOS point implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

module RGeo
  module Tests # :nodoc:
    module GeosFFI # :nodoc:
      class TestParsingUnparsing < ::Test::Unit::TestCase # :nodoc:
        def test_wkt_generator_default_floating_point
          # Bug report GH-4
          factory_ = ::RGeo::Geos.factory(native_interface: :ffi)
          point_ = factory_.point(111.99, -40.37)
          assert_equal("POINT (111.99 -40.37)", point_.as_text)
        end

        def test_wkt_generator_downcase
          factory_ = ::RGeo::Geos.factory(wkt_generator: { convert_case: :lower },
                                          native_interface: :ffi)
          point_ = factory_.point(1, 1)
          assert_equal("point (1.0 1.0)", point_.as_text)
        end

        def test_wkt_generator_geos
          factory_ = ::RGeo::Geos.factory(wkt_generator: :geos, native_interface: :ffi)
          point_ = factory_.point(1, 1)
          assert_equal("POINT (1.0000000000000000 1.0000000000000000)", point_.as_text)
        end

        def test_wkt_parser_default_with_non_geosable_input
          factory_ = ::RGeo::Geos.factory(native_interface: :ffi)
          assert_not_nil(factory_.parse_wkt("Point (1 1)"))
        end
      end
    end
  end
end if ::RGeo::Geos.ffi_supported?
