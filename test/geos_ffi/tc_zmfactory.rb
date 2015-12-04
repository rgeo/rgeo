# -----------------------------------------------------------------------------
#
# Tests for the GEOS point implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/factory_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module GeosFFI # :nodoc:
      class TestZMFactory < ::Test::Unit::TestCase # :nodoc:
        def setup
          @factory = ::RGeo::Geos.factory(has_z_coordinate: true, has_m_coordinate: true,
                                          srid: 1000, buffer_resolution: 2, native_interface: :ffi)
          @srid = 1000
        end

        include ::RGeo::Tests::Common::FactoryTests

        def test_is_geos_factory
          assert_equal(true, ::RGeo::Geos.is_geos?(@factory))
          assert_equal(false, ::RGeo::Geos.is_capi_geos?(@factory))
          assert_equal(true, ::RGeo::Geos.is_ffi_geos?(@factory))
        end

        def test_factory_parts
          assert_equal(1000, @factory.srid)
          assert_equal(1000, @factory.z_factory.srid)
          assert_equal(1000, @factory.m_factory.srid)
          assert_equal(2, @factory.buffer_resolution)
          assert_equal(2, @factory.z_factory.buffer_resolution)
          assert_equal(2, @factory.m_factory.buffer_resolution)
          assert(@factory.property(:has_z_coordinate))
          assert(@factory.property(:has_m_coordinate))
          assert(@factory.z_factory.property(:has_z_coordinate))
          assert(!@factory.z_factory.property(:has_m_coordinate))
          assert(!@factory.m_factory.property(:has_z_coordinate))
          assert(@factory.m_factory.property(:has_m_coordinate))
        end

        def test_4d_point
          point_ = @factory.point(1, 2, 3, 4)
          assert_equal(Feature::Point, point_.geometry_type)
          assert_equal(3, point_.z)
          assert_equal(4, point_.m)
          assert_equal(3, point_.z_geometry.z)
          assert_nil(point_.z_geometry.m)
          assert_nil(point_.m_geometry.z)
          assert_equal(4, point_.m_geometry.m)
        end
      end
    end
  end
end if ::RGeo::Geos.ffi_supported?
