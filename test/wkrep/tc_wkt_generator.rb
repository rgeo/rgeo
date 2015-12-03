# -----------------------------------------------------------------------------
#
# Tests for WKT generator
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

module RGeo
  module Tests # :nodoc:
    module WKRep # :nodoc:
      class TestWKTGenerator < ::Test::Unit::TestCase # :nodoc:
        def setup
          @factory = ::RGeo::Cartesian.preferred_factory(srid: 1000)
          @factoryz = ::RGeo::Cartesian.preferred_factory(srid: 1000, has_z_coordinate: true)
          @factorym = ::RGeo::Cartesian.preferred_factory(srid: 1000, has_m_coordinate: true)
          @factoryzm = ::RGeo::Cartesian.preferred_factory(srid: 1000, has_z_coordinate: true, has_m_coordinate: true)
        end

        def test_point_2d
          generator_ = ::RGeo::WKRep::WKTGenerator.new
          obj_ = @factory.point(1, 2)
          assert_equal("Point (1.0 2.0)", generator_.generate(obj_))
        end

        def test_point_z
          generator_ = ::RGeo::WKRep::WKTGenerator.new
          obj_ = @factoryz.point(1, 2, 3)
          assert_equal("Point (1.0 2.0 3.0)", generator_.generate(obj_))
        end

        def test_point_z_wkt11strict
          generator_ = ::RGeo::WKRep::WKTGenerator.new(tag_format: :wkt11_strict)
          obj_ = @factoryz.point(1, 2, 3)
          assert_equal("Point (1.0 2.0)", generator_.generate(obj_))
        end

        def test_point_m
          generator_ = ::RGeo::WKRep::WKTGenerator.new
          obj_ = @factorym.point(1, 2, 3)
          assert_equal("Point (1.0 2.0 3.0)", generator_.generate(obj_))
        end

        def test_point_zm
          generator_ = ::RGeo::WKRep::WKTGenerator.new
          obj_ = @factoryzm.point(1, 2, 3, 4)
          assert_equal("Point (1.0 2.0 3.0 4.0)", generator_.generate(obj_))
        end

        def test_point_squarebrackets
          generator_ = ::RGeo::WKRep::WKTGenerator.new(square_brackets: true)
          obj_ = @factory.point(1, 2)
          assert_equal("Point [1.0 2.0]", generator_.generate(obj_))
        end

        def test_point_uppercase
          generator_ = ::RGeo::WKRep::WKTGenerator.new(convert_case: :upper)
          obj_ = @factory.point(1, 2)
          assert_equal("POINT (1.0 2.0)", generator_.generate(obj_))
        end

        def test_point_lowercase
          generator_ = ::RGeo::WKRep::WKTGenerator.new(convert_case: :lower)
          obj_ = @factory.point(1, 2)
          assert_equal("point (1.0 2.0)", generator_.generate(obj_))
        end

        def test_point_wkt12
          generator_ = ::RGeo::WKRep::WKTGenerator.new(tag_format: :wkt12)
          obj_ = @factory.point(1, 2)
          assert_equal("Point (1.0 2.0)", generator_.generate(obj_))
        end

        def test_point_wkt12_z
          generator_ = ::RGeo::WKRep::WKTGenerator.new(tag_format: :wkt12)
          obj_ = @factoryz.point(1, 2, 3)
          assert_equal("Point Z (1.0 2.0 3.0)", generator_.generate(obj_))
        end

        def test_point_wkt12_m
          generator_ = ::RGeo::WKRep::WKTGenerator.new(tag_format: :wkt12)
          obj_ = @factorym.point(1, 2, 3)
          assert_equal("Point M (1.0 2.0 3.0)", generator_.generate(obj_))
        end

        def test_point_wkt12_zm
          generator_ = ::RGeo::WKRep::WKTGenerator.new(tag_format: :wkt12)
          obj_ = @factoryzm.point(1, 2, 3, 4)
          assert_equal("Point ZM (1.0 2.0 3.0 4.0)", generator_.generate(obj_))
        end

        def test_point_ewkt
          generator_ = ::RGeo::WKRep::WKTGenerator.new(tag_format: :ewkt)
          obj_ = @factory.point(1, 2)
          assert_equal("Point (1.0 2.0)", generator_.generate(obj_))
        end

        def test_point_ewkt_z
          generator_ = ::RGeo::WKRep::WKTGenerator.new(tag_format: :ewkt)
          obj_ = @factoryz.point(1, 2, 3)
          assert_equal("Point (1.0 2.0 3.0)", generator_.generate(obj_))
        end

        def test_point_ewkt_m
          generator_ = ::RGeo::WKRep::WKTGenerator.new(tag_format: :ewkt)
          obj_ = @factorym.point(1, 2, 3)
          assert_equal("PointM (1.0 2.0 3.0)", generator_.generate(obj_))
        end

        def test_point_ewkt_zm
          generator_ = ::RGeo::WKRep::WKTGenerator.new(tag_format: :ewkt)
          obj_ = @factoryzm.point(1, 2, 3, 4)
          assert_equal("Point (1.0 2.0 3.0 4.0)", generator_.generate(obj_))
        end

        def test_point_ewkt_with_srid
          generator_ = ::RGeo::WKRep::WKTGenerator.new(tag_format: :ewkt, emit_ewkt_srid: true)
          obj_ = @factory.point(1, 2)
          assert_equal("SRID=1000;Point (1.0 2.0)", generator_.generate(obj_))
        end

        def test_linestring_basic
          generator_ = ::RGeo::WKRep::WKTGenerator.new
          p1_ = @factory.point(1, 2)
          p2_ = @factory.point(2, 2)
          p3_ = @factory.point(1, 1)
          obj_ = @factory.line_string([p1_, p2_, p3_])
          assert_equal("LineString (1.0 2.0, 2.0 2.0, 1.0 1.0)", generator_.generate(obj_))
        end

        def test_linestring_empty
          generator_ = ::RGeo::WKRep::WKTGenerator.new
          obj_ = @factory.line_string([])
          assert_equal("LineString EMPTY", generator_.generate(obj_))
        end

        def test_polygon_basic
          generator_ = ::RGeo::WKRep::WKTGenerator.new
          p1_ = @factory.point(0, 0)
          p2_ = @factory.point(10, 0)
          p3_ = @factory.point(10, 10)
          p4_ = @factory.point(0, 10)
          ext_ = @factory.line_string([p1_, p2_, p3_, p4_, p1_])
          obj_ = @factory.polygon(ext_)
          assert_equal("Polygon ((0.0 0.0, 10.0 0.0, 10.0 10.0, 0.0 10.0, 0.0 0.0))", generator_.generate(obj_))
        end

        def test_polygon_with_hole
          generator_ = ::RGeo::WKRep::WKTGenerator.new
          p1_ = @factory.point(0, 0)
          p2_ = @factory.point(10, 0)
          p3_ = @factory.point(10, 10)
          p4_ = @factory.point(0, 10)
          p5_ = @factory.point(1, 1)
          p6_ = @factory.point(2, 2)
          p7_ = @factory.point(3, 1)
          ext_ = @factory.line_string([p1_, p2_, p3_, p4_, p1_])
          int_ = @factory.line_string([p5_, p6_, p7_, p5_])
          obj_ = @factory.polygon(ext_, [int_])
          assert_equal("Polygon ((0.0 0.0, 10.0 0.0, 10.0 10.0, 0.0 10.0, 0.0 0.0), (1.0 1.0, 2.0 2.0, 3.0 1.0, 1.0 1.0))", generator_.generate(obj_))
        end

        def test_polygon_empty
          generator_ = ::RGeo::WKRep::WKTGenerator.new
          obj_ = @factory.polygon(@factory.line_string([]))
          assert_equal("Polygon EMPTY", generator_.generate(obj_))
        end

        def test_multipoint_basic
          generator_ = ::RGeo::WKRep::WKTGenerator.new
          p1_ = @factory.point(1, 2)
          p2_ = @factory.point(2, 2)
          p3_ = @factory.point(1, 1)
          obj_ = @factory.multi_point([p1_, p2_, p3_])
          assert_equal("MultiPoint ((1.0 2.0), (2.0 2.0), (1.0 1.0))", generator_.generate(obj_))
        end

        def test_multipoint_empty
          generator_ = ::RGeo::WKRep::WKTGenerator.new
          obj_ = @factory.multi_point([])
          assert_equal("MultiPoint EMPTY", generator_.generate(obj_))
        end

        def test_multilinestring_basic
          generator_ = ::RGeo::WKRep::WKTGenerator.new
          p1_ = @factory.point(0, 0)
          p2_ = @factory.point(10, 0)
          p3_ = @factory.point(10, 10)
          p4_ = @factory.point(0, 10)
          p5_ = @factory.point(1, 1)
          p6_ = @factory.point(2, 2)
          p7_ = @factory.point(3, 1)
          ls1_ = @factory.line_string([p1_, p2_, p3_, p4_, p1_])
          ls2_ = @factory.line_string([p5_, p6_, p7_])
          ls3_ = @factory.line_string([])
          obj_ = @factory.multi_line_string([ls1_, ls2_, ls3_])
          assert_equal("MultiLineString ((0.0 0.0, 10.0 0.0, 10.0 10.0, 0.0 10.0, 0.0 0.0), (1.0 1.0, 2.0 2.0, 3.0 1.0), EMPTY)", generator_.generate(obj_))
        end

        def test_multilinestring_empty
          generator_ = ::RGeo::WKRep::WKTGenerator.new
          obj_ = @factory.multi_line_string([])
          assert_equal("MultiLineString EMPTY", generator_.generate(obj_))
        end

        def test_multipolygon_basic
          generator_ = ::RGeo::WKRep::WKTGenerator.new
          p1_ = @factory.point(0, 0)
          p2_ = @factory.point(10, 0)
          p3_ = @factory.point(10, 10)
          p4_ = @factory.point(0, 10)
          p5_ = @factory.point(1, 1)
          p6_ = @factory.point(2, 2)
          p7_ = @factory.point(3, 1)
          p8_ = @factory.point(20, 20)
          p9_ = @factory.point(30, 20)
          p10_ = @factory.point(30, 30)
          p11_ = @factory.point(20, 30)
          ext1_ = @factory.line_string([p1_, p2_, p3_, p4_, p1_])
          int1_ = @factory.line_string([p5_, p6_, p7_, p5_])
          ext3_ = @factory.line_string([p8_, p9_, p10_, p11_, p8_])
          poly1_ = @factory.polygon(ext1_, [int1_])
          poly2_ = @factory.polygon(@factory.line_string([]))
          poly3_ = @factory.polygon(ext3_)
          obj_ = @factory.multi_polygon([poly1_, poly2_, poly3_])
          assert_equal("MultiPolygon (((0.0 0.0, 10.0 0.0, 10.0 10.0, 0.0 10.0, 0.0 0.0), (1.0 1.0, 2.0 2.0, 3.0 1.0, 1.0 1.0)), EMPTY, ((20.0 20.0, 30.0 20.0, 30.0 30.0, 20.0 30.0, 20.0 20.0)))", generator_.generate(obj_))
        end

        def test_multipolygon_empty
          generator_ = ::RGeo::WKRep::WKTGenerator.new
          obj_ = @factory.multi_polygon([])
          assert_equal("MultiPolygon EMPTY", generator_.generate(obj_))
        end

        def test_collection_basic
          generator_ = ::RGeo::WKRep::WKTGenerator.new
          p1_ = @factory.point(0, 0)
          p2_ = @factory.point(10, 0)
          p3_ = @factory.point(10, 10)
          p4_ = @factory.point(0, 10)
          p5_ = @factory.point(1, 1)
          p6_ = @factory.point(2, 2)
          p7_ = @factory.point(3, 1)
          p8_ = @factory.point(20, 20)
          p9_ = @factory.point(30, 20)
          p10_ = @factory.point(30, 30)
          p11_ = @factory.point(20, 30)
          ext1_ = @factory.line_string([p1_, p2_, p3_, p4_, p1_])
          int1_ = @factory.line_string([p5_, p6_, p7_, p5_])
          ext3_ = @factory.line_string([p8_, p9_, p10_, p11_, p8_])
          poly1_ = @factory.polygon(ext1_, [int1_])
          poly2_ = @factory.polygon(@factory.line_string([]))
          poly3_ = @factory.polygon(ext3_)
          obj1_ = @factory.multi_polygon([poly1_, poly2_, poly3_])
          obj2_ = @factory.point(1, 2)
          obj_ = @factory.collection([obj1_, obj2_])
          assert_equal("GeometryCollection (MultiPolygon (((0.0 0.0, 10.0 0.0, 10.0 10.0, 0.0 10.0, 0.0 0.0), (1.0 1.0, 2.0 2.0, 3.0 1.0, 1.0 1.0)), EMPTY, ((20.0 20.0, 30.0 20.0, 30.0 30.0, 20.0 30.0, 20.0 20.0))), Point (1.0 2.0))", generator_.generate(obj_))
        end

        def test_collection_wkt12_z
          generator_ = ::RGeo::WKRep::WKTGenerator.new(tag_format: :wkt12)
          p1_ = @factoryz.point(0, 0)
          p2_ = @factoryz.point(10, 0)
          p3_ = @factoryz.point(10, 10)
          p4_ = @factoryz.point(0, 10)
          p5_ = @factoryz.point(1, 1)
          p6_ = @factoryz.point(2, 2)
          p7_ = @factoryz.point(3, 1)
          p8_ = @factoryz.point(20, 20)
          p9_ = @factoryz.point(30, 20)
          p10_ = @factoryz.point(30, 30)
          p11_ = @factoryz.point(20, 30)
          ext1_ = @factoryz.line_string([p1_, p2_, p3_, p4_, p1_])
          int1_ = @factoryz.line_string([p5_, p6_, p7_, p5_])
          ext3_ = @factoryz.line_string([p8_, p9_, p10_, p11_, p8_])
          poly1_ = @factoryz.polygon(ext1_, [int1_])
          poly2_ = @factoryz.polygon(@factory.line_string([]))
          poly3_ = @factoryz.polygon(ext3_)
          obj1_ = @factoryz.multi_polygon([poly1_, poly2_, poly3_])
          obj2_ = @factoryz.point(1, 2, 3)
          obj_ = @factoryz.collection([obj1_, obj2_])
          assert_equal("GeometryCollection Z (MultiPolygon Z (((0.0 0.0 0.0, 10.0 0.0 0.0, 10.0 10.0 0.0, 0.0 10.0 0.0, 0.0 0.0 0.0), (1.0 1.0 0.0, 2.0 2.0 0.0, 3.0 1.0 0.0, 1.0 1.0 0.0)), EMPTY, ((20.0 20.0 0.0, 30.0 20.0 0.0, 30.0 30.0 0.0, 20.0 30.0 0.0, 20.0 20.0 0.0))), Point Z (1.0 2.0 3.0))", generator_.generate(obj_))
        end

        def test_collection_empty
          generator_ = ::RGeo::WKRep::WKTGenerator.new
          obj_ = @factory.collection([])
          assert_equal("GeometryCollection EMPTY", generator_.generate(obj_))
        end
      end
    end
  end
end
