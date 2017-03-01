# -----------------------------------------------------------------------------
#
# Tests for miscellaneous GEOS stuff
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

module RGeo
  module Tests # :nodoc:
    module GeosCAPI # :nodoc:
      class TestMisc < ::Test::Unit::TestCase # :nodoc:
        def setup
          @factory = ::RGeo::Geos.factory(srid: 4326)
        end

        def test_marshal_dump_with_geos
          @factory = ::RGeo::Geos.factory(
            srid: 4326,
            wkt_generator: :geos,
            wkb_generator: :geos,
            wkt_parser: :geos,
            wkb_parser: :geos
          )

          dump = nil
          assert_nothing_raised { dump = @factory.marshal_dump }
          assert_equal({}, dump["wktg"])
          assert_equal({}, dump["wkbg"])
          assert_equal({}, dump["wktp"])
          assert_equal({}, dump["wkbp"])
        end

        def test_encode_with_geos
          @factory = ::RGeo::Geos.factory(
            srid: 4326,
            wkt_generator: :geos,
            wkb_generator: :geos,
            wkt_parser: :geos,
            wkb_parser: :geos
          )
          coder = Psych::Coder.new("test")

          assert_nothing_raised { @factory.encode_with(coder) }
          assert_equal({}, coder["wkt_generator"])
          assert_equal({}, coder["wkb_generator"])
          assert_equal({}, coder["wkt_parser"])
          assert_equal({}, coder["wkb_parser"])
        end

        def test_uninitialized
          geom_ = ::RGeo::Geos::CAPIGeometryImpl.new
          assert_equal(false, geom_.initialized?)
          assert_nil(geom_.geometry_type)
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

          factory_no_auto_prepare_ = ::RGeo::Geos.factory(srid: 4326, auto_prepare: :disabled)
          polygon2_ = factory_no_auto_prepare_.polygon(
            factory_no_auto_prepare_.linear_ring([p1_, p2_, p3_, p1_]))
          assert_equal(false, polygon2_.prepared?)
          polygon2_.intersects?(p1_)
          assert_equal(false, polygon2_.prepared?)
          polygon2_.intersects?(p2_)
          assert_equal(false, polygon2_.prepared?)
        end

        def test_gh_21
          # Test for GH-21 (seg fault in rgeo_convert_to_geos_geometry)
          # This seemed to fail under Ruby 1.8.7 only.
          f_ = RGeo::Geographic.simple_mercator_factory
          loc_ = f_.line_string([f_.point(-123, 37), f_.point(-122, 38)])
          f2_ = f_.projection_factory
          loc2_ = f2_.line_string([f2_.point(-123, 37), f2_.point(-122, 38)])
          loc2_.intersection(loc_)
        end

        def test_geos_version
          assert_match(/^\d+\.\d+(\.\d+)?$/, ::RGeo::Geos.version)
        end

        def test_unary_union_simple_points
          p1_ = @factory.point(1, 1)
          p2_ = @factory.point(2, 2)
          mp_ = @factory.multi_point([p1_, p2_])
          collection_ = @factory.collection([p1_, p2_])
          geom_ = collection_.unary_union
          if ::RGeo::Geos::CAPIFactory._supports_unary_union?
            assert(geom_.eql?(mp_))
          else
            assert_equal(nil, geom_)
          end
        end

        def test_unary_union_mixed_collection
          collection_ = @factory.parse_wkt("GEOMETRYCOLLECTION (POLYGON ((0 0, 0 90, 90 90, 90 0, 0 0)),   POLYGON ((120 0, 120 90, 210 90, 210 0, 120 0)),  LINESTRING (40 50, 40 140),  LINESTRING (160 50, 160 140),  POINT (60 50),  POINT (60 140),  POINT (40 140))")
          expected_ = @factory.parse_wkt("GEOMETRYCOLLECTION (POINT (60 140),   LINESTRING (40 90, 40 140), LINESTRING (160 90, 160 140), POLYGON ((0 0, 0 90, 40 90, 90 90, 90 0, 0 0)), POLYGON ((120 0, 120 90, 160 90, 210 90, 210 0, 120 0)))")
          geom_ = collection_.unary_union
          if ::RGeo::Geos::CAPIFactory._supports_unary_union?
            assert(geom_.eql?(expected_))
          else
            assert_equal(nil, geom_)
          end
        end
      end
    end
  end
end if ::RGeo::Geos.capi_supported?

unless ::RGeo::Geos.capi_supported?
  puts "WARNING: GEOS CAPI support not available. Related tests skipped."
end
