# -----------------------------------------------------------------------------
#
# Tests for the simple cartesian point implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/point_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module SimpleCartesian # :nodoc:
      class TestPoint < ::Test::Unit::TestCase # :nodoc:
        def setup
          @factory = ::RGeo::Cartesian.simple_factory(srid: 1, buffer_resolution: 8)
          @zfactory = ::RGeo::Cartesian.simple_factory(srid: 1, has_z_coordinate: true)
          @mfactory = ::RGeo::Cartesian.simple_factory(srid: 1, has_m_coordinate: true)
          @zmfactory = ::RGeo::Cartesian.simple_factory(srid: 1, has_z_coordinate: true, has_m_coordinate: true)
        end

        include ::RGeo::Tests::Common::PointTests

        def test_srid
          point_ = @factory.point(11, 12)
          assert_equal(1, point_.srid)
        end

        def test_distance
          point1_ = @factory.point(2, 2)
          point2_ = @factory.point(7, 14)
          assert_in_delta(13, point1_.distance(point2_), 0.0001)
        end

        undef_method :test_disjoint
        undef_method :test_intersects
        undef_method :test_touches
        undef_method :test_crosses
        undef_method :test_within
        undef_method :test_contains
        undef_method :test_overlaps
        undef_method :test_intersection
        undef_method :test_union
        undef_method :test_difference
        undef_method :test_sym_difference
      end
    end
  end
end
