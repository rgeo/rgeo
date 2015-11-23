# -----------------------------------------------------------------------------
#
# Common tests for geometry collection implementations
#
# -----------------------------------------------------------------------------

require "rgeo"

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
          geom_ = @factory.collection([@point1, @line1])
          assert_not_nil(geom_)
          assert(::RGeo::Feature::GeometryCollection === geom_)
          assert_equal(::RGeo::Feature::GeometryCollection, geom_.geometry_type)
          assert_equal(2, geom_.num_geometries)
          assert(@point1.eql?(geom_[0]))
          assert(@line1.eql?(geom_[1]))
        end

        def test_creation_empty
          geom_ = @factory.collection([])
          assert_not_nil(geom_)
          assert(::RGeo::Feature::GeometryCollection === geom_)
          assert_equal(::RGeo::Feature::GeometryCollection, geom_.geometry_type)
          assert_equal(0, geom_.num_geometries)
          assert_equal([], geom_.to_a)
        end

        def test_bounds_check
          geom_ = @factory.collection([@point1, @line1])
          assert_nil(geom_.geometry_n(200))
          assert_nil(geom_.geometry_n(-1))
          assert(@line1.eql?(geom_[-1]))
        end

        def test_creation_save_klass
          geom_ = @factory.collection([@point1, @line3])
          assert_not_nil(geom_)
          assert(::RGeo::Feature::GeometryCollection === geom_)
          assert_equal(::RGeo::Feature::GeometryCollection, geom_.geometry_type)
          assert_equal(2, geom_.num_geometries)
          assert(geom_[1].eql?(@line3))
        end

        def test_creation_compound
          geom1_ = @factory.collection([@point1, @line1])
          geom2_ = @factory.collection([@point2, geom1_])
          assert_not_nil(geom2_)
          assert(::RGeo::Feature::GeometryCollection === geom2_)
          assert_equal(::RGeo::Feature::GeometryCollection, geom2_.geometry_type)
          assert_equal(2, geom2_.num_geometries)
          assert(geom2_[1].eql?(geom1_))
        end

        def test_creation_compound_save_klass
          geom1_ = @factory.collection([@point1, @line3])
          geom2_ = @factory.collection([@point2, geom1_])
          ::GC.start
          assert_not_nil(geom2_)
          assert(::RGeo::Feature::GeometryCollection === geom2_)
          assert_equal(::RGeo::Feature::GeometryCollection, geom2_.geometry_type)
          assert_equal(2, geom2_.num_geometries)
          assert_equal(::RGeo::Feature::Line, geom2_[1][1].geometry_type)
        end

        def test_required_equivalences
          geom1_ = @factory.collection([@point1, @line1])
          geom2_ = @factory.collection([@point1, @line1])
          assert(geom1_.eql?(geom2_))
          assert(geom1_ == geom2_)
        end

        def test_fully_equal
          geom1_ = @factory.collection([@point1, @line1])
          geom2_ = @factory.collection([@point1, @line1])
          assert(geom1_.rep_equals?(geom2_))
          assert(geom1_.equals?(geom2_))
        end

        def test_geometrically_equal
          geom1_ = @factory.collection([@point2, @line2])
          geom2_ = @factory.collection([@point2, @line1, @line2])
          assert(!geom1_.rep_equals?(geom2_))
          assert(geom1_.equals?(geom2_))
        end

        def test_empty_equal
          geom1_ = @factory.collection([])
          geom2_ = @factory.collection([])
          assert(geom1_.rep_equals?(geom2_))
          assert(geom1_.equals?(geom2_))
        end

        def test_not_equal
          geom1_ = @factory.collection([@point1, @line1])
          geom2_ = @factory.collection([@point2, @line1])
          assert(!geom1_.rep_equals?(geom2_))
          assert(!geom1_.equals?(geom2_))
        end

        def test_hashes_equal_for_representationally_equivalent_objects
          geom1_ = @factory.collection([@point1, @line1])
          geom2_ = @factory.collection([@point1, @line1])
          assert_equal(geom1_.hash, geom2_.hash)
        end

        def test_nested_equality
          geom1_ = @factory.collection([@line1, @factory.collection([@point1, @point2])])
          geom2_ = @factory.collection([@line1, @factory.collection([@point1, @point2])])
          assert(geom1_.rep_equals?(geom2_))
          assert_equal(geom1_.hash, geom2_.hash)
        end

        def test_out_of_order_is_not_equal
          geom1_ = @factory.collection([@line1, @point2])
          geom2_ = @factory.collection([@point2, @line1])
          assert(!geom1_.rep_equals?(geom2_))
          assert_not_equal(geom1_.hash, geom2_.hash)
        end

        def test_wkt_creation_simple
          parsed_geom_ = @factory.parse_wkt("GEOMETRYCOLLECTION(POINT(0 0), LINESTRING(-4 2, -5 3))")
          built_geom_ = @factory.collection([@point1, @line1])
          assert(built_geom_.eql?(parsed_geom_))
        end

        def test_wkt_creation_empty
          parsed_geom_ = @factory.parse_wkt("GEOMETRYCOLLECTION EMPTY")
          assert_equal(0, parsed_geom_.num_geometries)
          assert_equal([], parsed_geom_.to_a)
        end

        def test_clone
          geom1_ = @factory.collection([@point1, @line1])
          geom2_ = geom1_.clone
          assert(geom1_.eql?(geom2_))
          assert_equal(::RGeo::Feature::GeometryCollection, geom2_.geometry_type)
          assert_equal(2, geom2_.num_geometries)
          assert(@point1.eql?(geom2_[0]))
          assert(@line1.eql?(geom2_[1]))
        end

        def test_type_check
          geom1_ = @factory.collection([@point1, @line1])
          assert(::RGeo::Feature::Geometry.check_type(geom1_))
          assert(!::RGeo::Feature::Point.check_type(geom1_))
          assert(::RGeo::Feature::GeometryCollection.check_type(geom1_))
          assert(!::RGeo::Feature::MultiPoint.check_type(geom1_))
          geom2_ = @factory.collection([@point1, @point2])
          assert(::RGeo::Feature::Geometry.check_type(geom2_))
          assert(!::RGeo::Feature::Point.check_type(geom2_))
          assert(::RGeo::Feature::GeometryCollection.check_type(geom2_))
          assert(!::RGeo::Feature::MultiPoint.check_type(geom2_))
        end

        def test_as_text_wkt_round_trip
          geom1_ = @factory.collection([@point1, @line1])
          text_ = geom1_.as_text
          geom2_ = @factory.parse_wkt(text_)
          assert(geom1_.eql?(geom2_))
        end

        def test_as_binary_wkb_round_trip
          geom1_ = @factory.collection([@point1, @line1])
          binary_ = geom1_.as_binary
          geom2_ = @factory.parse_wkb(binary_)
          assert(geom1_.eql?(geom2_))
        end

        def test_dimension
          geom1_ = @factory.collection([@point1, @line1])
          assert_equal(1, geom1_.dimension)
          geom2_ = @factory.collection([@point1, @point2])
          assert_equal(0, geom2_.dimension)
          geom3_ = @factory.collection([])
          assert_equal(-1, geom3_.dimension)
        end

        def test_is_empty
          geom1_ = @factory.collection([@point1, @line1])
          assert(!geom1_.is_empty?)
          geom2_ = @factory.collection([])
          assert(geom2_.is_empty?)
        end

        def test_empty_collection_envelope
          empty_ = @factory.collection([])
          envelope_ = empty_.envelope
          assert_equal(Feature::GeometryCollection, envelope_.geometry_type)
          assert_equal(0, envelope_.num_geometries)
        end

        def test_empty_collection_boundary
          empty_ = @factory.collection([])
          assert_nil(empty_.boundary)
        end

        def test_each_block
          geom1_ = @factory.collection([@point1, @line1])
          i_ = 0
          geom1_.each do |g_|
            if i_ == 0
              assert_equal(@point1, g_)
            else
              assert_equal(@line1, g_)
            end
            i_ += 1
          end
        end

        def test_each_enumerator
          geom1_ = @factory.collection([@point1, @line1])
          enum_ = geom1_.each
          assert_equal(@point1, enum_.next)
          assert_equal(@line1, enum_.next)
          assert_raise(::StopIteration) do
            enum_.next
          end
        end
      end
    end
  end
end
