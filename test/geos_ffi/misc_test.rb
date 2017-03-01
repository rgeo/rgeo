# -----------------------------------------------------------------------------
#
# Tests for miscellaneous GEOS stuff
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

module RGeo
  module Tests # :nodoc:
    module GeosFFI # :nodoc:
      class TestMisc < ::Test::Unit::TestCase # :nodoc:
        def setup
          @factory = ::RGeo::Geos.factory(srid: 4326, native_interface: :ffi)
        end

        def test_empty_geometries_equal
          geom1_ = @factory.collection([])
          geom2_ = @factory.line_string([])
          assert(!geom1_.eql?(geom2_))
          assert(geom1_.equals?(geom2_))
        end

        def test_prepare
          p1_ = @factory.point(1, 2)
          p2_ = @factory.point(3, 4)
          p3_ = @factory.point(5, 2)
          polygon_ = @factory.polygon(@factory.linear_ring([p1_, p2_, p3_, p1_]))
          assert_equal(false, polygon_.prepared?)
          polygon_.prepare!
          assert_equal(true, polygon_.prepared?)
        end

        def test_auto_prepare
          p1_ = @factory.point(1, 2)
          p2_ = @factory.point(3, 4)
          p3_ = @factory.point(5, 2)
          polygon_ = @factory.polygon(@factory.linear_ring([p1_, p2_, p3_, p1_]))
          assert_equal(false, polygon_.prepared?)
          polygon_.intersects?(p1_)
          assert_equal(false, polygon_.prepared?)
          polygon_.intersects?(p2_)
          assert_equal(true, polygon_.prepared?)

          factory_no_auto_prepare_ = ::RGeo::Geos.factory(srid: 4326,
                                                          native_interface: :ffi, auto_prepare: :disabled)
          polygon2_ = factory_no_auto_prepare_.polygon(
            factory_no_auto_prepare_.linear_ring([p1_, p2_, p3_, p1_]))
          assert_equal(false, polygon2_.prepared?)
          polygon2_.intersects?(p1_)
          assert_equal(false, polygon2_.prepared?)
          polygon2_.intersects?(p2_)
          assert_equal(false, polygon2_.prepared?)
        end

        def test_unary_union_simple_points
          p1_ = @factory.point(1, 1)
          p2_ = @factory.point(2, 2)
          mp_ = @factory.multi_point([p1_, p2_])
          collection_ = @factory.collection([p1_, p2_])
          geom_ = collection_.unary_union
          if ::RGeo::Geos::Utils.ffi_supports_unary_union
            assert(geom_.eql?(mp_))
          else
            assert_equal(nil, geom_)
          end
        end

        def test_unary_union_mixed_collection
          collection_ = @factory.parse_wkt("GEOMETRYCOLLECTION (POLYGON ((0 0, 0 90, 90 90, 90 0, 0 0)),   POLYGON ((120 0, 120 90, 210 90, 210 0, 120 0)),  LINESTRING (40 50, 40 140),  LINESTRING (160 50, 160 140),  POINT (60 50),  POINT (60 140),  POINT (40 140))")
          expected_ = @factory.parse_wkt("GEOMETRYCOLLECTION (POINT (60 140),   LINESTRING (40 90, 40 140), LINESTRING (160 90, 160 140), POLYGON ((0 0, 0 90, 40 90, 90 90, 90 0, 0 0)), POLYGON ((120 0, 120 90, 160 90, 210 90, 210 0, 120 0)))")
          geom_ = collection_.unary_union
          if ::RGeo::Geos::Utils.ffi_supports_unary_union
            assert(geom_.eql?(expected_))
          else
            assert_equal(nil, geom_)
          end
        end
      end
    end
  end
end if ::RGeo::Geos.ffi_supported?

unless ::RGeo::Geos.ffi_supported?
  puts "WARNING: FFI-GEOS support not available. Related tests skipped."
end
