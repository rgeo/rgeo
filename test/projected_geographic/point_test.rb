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
    module ProjectedGeographic # :nodoc:
      class TestPoint < ::Test::Unit::TestCase # :nodoc:
        def setup
          @factory = ::RGeo::Geographic.projected_factory(buffer_resolution: 8, projection_proj4: "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs", projection_srid: 3857)
          @zfactory = ::RGeo::Geographic.projected_factory(has_z_coordinate: true, projection_proj4: "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs", projection_srid: 3857)
          @mfactory = ::RGeo::Geographic.projected_factory(has_m_coordinate: true, projection_proj4: "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs", projection_srid: 3857)
          @zmfactory = ::RGeo::Geographic.projected_factory(has_z_coordinate: true, has_m_coordinate: true, projection_proj4: "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs", projection_srid: 3857)
        end

        include ::RGeo::Tests::Common::PointTests

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
end if ::RGeo::CoordSys::Proj4.supported?
