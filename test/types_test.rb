# -----------------------------------------------------------------------------
#
# Tests for type properties
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

module RGeo
  module Tests # :nodoc:
    class TestTypes < ::Test::Unit::TestCase # :nodoc:
      def test_geometry
        assert_equal("Geometry", ::RGeo::Feature::Geometry.type_name)
        assert_nil(::RGeo::Feature::Geometry.supertype)
        assert(::RGeo::Feature::Geometry.subtype_of?(::RGeo::Feature::Geometry))
        assert(!::RGeo::Feature::Geometry.subtype_of?(::RGeo::Feature::Point))
      end

      def test_point
        assert_equal("Point", ::RGeo::Feature::Point.type_name)
        assert_equal(::RGeo::Feature::Geometry, ::RGeo::Feature::Point.supertype)
        assert(::RGeo::Feature::Point.subtype_of?(::RGeo::Feature::Point))
        assert(::RGeo::Feature::Point.subtype_of?(::RGeo::Feature::Geometry))
        assert(!::RGeo::Feature::Point.subtype_of?(::RGeo::Feature::LineString))
      end

      def test_line_string
        assert_equal("LineString", ::RGeo::Feature::LineString.type_name)
        assert_equal(::RGeo::Feature::Curve, ::RGeo::Feature::LineString.supertype)
        assert(::RGeo::Feature::LineString.subtype_of?(::RGeo::Feature::LineString))
        assert(::RGeo::Feature::LineString.subtype_of?(::RGeo::Feature::Curve))
        assert(::RGeo::Feature::LineString.subtype_of?(::RGeo::Feature::Geometry))
        assert(!::RGeo::Feature::LineString.subtype_of?(::RGeo::Feature::Line))
      end
    end
  end
end
