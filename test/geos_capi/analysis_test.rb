# frozen_string_literal: true

require_relative "../test_helper"

module GeosCapi
  class AnalysisTest < CartesianAnalysisTest
    def setup
      skip "Needs GEOS." unless RGeo::Geos.capi_supported?
      @fixtures = Fixtures.new(RGeo::Geos.factory)
    end

    def test_ccw_p_raises_if_not_a_geos_object
      skip "Needs GEOS 3.7+" unless RGeo::Geos::Analysis.ccw_supported?
      factory = RGeo::Cartesian.simple_factory
      pt1 = factory.point(1, 0)
      pt2 = factory.point(2, 0)
      pt3 = factory.point(2, 1)
      ring = factory.line_string([pt1, pt2, pt3, pt1])
      assert_raises(RGeo::Error::RGeoError) { RGeo::Geos::Analysis.ccw?(ring) }
    end

    def test_ccw_p_raises_if_no_coordseq
      skip "Needs GEOS 3.7+" unless RGeo::Geos::Analysis.ccw_supported?
      factory = RGeo::Geos.factory(native_interface: :capi)
      point = factory.point(1, 2)
      assert_raises(RGeo::Error::InvalidGeometry) { RGeo::Geos::Analysis.ccw?(point) }
    end

    def test_ccw_p_returns_true_if_ccw
      skip "Needs GEOS 3.7+" unless RGeo::Geos::Analysis.ccw_supported?
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

    # no need to re-test the ruby implementation
    methods.grep(/\Atest_ring_direction/).each { |meth| undef_method meth }
  end
end
