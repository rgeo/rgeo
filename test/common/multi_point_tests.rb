# -----------------------------------------------------------------------------
#
# Common tests for multi point implementations
#
# -----------------------------------------------------------------------------

require "rgeo"

module RGeo
  module Tests # :nodoc:
    module Common # :nodoc:
      module MultiPointTests # :nodoc:
        def setup
          @factory = create_factory
          @point1 = @factory.point(0, 0)
          @point2 = @factory.point(1, 0)
          @point3 = @factory.point(-4, 2)
          @point4 = @factory.point(-5, 3)
          @point5 = @factory.point(-5, 3)
        end

        def test_creation_simple
          geom_ = @factory.multi_point([@point1, @point2])
          assert_not_nil(geom_)
          assert(::RGeo::Feature::MultiPoint === geom_)
          assert_equal(::RGeo::Feature::MultiPoint, geom_.geometry_type)
          assert_equal(2, geom_.num_geometries)
          assert(@point1.eql?(geom_[0]))
          assert(@point2.eql?(geom_[1]))
        end

        def test_creation_empty
          geom_ = @factory.multi_point([])
          assert_not_nil(geom_)
          assert(::RGeo::Feature::MultiPoint === geom_)
          assert_equal(::RGeo::Feature::MultiPoint, geom_.geometry_type)
          assert_equal(0, geom_.num_geometries)
          assert_equal([], geom_.to_a)
        end

        def test_creation_casting
          mp1_ = @factory.collection([@point3])
          mp2_ = @factory.multi_point([@point4])
          geom_ = @factory.multi_point([@point1, @point2, mp1_, mp2_])
          assert_not_nil(geom_)
          assert_equal(::RGeo::Feature::MultiPoint, geom_.geometry_type)
          assert_equal(4, geom_.num_geometries)
          assert(@point1.eql?(geom_[0]))
          assert(@point2.eql?(geom_[1]))
          assert(@point3.eql?(geom_[2]))
          assert(@point4.eql?(geom_[3]))
        end

        def test_creation_wrong_type
          line_ = @factory.line_string([@point1, @point2])
          geom_ = @factory.multi_point([@point3, line_])
          assert_nil(geom_)
        end

        def test_required_equivalences
          geom1_ = @factory.multi_point([@point1, @point2])
          geom2_ = @factory.multi_point([@point1, @point2])
          assert(geom1_.eql?(geom2_))
          assert(geom1_ == geom2_)
        end

        def test_fully_equal
          geom1_ = @factory.multi_point([@point1, @point2])
          geom2_ = @factory.multi_point([@point1, @point2])
          assert(geom1_.rep_equals?(geom2_))
          assert(geom1_.equals?(geom2_))
        end

        def test_geometrically_equal
          geom1_ = @factory.multi_point([@point1, @point4])
          geom2_ = @factory.multi_point([@point1, @point4, @point5])
          assert(!geom1_.rep_equals?(geom2_))
          assert(geom1_.equals?(geom2_))
        end

        def test_not_equal
          geom1_ = @factory.multi_point([@point1, @point2])
          geom2_ = @factory.multi_point([@point1])
          assert(!geom1_.rep_equals?(geom2_))
          assert(!geom1_.equals?(geom2_))
        end

        def test_hashes_equal_for_representationally_equivalent_objects
          geom1_ = @factory.multi_point([@point1, @point2])
          geom2_ = @factory.multi_point([@point1, @point2])
          assert_equal(geom1_.hash, geom2_.hash)
        end

        def test_wkt_creation_simple
          parsed_geom_ = @factory.parse_wkt("MULTIPOINT((0 0), (-4 2), (-5 3))")
          built_geom_ = @factory.multi_point([@point1, @point3, @point4])
          assert(built_geom_.eql?(parsed_geom_))
        end

        def test_wkt_creation_empty
          parsed_geom_ = @factory.parse_wkt("MULTIPOINT EMPTY")
          assert(::RGeo::Feature::MultiPoint === parsed_geom_)
          assert_equal(0, parsed_geom_.num_geometries)
          assert_equal([], parsed_geom_.to_a)
        end

        def test_clone
          geom1_ = @factory.multi_point([@point1, @point2])
          geom2_ = geom1_.clone
          assert(geom1_.eql?(geom2_))
          assert_equal(::RGeo::Feature::MultiPoint, geom2_.geometry_type)
          assert_equal(2, geom2_.num_geometries)
          assert(@point1.eql?(geom2_[0]))
          assert(@point2.eql?(geom2_[1]))
        end

        def test_type_check
          geom1_ = @factory.multi_point([@point1, @point2])
          assert(::RGeo::Feature::Geometry.check_type(geom1_))
          assert(!::RGeo::Feature::Point.check_type(geom1_))
          assert(::RGeo::Feature::GeometryCollection.check_type(geom1_))
          assert(::RGeo::Feature::MultiPoint.check_type(geom1_))
          assert(!::RGeo::Feature::MultiLineString.check_type(geom1_))
          geom2_ = @factory.multi_point([])
          assert(::RGeo::Feature::Geometry.check_type(geom2_))
          assert(!::RGeo::Feature::Point.check_type(geom2_))
          assert(::RGeo::Feature::GeometryCollection.check_type(geom2_))
          assert(::RGeo::Feature::MultiPoint.check_type(geom2_))
          assert(!::RGeo::Feature::MultiLineString.check_type(geom2_))
        end

        def test_as_text_wkt_round_trip
          geom1_ = @factory.multi_point([@point1, @point2])
          text_ = geom1_.as_text
          geom2_ = @factory.parse_wkt(text_)
          assert(geom1_.eql?(geom2_))
        end

        def test_as_binary_wkb_round_trip
          geom1_ = @factory.multi_point([@point1, @point2])
          binary_ = geom1_.as_binary
          geom2_ = @factory.parse_wkb(binary_)
          assert(geom1_.eql?(geom2_))
        end

        def test_dimension
          geom1_ = @factory.multi_point([@point1, @point2])
          assert_equal(0, geom1_.dimension)
          geom2_ = @factory.multi_point([])
          assert_equal(-1, geom2_.dimension)
        end

        def test_is_empty
          geom1_ = @factory.multi_point([@point1, @point2])
          assert(!geom1_.is_empty?)
          geom2_ = @factory.multi_point([])
          assert(geom2_.is_empty?)
        end

        def test_union
          geom1_ = @factory.multi_point([@point1, @point2])
          geom2_ = @factory.multi_point([@point1, @point3])
          geom3_ = @factory.multi_point([@point1, @point2, @point3])
          assert_equal(geom3_, geom1_.union(geom2_))
          assert_equal(geom3_, geom1_ + geom2_)
        end

        def test_difference
          geom1_ = @factory.multi_point([@point1, @point2])
          geom2_ = @factory.multi_point([@point1, @point3])
          assert_equal(@point2, geom1_.difference(geom2_))
          assert_equal(@point2, geom1_ - geom2_)
        end

        def test_intersection
          geom1_ = @factory.multi_point([@point1, @point2])
          geom2_ = @factory.multi_point([@point1, @point3])
          assert_equal(@point1, geom1_.intersection(geom2_))
          assert_equal(@point1, geom1_ * geom2_)
        end

        def test_zm
          factory_ = create_factory(has_z_coordinate: true, has_m_coordinate: true)
          p1_ = factory_.point(1, 2, 3, 4)
          mp_ = factory_.multi_point([p1_])
          assert_equal(p1_, mp_[0])
        end

        def test_coordinate
          p0 = @factory.point(0, 0)
          p1 = @factory.point(1, 1)
          p2 = @factory.point(2, 2)
          points = [p0, p1, p2]
          mp = @factory.multi_point(points)
          assert_equal(mp.coordinates, points.map(&:coordinates))
        end
      end
    end
  end
end
