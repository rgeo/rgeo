# frozen_string_literal: true

require_relative "../test_helper"

class GeosWKREPTest < Minitest::Test
  def setup
    skip "Needs GEOS FFI." unless RGeo::Geos.ffi_supported?
    @factory = RGeo::Geos.factory(native_interface: :ffi)
  end

  def test_parse_wkb_raises_on_wrong_data
    assert_raises(RGeo::Error::ParseError) do
      @factory.parse_wkb(
        "00000003e93ff00000000000004000000000000000"
      )
    end
  end

  def test_parse_wkb_parses_correct_data
    obj = @factory.parse_wkb("0101000000000000000000f03f0000000000000040")
    assert_equal(RGeo::Feature::Point, obj.geometry_type)
  end

  def test_parse_wkb_parses_xdr_binary
    obj = @factory.parse_wkb("\x00\x00\x00\x00\x01?\xF0\x00\x00\x00\x00\x00\x00@\x00\x00\x00\x00\x00\x00\x00")
    assert_equal(RGeo::Feature::Point, obj.geometry_type)
  end

  def test_parse_wkt_raises_on_wrong_data
    assert_raises(RGeo::Error::ParseError) do
      @factory.parse_wkt(
        "SRID=1000;POINT(1 2)"
      )
    end
  end

  def test_parse_wkt_parses_correct_data
    obj = @factory.parse_wkt("POINT(1. .2)")
    assert_equal(RGeo::Feature::Point, obj.geometry_type)
  end

  def test_generate_wkb
    assert_equal(@factory.point(1, 2).as_binary.unpack1("H*"), "0101000000000000000000f03f0000000000000040")
  end

  def test_generate_wkt
    assert_equal(@factory.point(1, 2).as_text, "POINT (1.0000000000000000 2.0000000000000000)")
  end

  def test_wkt_generator_downcase
    factory = RGeo::Geos.factory(native_interface: :ffi, wkt_generator: { convert_case: :lower })
    point = factory.point(1, 1)
    assert_equal("point (1.0 1.0)", point.as_text)
  end
end
