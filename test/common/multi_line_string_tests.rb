# -----------------------------------------------------------------------------
#
# Common tests for multi line string implementations
#
# -----------------------------------------------------------------------------

require "rgeo"

module RGeo
  module Tests # :nodoc:
    module Common # :nodoc:
      module MultiLineStringTests # :nodoc:
        def setup
          @factory = create_factory
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(1, 0)
          point3_ = @factory.point(-4, 2)  # (-4, 2)
          point4_ = @factory.point(-7, 6)  # (-5, 3)
          point5_ = @factory.point(5, 11)  # (-3, 5)
          @linestring1 = @factory.line_string([point1_, point2_])
          @linestring2 = @factory.line_string([point3_, point4_, point5_])
          @linearring1 = @factory.linear_ring([point5_, point3_, point4_, point5_])
          @line1 = @factory.line(point1_, point2_)
        end

        def test_creation_simple
          geom_ = @factory.multi_line_string([@linestring1, @linestring2])
          assert_not_nil(geom_)
          assert(::RGeo::Feature::MultiLineString === geom_)
          assert_equal(::RGeo::Feature::MultiLineString, geom_.geometry_type)
          assert_equal(2, geom_.num_geometries)
          assert(@linestring1.eql?(geom_[0]))
          assert(@linestring2.eql?(geom_[1]))
        end

        def test_creation_empty
          geom_ = @factory.multi_line_string([])
          assert_not_nil(geom_)
          assert(::RGeo::Feature::MultiLineString === geom_)
          assert_equal(::RGeo::Feature::MultiLineString, geom_.geometry_type)
          assert_equal(0, geom_.num_geometries)
          assert_equal([], geom_.to_a)
        end

        def test_creation_save_types
          geom_ = @factory.multi_line_string([@linestring1, @linearring1, @line1])
          assert_not_nil(geom_)
          assert(::RGeo::Feature::MultiLineString === geom_)
          assert_equal(::RGeo::Feature::MultiLineString, geom_.geometry_type)
          assert_equal(3, geom_.num_geometries)
          assert(geom_[1].eql?(@linearring1))
          assert(geom_[2].eql?(@line1))
        end

        def test_creation_casting
          mls1_ = @factory.collection([@line1])
          mls2_ = @factory.multi_line_string([@linearring1])
          geom_ = @factory.multi_line_string([@linestring1, @linestring2, mls1_, mls2_])
          assert_not_nil(geom_)
          assert_equal(::RGeo::Feature::MultiLineString, geom_.geometry_type)
          assert_equal(4, geom_.num_geometries)
          assert(@linestring1.eql?(geom_[0]))
          assert(@linestring2.eql?(geom_[1]))
          assert(@line1.eql?(geom_[2]))
          assert(@linearring1.eql?(geom_[3]))
        end

        def test_required_equivalences
          geom1_ = @factory.multi_line_string([@linestring1, @linestring2])
          geom2_ = @factory.multi_line_string([@linestring1, @linestring2])
          assert(geom1_.eql?(geom2_))
          assert(geom1_ == geom2_)
        end

        def test_fully_equal
          geom1_ = @factory.multi_line_string([@linestring1, @linestring2])
          geom2_ = @factory.multi_line_string([@linestring1, @linestring2])
          assert(geom1_.rep_equals?(geom2_))
          assert(geom1_.equals?(geom2_))
        end

        def test_geometrically_equal
          geom1_ = @factory.multi_line_string([@linestring1, @linestring2, @linearring1])
          geom2_ = @factory.multi_line_string([@line1, @linearring1])
          assert(!geom1_.rep_equals?(geom2_))
          assert(geom1_.equals?(geom2_))
        end

        def test_not_equal
          geom1_ = @factory.multi_line_string([@linestring2])
          geom2_ = @factory.multi_line_string([@linearring1])
          assert(!geom1_.rep_equals?(geom2_))
          assert(!geom1_.equals?(geom2_))
        end

        def test_hashes_equal_for_representationally_equivalent_objects
          geom1_ = @factory.multi_line_string([@linestring1, @linestring2])
          geom2_ = @factory.multi_line_string([@linestring1, @linestring2])
          assert_equal(geom1_.hash, geom2_.hash)
        end

        def test_wkt_creation_simple
          parsed_geom_ = @factory.parse_wkt("MULTILINESTRING((0 0, 1 0), (-4 2, -7 6, 5 11))")
          built_geom_ = @factory.multi_line_string([@linestring1, @linestring2])
          assert(built_geom_.eql?(parsed_geom_))
        end

        def test_wkt_creation_empty
          parsed_geom_ = @factory.parse_wkt("MULTILINESTRING EMPTY")
          assert_equal(::RGeo::Feature::MultiLineString, parsed_geom_.geometry_type)
          assert_equal(0, parsed_geom_.num_geometries)
          assert_equal([], parsed_geom_.to_a)
        end

        def test_clone
          geom1_ = @factory.multi_line_string([@linestring1, @linestring2])
          geom2_ = geom1_.clone
          assert(geom1_.eql?(geom2_))
          assert_equal(::RGeo::Feature::MultiLineString, geom2_.geometry_type)
          assert_equal(2, geom2_.num_geometries)
          assert(@linestring1.eql?(geom2_[0]))
          assert(@linestring2.eql?(geom2_[1]))
        end

        def test_type_check
          geom1_ = @factory.multi_line_string([@linestring1, @linestring2])
          assert(::RGeo::Feature::Geometry.check_type(geom1_))
          assert(!::RGeo::Feature::LineString.check_type(geom1_))
          assert(::RGeo::Feature::GeometryCollection.check_type(geom1_))
          assert(!::RGeo::Feature::MultiPoint.check_type(geom1_))
          assert(::RGeo::Feature::MultiLineString.check_type(geom1_))
          geom2_ = @factory.multi_line_string([])
          assert(::RGeo::Feature::Geometry.check_type(geom2_))
          assert(!::RGeo::Feature::LineString.check_type(geom2_))
          assert(::RGeo::Feature::GeometryCollection.check_type(geom2_))
          assert(!::RGeo::Feature::MultiPoint.check_type(geom2_))
          assert(::RGeo::Feature::MultiLineString.check_type(geom2_))
        end

        def test_as_text_wkt_round_trip
          geom1_ = @factory.multi_line_string([@linestring1, @linestring2])
          text_ = geom1_.as_text
          geom2_ = @factory.parse_wkt(text_)
          assert(geom1_.eql?(geom2_))
        end

        def test_as_binary_wkb_round_trip
          geom1_ = @factory.multi_line_string([@linestring1, @linestring2])
          binary_ = geom1_.as_binary
          geom2_ = @factory.parse_wkb(binary_)
          assert(geom1_.eql?(geom2_))
        end

        def test_dimension
          geom1_ = @factory.multi_line_string([@linestring1, @linestring2])
          assert_equal(1, geom1_.dimension)
          geom2_ = @factory.multi_line_string([])
          assert_equal(-1, geom2_.dimension)
        end

        def test_is_empty
          geom1_ = @factory.multi_line_string([@linestring1, @linestring2])
          assert(!geom1_.is_empty?)
          geom2_ = @factory.multi_line_string([])
          assert(geom2_.is_empty?)
        end

        def test_length
          geom1_ = @factory.multi_line_string([@linestring1, @linestring2])
          assert_equal(19, geom1_.length)
          geom2_ = @factory.multi_line_string([])
          assert_equal(0, geom2_.length)
        end

        def test_coordinates
          ml = @factory.multi_line_string([@linestring1, @linestring2])
          assert_equal(ml.coordinates, [@linestring1, @linestring2].map(&:coordinates))
        end
      end
    end
  end
end
