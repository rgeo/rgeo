# -----------------------------------------------------------------------------
#
# Tests for the simple mercator point implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/point_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module SimpleMercator # :nodoc:
      class TestPoint < ::Test::Unit::TestCase # :nodoc:
        def setup
          @factory = ::RGeo::Geographic.simple_mercator_factory(buffer_resolution: 8)
          @zfactory = ::RGeo::Geographic.simple_mercator_factory(has_z_coordinate: true)
          @mfactory = ::RGeo::Geographic.simple_mercator_factory(has_m_coordinate: true)
          @zmfactory = ::RGeo::Geographic.simple_mercator_factory(has_z_coordinate: true, has_m_coordinate: true)
        end

        include ::RGeo::Tests::Common::PointTests

        # TEMP until ffi-geos 0.0.5 is released
        undef_method :test_buffer
        # END_TEMP

        def test_has_projection
          point_ = @factory.point(21, -22)
          assert(point_.respond_to?(:projection))
        end

        def test_latlon
          point_ = @factory.point(21, -22)
          assert_equal(21, point_.longitude)
          assert_equal(-22, point_.latitude)
        end

        def test_srid
          point_ = @factory.point(11, 12)
          assert_equal(4326, point_.srid)
        end

        def test_distance
          point1_ = @factory.point(11, 12)
          point2_ = @factory.point(11, 12)
          point3_ = @factory.point(13, 12)
          assert_in_delta(0, point1_.distance(point2_), 0.0001)
          assert_in_delta(222_638, point1_.distance(point3_), 1)
        end
      end
    end
  end
end
