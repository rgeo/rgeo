# frozen_string_literal: true

module RGeo
  module Tests # :nodoc:
    module Common # :nodoc:
      module ValidityTests # :nodoc:
        def test_validity_correct_implementation
          assert(
            RGeo::ImplHelper::ValidityCheck.send(:classes).empty?,
            "`ValidityCheck.override_classes` was not called correctly"
          )
          assert(
            defined?(@factory),
            "Tests that include ValidityTests should have a @factory variable."
          )
          assert(
            @factory.point(1, 1).method(:invalid_reason).owner != RGeo::ImplHelper::ValidityCheck,
            "Current implementation must have an `invalid_reason` method for its geometries."
          )
        end

        def test_validity_unsafe_area
          assert_equal(0, bowtie_polygon.unsafe_area)
          assert_raises(RGeo::Error::InvalidGeometry) do
            bowtie_polygon.area
          end
          assert_equal(1, square_polygon.area)
        end

        def test_validity_make_valid
          skip "make_valid not handled by current implementation" unless implements_make_valid?

          assert_equal(0.5, bowtie_polygon.make_valid.area)
        end

        def implements_make_valid?
          square_polygon.method(:make_valid).owner != RGeo::ImplHelper::ValidityCheck
        end

        def square_polygon
          @square_polygon ||= @factory.polygon(
            @factory.linear_ring(
              [
                @factory.point(0, 0),
                @factory.point(1, 0),
                @factory.point(1, 1),
                @factory.point(0, 1),
                @factory.point(0, 0)
              ]
            )
          )
        end

        def bowtie_polygon
          @bowtie_polygon ||= @factory.polygon(
            @factory.linear_ring(
              [
                @factory.point(0, 0),
                @factory.point(1, 1),
                @factory.point(1, 0),
                @factory.point(0, 1),
                @factory.point(0, 0)
              ]
            )
          )
        end

        def test_invalid_point_invalid_coordinate
          assert(invalid_point.invalid_reason.include?(RGeo::ImplHelper::TopologyErrors::INVALID_COORDINATE))
          assert_equal(false, invalid_point.valid?)
        end

        def test_valid_point
          pt = point1
          assert_nil(pt.invalid_reason)
          assert(pt.valid?)
        end

        def test_invalid_line_string_invalid_coord
          ls = @factory.line_string([invalid_point, point1])
          assert_includes(ls.invalid_reason, RGeo::ImplHelper::TopologyErrors::INVALID_COORDINATE)
          assert_equal(false, ls.valid?)
        end

        def test_valid_line_string
          ls = @factory.line_string([point1, @factory.point(1, 1)])
          assert_nil(ls.invalid_reason)
          assert(ls.valid?)
        end

        def test_invalid_linear_ring_invalid_coordinate
          lr = @factory.linear_ring([point1, invalid_point, point2, invalid_point, point1])
          assert_includes(lr.invalid_reason, RGeo::ImplHelper::TopologyErrors::INVALID_COORDINATE)
          assert_equal(false, lr.valid?)
        end

        def test_invalid_linear_ring_self_intersection
          lr = @factory.linear_ring([point1, point2, point3, point4])
          assert_includes(lr.invalid_reason, RGeo::ImplHelper::TopologyErrors::SELF_INTERSECTION)
          assert_equal(false, lr.valid?)
        end

        def test_valid_linear_ring
          lr = @factory.linear_ring([point1, point3, point2, point4, point1])
          assert_nil(lr.invalid_reason)
          assert(lr.valid?)
        end

        def test_invalid_polygon_invalid_coord
          lr = @factory.linear_ring([point1, invalid_point, point2, point4, point1])
          poly1 = @factory.polygon(lr)
          assert_includes(poly1.invalid_reason, RGeo::ImplHelper::TopologyErrors::INVALID_COORDINATE)
          assert_equal(false, poly1.valid?)

          # test in hole
          poly2 = @factory.polygon(big_square, [lr])
          assert_includes(poly2.invalid_reason, RGeo::ImplHelper::TopologyErrors::INVALID_COORDINATE)
          assert_equal(false, poly2.valid?)
        end

        def test_invalid_polygon_inconsistent_area
          pt1 = @factory.point(0, 0)
          pt2 = @factory.point(-6, 3)
          pt3 = @factory.point(0, 3)
          lr = @factory.linear_ring([pt1, pt2, pt3, pt1])
          poly = @factory.polygon(big_square, [lr])

          assert_includes(poly.invalid_reason, RGeo::ImplHelper::TopologyErrors::SELF_INTERSECTION)
          assert_equal(false, poly.valid?)

          # intersecting holes
          pt4 = @factory.point(0, 0)
          pt5 = @factory.point(2, 0)
          pt6 = @factory.point(1, 2)

          pt7 = @factory.point(1, 1)
          pt8 = @factory.point(3, 1)
          pt9 = @factory.point(2, 3)

          hole1 = @factory.linear_ring([pt4, pt5, pt6, pt4])
          hole2 = @factory.linear_ring([pt7, pt8, pt9, pt7])
          poly2 = @factory.polygon(big_square, [hole1, hole2])

          assert_includes(poly2.invalid_reason, RGeo::ImplHelper::TopologyErrors::SELF_INTERSECTION)
          assert_equal(false, poly2.valid?)
        end

        def test_invalid_polygon_duplicate_rings
          poly = @factory.polygon(big_square, [little_square, little_square])
          assert_includes(poly.invalid_reason, RGeo::ImplHelper::TopologyErrors::SELF_INTERSECTION)
          assert_equal(false, poly.valid?)
        end

        def test_invalid_polygon_self_intersecting_ring
          hourglass = @factory.linear_ring([point1, point2, point3, point4, point1])
          poly = @factory.polygon(hourglass)
          assert_includes(poly.invalid_reason, RGeo::ImplHelper::TopologyErrors::SELF_INTERSECTION)
          assert_equal(false, poly.valid?)
        end

        def test_invalid_polygon_holes_not_in_shell
          pt1 = @factory.point(2, 2)
          pt2 = @factory.point(3, 2)
          pt3 = @factory.point(3, 3)
          pt4 = @factory.point(2, 3)
          disjoint_hole = @factory.linear_ring([pt1, pt2, pt3, pt4, pt1])

          poly = @factory.polygon(little_square, [disjoint_hole])
          assert_includes(poly.invalid_reason, RGeo::ImplHelper::TopologyErrors::HOLE_OUTSIDE_SHELL)
          assert_equal(false, poly.valid?)

          # test a containing hole
          poly2 = @factory.polygon(little_square, [big_square])
          assert_includes(poly2.invalid_reason, RGeo::ImplHelper::TopologyErrors::HOLE_OUTSIDE_SHELL)
          assert_equal(false, poly2.valid?)
        end

        def test_invalid_polygon_nested_holes
          pt1 = @factory.point(0.33, 0.33)
          pt2 = @factory.point(0.66, 0.33)
          pt3 = @factory.point(0.66, 0.66)
          pt4 = @factory.point(0.33, 0.66)
          nested_hole = @factory.linear_ring([pt1, pt2, pt3, pt4, pt1])

          poly = @factory.polygon(big_square, [little_square, nested_hole])
          assert_includes(poly.invalid_reason, RGeo::ImplHelper::TopologyErrors::NESTED_HOLES)
          assert_equal(false, poly.valid?)
        end

        def test_invalid_polygon_disconnected_interior
          pt1 = @factory.point(0, 0.5)
          pt2 = @factory.point(0.5, 0)
          pt3 = @factory.point(1, 0.5)
          pt4 = @factory.point(0.5, 1)
          inscribed_diamond = @factory.linear_ring([pt1, pt2, pt3, pt4, pt1])

          poly = @factory.polygon(little_square, [inscribed_diamond])
          assert_includes(poly.invalid_reason, RGeo::ImplHelper::TopologyErrors::DISCONNECTED_INTERIOR)
          assert_equal(false, poly.valid?)

          # test with touching triangles
          pt5 = @factory.point(0, 0.5)
          pt6 = @factory.point(0.25, 0.33)
          pt7 = @factory.point(0.5, 0.5)
          pt8 = @factory.point(0.75, 0.33)
          pt9 = @factory.point(1, 0.5)

          triangle1 = @factory.linear_ring([pt5, pt6, pt7, pt5])
          triangle2 = @factory.linear_ring([pt7, pt8, pt9, pt7])
          poly2 = @factory.polygon(little_square, [triangle1, triangle2])
          assert_includes(poly2.invalid_reason, RGeo::ImplHelper::TopologyErrors::DISCONNECTED_INTERIOR)
          assert_equal(false, poly2.valid?)
        end

        def test_valid_polygon
          pt1 = @factory.point(0, 0.5)
          pt2 = @factory.point(0.25, 0.33)
          pt3 = @factory.point(0.5, 0.5)
          pt4 = @factory.point(0.75, 0.33)
          pt5 = @factory.point(0.8, 0.5)

          triangle1 = @factory.linear_ring([pt1, pt2, pt3, pt1])
          triangle2 = @factory.linear_ring([pt3, pt4, pt5, pt3])
          poly = @factory.polygon(little_square, [triangle1, triangle2])

          assert_nil(poly.invalid_reason)
          assert(poly.valid?)
        end

        def test_invalid_multi_point_invalid_coordinate
          mp = @factory.multi_point([invalid_point, point1])
          assert_includes(mp.invalid_reason, RGeo::ImplHelper::TopologyErrors::INVALID_COORDINATE)
          assert_equal(false, mp.valid?)
        end

        def test_valid_multi_point
          mp = @factory.multi_point([point1, point2])
          assert_nil(mp.invalid_reason)
          assert(mp.valid?)
        end

        def test_multi_polygon_consistent_area
          pt1 = @factory.point(0.5, 0.5)
          pt2 = @factory.point(1.5, 0.5)
          pt3 = @factory.point(1.5, 1.5)
          pt4 = @factory.point(0.5, 1.5)

          shell1 = little_square
          shell2 = @factory.linear_ring([pt1, pt2, pt3, pt4, pt1])
          mp = @factory.multi_polygon([@factory.polygon(shell1), @factory.polygon(shell2)])
          assert_includes(mp.invalid_reason, RGeo::ImplHelper::TopologyErrors::SELF_INTERSECTION)
          assert_equal(false, mp.valid?)
        end

        def test_multi_polygon_nested_shell
          shell1 = little_square
          shell2 = big_square
          mp = @factory.multi_polygon([@factory.polygon(shell1), @factory.polygon(shell2)])
          assert_includes(mp.invalid_reason, RGeo::ImplHelper::TopologyErrors::NESTED_SHELLS)
          assert_equal(false, mp.valid?)
        end

        def test_multi_polygon_valid
          pt1 = @factory.point(2, 2)
          pt2 = @factory.point(3, 2)
          pt3 = @factory.point(3, 3)
          pt4 = @factory.point(2, 3)
          shell1 = @factory.linear_ring([pt1, pt2, pt3, pt4, pt1])
          shell2 = little_square
          mp = @factory.multi_polygon([@factory.polygon(shell1), @factory.polygon(shell2)])

          assert_nil(mp.invalid_reason)
          assert(mp.valid?)
        end

        private

        def invalid_point
          return @invalid_point if defined?(@invalid_point)

          @invalid_point = @factory.point(Float::INFINITY, 0)
        end

        def point1
          return @point1 if defined?(@point1)

          @point1 = @factory.point(0, 0)
        end

        def point2
          return @point2 if defined?(@point2)

          @point2 = @factory.point(1, 1)
        end

        def point3
          return @point3 if defined?(@point3)

          @point3 = @factory.point(0, 1)
        end

        def point4
          return @point4 if defined?(@point4)

          @point4 = @factory.point(1, 0)
        end

        def point5
          return @point5 if defined?(@point5)

          @point5 = @factory.point(-5, -5)
        end

        def point6
          return @point6 if defined?(@point6)

          @point6 = @factory.point(5, -5)
        end

        def point7
          return @point7 if defined?(@point7)

          @point7 = @factory.point(5, 5)
        end

        def point8
          return @point8 if defined?(@point8)

          @point8 = @factory.point(-5, 5)
        end

        def big_square
          return @big_square if defined?(@big_square)

          @big_square = @factory.linear_ring([point5, point6, point7, point8, point5])
        end

        def little_square
          return @little_square if defined?(@little_square)

          @little_square = @factory.linear_ring([point1, point3, point2, point4, point1])
        end
      end
    end
  end
end
