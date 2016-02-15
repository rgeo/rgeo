# -----------------------------------------------------------------------------
#
# Tests for the GEOS point implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/point_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module GeosFFI # :nodoc:
      class TestPoint < ::Test::Unit::TestCase # :nodoc:
        def setup
          @factory = ::RGeo::Geos.factory(native_interface: :ffi, buffer_resolution: 8)
          @zfactory = ::RGeo::Geos.factory(has_z_coordinate: true, native_interface: :ffi)
          @mfactory = ::RGeo::Geos.factory(has_m_coordinate: true, native_interface: :ffi)
          @zmfactory = ::RGeo::Geos.factory(has_z_coordinate: true, has_m_coordinate: true,
                                            native_interface: :ffi)
        end

        include ::RGeo::Tests::Common::PointTests

        # TEMP until ffi-geos 0.0.5 is released
        undef_method :test_buffer
        # END_TEMP

        def test_is_geos
          point_ = @factory.point(21, -22)
          assert_equal(true, ::RGeo::Geos.is_geos?(point_))
          assert_equal(false, ::RGeo::Geos.is_capi_geos?(point_))
          assert_equal(true, ::RGeo::Geos.is_ffi_geos?(point_))
          point2_ = @zmfactory.point(21, -22, 0, 0)
          assert_equal(true, ::RGeo::Geos.is_geos?(point2_))
          assert_equal(false, ::RGeo::Geos.is_capi_geos?(point2_))
          assert_equal(true, ::RGeo::Geos.is_ffi_geos?(point2_))
        end

        def test_has_no_projection
          point_ = @factory.point(21, -22)
          assert(!point_.respond_to?(:projection))
        end

        def test_srid
          point_ = @factory.point(11, 12)
          assert_equal(0, point_.srid)
        end

        def test_distance
          point1_ = @factory.point(11, 12)
          point2_ = @factory.point(11, 12)
          point3_ = @factory.point(13, 12)
          assert_equal(0, point1_.distance(point2_))
          assert_equal(2, point1_.distance(point3_))
        end

        if defined?(::Encoding)

          def test_as_text_encoding
            factory_ = ::RGeo::Geos.factory(native_interface: :ffi, wkt_generator: :geos)
            point_ = factory_.point(11, 12)
            assert_equal(::Encoding::US_ASCII, point_.as_text.encoding)
          end

          def test_as_binary_encoding
            factory_ = ::RGeo::Geos.factory(native_interface: :ffi, wkb_generator: :geos)
            point_ = factory_.point(11, 12)
            assert_equal(::Encoding::ASCII_8BIT, point_.as_binary.encoding)
          end

        end
      end
    end
  end
end if ::RGeo::Geos.ffi_supported?
