# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Common tests for geometry collection implementations
#
# -----------------------------------------------------------------------------

module RGeo
  module Tests # :nodoc:
    module Common # :nodoc:
      module GeometryCollectionTests # :nodoc:
        def setup
          @factory = create_factory
          @point1 = @factory.point(0, 0)
          @point2 = @factory.point(1, 0)
          @point3 = @factory.point(-4, 2)
          @point4 = @factory.point(-5, 3)
          @line1 = @factory.line_string([@point3, @point4])
          @line2 = @factory.line_string([@point3, @point4, @point1])
          @line3 = @factory.line(@point3, @point4)
        end

        def test_creation_simple
          geom = @factory.collection([@point1, @line1])
          assert(RGeo::Feature::GeometryCollection === geom)
          assert_equal(RGeo::Feature::GeometryCollection, geom.geometry_type)
          assert_equal(2, geom.num_geometries)
          assert(@point1.eql?(geom[0]))
          assert(@line1.eql?(geom[1]))
        end

        def test_creation_empty
          geom = @factory.collection([])
          assert(RGeo::Feature::GeometryCollection === geom)
          assert_equal(RGeo::Feature::GeometryCollection, geom.geometry_type)
          assert_equal(0, geom.num_geometries)
          assert_equal([], geom.to_a)
        end

        def test_bounds_check
          geom = @factory.collection([@point1, @line1])
          assert_nil(geom.geometry_n(200))
          assert_nil(geom.geometry_n(-1))
          assert(@line1.eql?(geom[-1]))
        end

        def test_enumerables
          geom = @factory.collection([@point1, @line1])
          assert_equal(geom.select { |e| e == @point1 }, [@point1])
          assert_equal(geom.detect { |e| e == @point1 }, @point1)
          assert_equal(geom.map { |e| e == @point1 }, [true, false])
        end

        def test_creation_save_klass
          geom = @factory.collection([@point1, @line3])
          assert(RGeo::Feature::GeometryCollection === geom)
          assert_equal(RGeo::Feature::GeometryCollection, geom.geometry_type)
          assert_equal(2, geom.num_geometries)
          assert(geom[1].eql?(@line3))
        end

        def test_creation_compound
          geom1 = @factory.collection([@point1, @line1])
          geom2 = @factory.collection([@point2, geom1])
          assert(RGeo::Feature::GeometryCollection === geom2)
          assert_equal(RGeo::Feature::GeometryCollection, geom2.geometry_type)
          assert_equal(2, geom2.num_geometries)
          assert(geom2[1].eql?(geom1))
        end

        def test_creation_compound_save_klass
          geom1 = @factory.collection([@point1, @line3])
          geom2 = @factory.collection([@point2, geom1])
          assert(RGeo::Feature::GeometryCollection === geom2)
          assert_equal(RGeo::Feature::GeometryCollection, geom2.geometry_type)
          assert_equal(2, geom2.num_geometries)
          assert_equal(RGeo::Feature::Line, geom2[1][1].geometry_type)
        end

        def test_required_equivalences
          geom1 = @factory.collection([@point1, @line1])
          geom2 = @factory.collection([@point1, @line1])
          assert(geom1.eql?(geom2))
          assert(geom1 == geom2)
        end

        def test_fully_equal
          geom1 = @factory.collection([@point1, @line1])
          geom2 = @factory.collection([@point1, @line1])
          assert(geom1.rep_equals?(geom2))
          assert(geom1.equals?(geom2))
        end

        def test_geometrically_equal
          geom1 = @factory.collection([@point2, @line2])
          geom2 = @factory.collection([@point2, @line1, @line2])
          assert(!geom1.rep_equals?(geom2))
          assert(geom1.equals?(geom2))
        end

        def test_empty_equal
          geom1 = @factory.collection([])
          geom2 = @factory.collection([])
          assert(geom1.rep_equals?(geom2))
          assert(geom1.equals?(geom2))
        end

        def test_not_equal
          geom1 = @factory.collection([@point1, @line1])
          geom2 = @factory.collection([@point2, @line1])
          assert(!geom1.rep_equals?(geom2))
          assert(!geom1.equals?(geom2))
        end

        def test_hashes_equal_for_representationally_equivalent_objects
          geom1 = @factory.collection([@point1, @line1])
          geom2 = @factory.collection([@point1, @line1])
          assert_equal(geom1.hash, geom2.hash)
        end

        def test_nested_equality
          geom1 = @factory.collection([@line1, @factory.collection([@point1, @point2])])
          geom2 = @factory.collection([@line1, @factory.collection([@point1, @point2])])
          assert(geom1.rep_equals?(geom2))
          assert_equal(geom1.hash, geom2.hash)
        end

        def test_out_of_order_is_not_equal
          geom1 = @factory.collection([@line1, @point2])
          geom2 = @factory.collection([@point2, @line1])
          assert(!geom1.rep_equals?(geom2))
          refute_equal(geom1.hash, geom2.hash)
        end

        def test_wkt_creation_simple
          parsed_geom = @factory.parse_wkt("GEOMETRYCOLLECTION(POINT(0 0), LINESTRING(-4 2, -5 3))")
          built_geom = @factory.collection([@point1, @line1])
          assert(built_geom.eql?(parsed_geom))
        end

        def test_wkt_creation_empty
          parsed_geom = @factory.parse_wkt("GEOMETRYCOLLECTION EMPTY")
          assert_equal(0, parsed_geom.num_geometries)
          assert_equal([], parsed_geom.to_a)
        end

        def test_clone
          geom1 = @factory.collection([@point1, @line1])
          geom2 = geom1.clone
          assert(geom1.eql?(geom2))
          assert_equal(RGeo::Feature::GeometryCollection, geom2.geometry_type)
          assert_equal(2, geom2.num_geometries)
          assert(@point1.eql?(geom2[0]))
          assert(@line1.eql?(geom2[1]))
        end

        def test_type_check
          geom1 = @factory.collection([@point1, @line1])
          assert(RGeo::Feature::Geometry.check_type(geom1))
          assert(!RGeo::Feature::Point.check_type(geom1))
          assert(RGeo::Feature::GeometryCollection.check_type(geom1))
          assert(!RGeo::Feature::MultiPoint.check_type(geom1))
          geom2 = @factory.collection([@point1, @point2])
          assert(RGeo::Feature::Geometry.check_type(geom2))
          assert(!RGeo::Feature::Point.check_type(geom2))
          assert(RGeo::Feature::GeometryCollection.check_type(geom2))
          assert(!RGeo::Feature::MultiPoint.check_type(geom2))
        end

        def test_as_text_wkt_round_trip
          geom1 = @factory.collection([@point1, @line1])
          text = geom1.as_text
          geom2 = @factory.parse_wkt(text)
          assert(geom1.eql?(geom2))
        end

        def test_as_binary_wkb_round_trip
          geom1 = @factory.collection([@point1, @line1])
          binary = geom1.as_binary
          geom2 = @factory.parse_wkb(binary)
          assert(geom1.eql?(geom2))
        end

        def test_dimension
          geom1 = @factory.collection([@point1, @line1])
          assert_equal(1, geom1.dimension)
          geom2 = @factory.collection([@point1, @point2])
          assert_equal(0, geom2.dimension)
          geom3 = @factory.collection([])
          assert_equal(-1, geom3.dimension)
        end

        def test_is_empty
          geom1 = @factory.collection([@point1, @line1])
          assert(!geom1.empty?)
          geom2 = @factory.collection([])
          assert(geom2.empty?)
        end

        def test_empty_collection_envelope
          empty = @factory.collection([])
          envelope = empty.envelope
          assert_equal(Feature::GeometryCollection, envelope.geometry_type)
          assert_equal(0, envelope.num_geometries)
        end

        def test_empty_collection_boundary
          empty = @factory.collection([])
          assert_raises(RGeo::Error::InvalidGeometry) { empty.boundary }
        end

        def test_each_block
          geom1 = @factory.collection([@point1, @line1])
          i = 0
          geom1.each do |g|
            if i == 0
              assert_equal(@point1, g)
            else
              assert_equal(@line1, g)
            end
            i += 1
          end
        end

        def test_each_enumerator
          geom1 = @factory.collection([@point1, @line1])
          enum = geom1.each
          assert_equal(@point1, enum.next)
          assert_equal(@line1, enum.next)
          assert_raises(::StopIteration) do
            enum.next
          end
        end
      end
    end
  end
end
