# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../cartesian_analysis_test"

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

    def test_ccw_p_false_if_not_enough
      skip "Needs GEOS 3.7+" unless RGeo::Geos::Analysis.ccw_supported?
      factory = RGeo::Geos.factory(native_interface: :capi)
      pt1 = factory.point(1, 2)
      pt2 = factory.point(2, 0)
      seq = factory.line_string([pt1, pt2])
      # https://github.com/libgeos/geos/pull/878
      if geos_version_match(">= 3.12.0")
        assert_equal(false, RGeo::Geos::Analysis.ccw?(pt1))
        assert_equal(false, RGeo::Geos::Analysis.ccw?(seq))
      else
        assert_raises(RGeo::Error::InvalidGeometry) { RGeo::Geos::Analysis.ccw?(pt1) }
        assert_raises(RGeo::Error::InvalidGeometry) { RGeo::Geos::Analysis.ccw?(seq) }
      end
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
