# -----------------------------------------------------------------------------
#
# Tests for mixin system
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

module RGeo
  module Tests # :nodoc:
    class TestMixins < ::Test::Unit::TestCase # :nodoc:
      module Mixin1  # :nodoc:
        def mixin1_method
        end
      end

      module Mixin2  # :nodoc:
        def mixin2_method
        end
      end

      ::RGeo::Feature::MixinCollection::GLOBAL.for_type(::RGeo::Feature::Point).add(Mixin1)
      ::RGeo::Feature::MixinCollection::GLOBAL.for_type(::RGeo::Feature::GeometryCollection).add(Mixin1)
      ::RGeo::Feature::MixinCollection::GLOBAL.for_type(::RGeo::Feature::MultiCurve).add(Mixin2)

      def test_basic_mixin_cartesian
        factory_ = ::RGeo::Cartesian.simple_factory
        assert_equal(::RGeo::Cartesian::PointImpl, factory_.point(1, 1).class)
        assert(factory_.point(1, 1).class.include?(Mixin1))
        assert(!factory_.point(1, 1).class.include?(Mixin2))
        assert(factory_.point(1, 1).respond_to?(:mixin1_method))
        assert(!factory_.point(1, 1).respond_to?(:mixin2_method))
      end

      def test_inherited_mixin_cartesian
        factory_ = ::RGeo::Cartesian.simple_factory
        assert(factory_.collection([]).class.include?(Mixin1))
        assert(!factory_.collection([]).class.include?(Mixin2))
        assert(factory_.collection([]).respond_to?(:mixin1_method))
        assert(!factory_.collection([]).respond_to?(:mixin2_method))
        assert(factory_.multi_line_string([]).class.include?(Mixin1))
        assert(factory_.multi_line_string([]).class.include?(Mixin2))
        assert(factory_.multi_line_string([]).respond_to?(:mixin1_method))
        assert(factory_.multi_line_string([]).respond_to?(:mixin2_method))
      end

      if ::RGeo::Geos.capi_supported?

        def test_basic_mixin_geos_capi
          factory_ = ::RGeo::Geos.factory(native_interface: :capi)
          assert_equal(::RGeo::Geos::CAPIPointImpl, factory_.point(1, 1).class)
          assert(factory_.point(1, 1).class.include?(Mixin1))
          assert(!factory_.point(1, 1).class.include?(Mixin2))
          assert(factory_.point(1, 1).respond_to?(:mixin1_method))
          assert(!factory_.point(1, 1).respond_to?(:mixin2_method))
        end

        def test_inherited_mixin_geos_capi
          factory_ = ::RGeo::Geos.factory(native_interface: :capi)
          assert(factory_.collection([]).class.include?(Mixin1))
          assert(!factory_.collection([]).class.include?(Mixin2))
          assert(factory_.collection([]).respond_to?(:mixin1_method))
          assert(!factory_.collection([]).respond_to?(:mixin2_method))
          assert(factory_.multi_line_string([]).class.include?(Mixin1))
          assert(factory_.multi_line_string([]).class.include?(Mixin2))
          assert(factory_.multi_line_string([]).respond_to?(:mixin1_method))
          assert(factory_.multi_line_string([]).respond_to?(:mixin2_method))
        end

      end

      if ::RGeo::Geos.ffi_supported?

        def test_basic_mixin_geos_ffi
          factory_ = ::RGeo::Geos.factory(native_interface: :ffi)
          assert_equal(::RGeo::Geos::FFIPointImpl, factory_.point(1, 1).class)
          assert(factory_.point(1, 1).class.include?(Mixin1))
          assert(!factory_.point(1, 1).class.include?(Mixin2))
          assert(factory_.point(1, 1).respond_to?(:mixin1_method))
          assert(!factory_.point(1, 1).respond_to?(:mixin2_method))
        end

        def test_inherited_mixin_geos_ffi
          factory_ = ::RGeo::Geos.factory(native_interface: :ffi)
          assert(factory_.collection([]).class.include?(Mixin1))
          assert(!factory_.collection([]).class.include?(Mixin2))
          assert(factory_.collection([]).respond_to?(:mixin1_method))
          assert(!factory_.collection([]).respond_to?(:mixin2_method))
          assert(factory_.multi_line_string([]).class.include?(Mixin1))
          assert(factory_.multi_line_string([]).class.include?(Mixin2))
          assert(factory_.multi_line_string([]).respond_to?(:mixin1_method))
          assert(factory_.multi_line_string([]).respond_to?(:mixin2_method))
        end

      end

      def test_basic_mixin_spherical
        factory_ = ::RGeo::Geographic.spherical_factory
        assert_equal(::RGeo::Geographic::SphericalPointImpl, factory_.point(1, 1).class)
        assert(factory_.point(1, 1).class.include?(Mixin1))
        assert(!factory_.point(1, 1).class.include?(Mixin2))
        assert(factory_.point(1, 1).respond_to?(:mixin1_method))
        assert(!factory_.point(1, 1).respond_to?(:mixin2_method))
      end

      def test_inherited_mixin_spherical
        factory_ = ::RGeo::Geographic.spherical_factory
        assert(factory_.collection([]).class.include?(Mixin1))
        assert(!factory_.collection([]).class.include?(Mixin2))
        assert(factory_.collection([]).respond_to?(:mixin1_method))
        assert(!factory_.collection([]).respond_to?(:mixin2_method))
        assert(factory_.multi_line_string([]).class.include?(Mixin1))
        assert(factory_.multi_line_string([]).class.include?(Mixin2))
        assert(factory_.multi_line_string([]).respond_to?(:mixin1_method))
        assert(factory_.multi_line_string([]).respond_to?(:mixin2_method))
      end

      def test_basic_mixin_simple_mercator
        factory_ = ::RGeo::Geographic.simple_mercator_factory
        assert_equal(::RGeo::Geographic::ProjectedPointImpl, factory_.point(1, 1).class)
        assert(factory_.point(1, 1).class.include?(Mixin1))
        assert(!factory_.point(1, 1).class.include?(Mixin2))
        assert(factory_.point(1, 1).respond_to?(:mixin1_method))
        assert(!factory_.point(1, 1).respond_to?(:mixin2_method))
      end

      def test_inherited_mixin_simple_mercator
        factory_ = ::RGeo::Geographic.simple_mercator_factory
        assert(factory_.collection([]).class.include?(Mixin1))
        assert(!factory_.collection([]).class.include?(Mixin2))
        assert(factory_.collection([]).respond_to?(:mixin1_method))
        assert(!factory_.collection([]).respond_to?(:mixin2_method))
        assert(factory_.multi_line_string([]).class.include?(Mixin1))
        assert(factory_.multi_line_string([]).class.include?(Mixin2))
        assert(factory_.multi_line_string([]).respond_to?(:mixin1_method))
        assert(factory_.multi_line_string([]).respond_to?(:mixin2_method))
      end
    end
  end
end
