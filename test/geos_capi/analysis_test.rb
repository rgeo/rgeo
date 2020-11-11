# frozen_string_literal: true

require_relative "../test_helper"

module GeosCapi
  class AnalysisTest < Minitest::Test
    def setup
      skip "Needs GEOS." unless RGeo::Geos.capi_supported?
    end

    def test_ccw_p_raises_if_not_a_geos_object
      factory = RGeo::Cartesian.simple_factory
      pt1 = factory.point(1, 0)
      pt2 = factory.point(2, 0)
      pt3 = factory.point(2, 1)
      ring = factory.line_string([pt1, pt2, pt3, pt1])
      assert_raises(RGeo::Error::RGeoError) { RGeo::Geos::Analysis.ccw?(ring) }
    end

    def test_ccw_p_raises_if_no_coordseq
      factory = RGeo::Geos.factory(native_interface: :capi)
      point = factory.point(1, 2)
      assert_raises(RGeo::Error::GeosError) { RGeo::Geos::Analysis.ccw?(point) }
    end

    def test_ccw_p_returns_true_if_ccw
      factory = RGeo::Geos.factory(native_interface: :capi)
      pt1 = factory.point(1, 0)
      pt2 = factory.point(2, 0)
      pt3 = factory.point(2, 1)
      sequence = [pt1, pt2, pt3, pt1]
      ring_ccw = factory.line_string(sequence)
      ring_cw = factory.line_string(sequence.reverse)
      assert_equal(false, RGeo::Geos::Analysis.ccw?(ring_cw))
      assert_equal(true, RGeo::Geos::Analysis.ccw?(ring_ccw))
    end
  end
end
