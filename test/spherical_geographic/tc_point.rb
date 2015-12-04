# -----------------------------------------------------------------------------
#
# Tests for the simple spherical point implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/point_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module SphericalGeographic # :nodoc:
      class TestPoint < ::Test::Unit::TestCase # :nodoc:
        def setup
          @factory = ::RGeo::Geographic.spherical_factory(buffer_resolution: 8)
          @zfactory = ::RGeo::Geographic.spherical_factory(has_z_coordinate: true)
          @mfactory = ::RGeo::Geographic.spherical_factory(has_m_coordinate: true)
          @zmfactory = ::RGeo::Geographic.spherical_factory(has_z_coordinate: true, has_m_coordinate: true)
        end

        include ::RGeo::Tests::Common::PointTests

        def test_latlon
          point_ = @factory.point(21, -22)
          assert_equal(21, point_.longitude)
          assert_equal(-22, point_.latitude)
        end

        def test_antimeridian_positive
          point_ = @factory.point(180, 85)
          assert_equal(180, point_.longitude)
          assert_equal(85, point_.latitude)
        end

        def test_antimeridian_netagive
          point_ = @factory.point(-180, -85)
          assert_equal(-180, point_.longitude)
          assert_equal(-85, point_.latitude)
        end

        def test_srid
          point_ = @factory.point(11, 12)
          assert_equal(4055, point_.srid)
        end

        def test_distance
          point1_ = @factory.point(0, 10)
          point2_ = @factory.point(0, 10)
          point3_ = @factory.point(0, 40)
          assert_in_delta(0, point1_.distance(point2_), 0.0001)
          assert_in_delta(::Math::PI / 6.0 * ::RGeo::Geographic::SphericalMath::RADIUS, point1_.distance(point3_), 0.0001)
        end

        def test_floating_point_perturbation
          # A naive way of wrapping longitudes to [-180,180] might cause
          # perturbation due to floating point errors. Make sure this
          # doesn't happen.
          point_ = @factory.point(-98.747534, 38.057583)
          assert_equal(-98.747534, point_.x)
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
