# frozen_string_literal: true

module RGeo
  module Tests
    module Common
      module ValidityTests
        def test_invalid_point_invalid_coordinate
          assert(@invalid_point.invalid_reason.include?(RGeo::ImplHelper::TopologyErrors::INVALID_COORDINATE))
          assert_equal(false, @invalid_point.valid?)
        end

        def test_valid_point
          pt = @point1
          assert_nil(pt.invalid_reason)
          assert(pt.valid?)
        end

        def test_invalid_line_string_invalid_coord
          ls = @factory.line_string([@invalid_point, @point1])
          assert_includes(ls.invalid_reason, RGeo::ImplHelper::TopologyErrors::INVALID_COORDINATE)
          assert_equal(false, ls.valid?)
        end

        def test_valid_line_string
          ls = @factory.line_string([@point1, @factory.point(1, 1)])
          assert_nil(ls.invalid_reason)
          assert(ls.valid?)
        end

        def test_invalid_linear_ring_invalid_coordinate
          lr = @factory.linear_ring([@point1, @invalid_point, @point2, @invalid_point, @point1])
          assert_includes(lr.invalid_reason, RGeo::ImplHelper::TopologyErrors::INVALID_COORDINATE)
          assert_equal(false, lr.valid?)
        end

        def test_invalid_linear_ring_self_intersection
          lr = @factory.linear_ring([@point1, @point2, @point3, @point4])
          assert_includes(lr.invalid_reason, RGeo::ImplHelper::TopologyErrors::SELF_INTERSECTION)
          assert_equal(false, lr.valid?)
        end

        def test_valid_linear_ring
          lr = @factory.linear_ring([@point1, @point3, @point2, @point4, @point1])
          assert_nil(lr.invalid_reason)
          assert(lr.valid?)
        end

        def test_invalid_polygon_invalid_coord
          lr = @factory.linear_ring([@point1, @invalid_point, @point2, @point4, @point1])
          poly1 = @factory.polygon(lr)
          assert_includes(poly1.invalid_reason, RGeo::ImplHelper::TopologyErrors::INVALID_COORDINATE)
          assert_equal(false, poly1.valid?)

          # test in hole
          poly2 = @factory.polygon(@big_square, [lr])
          assert_includes(poly2.invalid_reason, RGeo::ImplHelper::TopologyErrors::INVALID_COORDINATE)
          assert_equal(false, poly2.valid?)
        end

        def test_invalid_polygon_inconsistent_area
          pt1 = @factory.point(0, 0)
          pt2 = @factory.point(-6, 3)
          pt3 = @factory.point(0, 3)
          lr = @factory.linear_ring([pt1, pt2, pt3, pt1])
          poly = @factory.polygon(@big_square, [lr])

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
          poly2 = @factory.polygon(@big_square, [hole1, hole2])

          assert_includes(poly2.invalid_reason, RGeo::ImplHelper::TopologyErrors::SELF_INTERSECTION)
          assert_equal(false, poly2.valid?)
        end

        def test_invalid_polygon_duplicate_rings
          poly = @factory.polygon(@big_square, [@little_square, @little_square])
          assert_includes(poly.invalid_reason, RGeo::ImplHelper::TopologyErrors::DUPLICATE_RINGS)
          assert_equal(false, poly.valid?)
        end

        def test_invalid_polygon_self_intersecting_ring
          hourglass = @factory.linear_ring([@point1, @point2, @point3, @point4, @point1])
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

          poly = @factory.polygon(@little_square, [disjoint_hole])
          assert_includes(poly.invalid_reason, RGeo::ImplHelper::TopologyErrors::HOLE_OUTSIDE_SHELL)
          assert_equal(false, poly.valid?)

          # test a containing hole
          poly2 = @factory.polygon(@little_square, [@big_square])
          assert_includes(poly2.invalid_reason, RGeo::ImplHelper::TopologyErrors::HOLE_OUTSIDE_SHELL)
          assert_equal(false, poly2.valid?)
        end

        def test_invalid_polygon_nested_holes
          pt1 = @factory.point(0.33, 0.33)
          pt2 = @factory.point(0.66, 0.33)
          pt3 = @factory.point(0.66, 0.66)
          pt4 = @factory.point(0.33, 0.66)
          nested_hole = @factory.linear_ring([pt1, pt2, pt3, pt4, pt1])

          poly = @factory.polygon(@big_square, [@little_square, nested_hole])
          assert_includes(poly.invalid_reason, RGeo::ImplHelper::TopologyErrors::NESTED_HOLES)
          assert_equal(false, poly.valid?)
        end

        def test_invalid_polygon_disconnected_interior
          pt1 = @factory.point(0, 0.5)
          pt2 = @factory.point(0.5, 0)
          pt3 = @factory.point(1, 0.5)
          pt4 = @factory.point(0.5, 1)
          inscribed_diamond = @factory.linear_ring([pt1, pt2, pt3, pt4, pt1])

          poly = @factory.polygon(@little_square, [inscribed_diamond])
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
          poly2 = @factory.polygon(@little_square, [triangle1, triangle2])
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
          poly = @factory.polygon(@little_square, [triangle1, triangle2])

          assert_nil(poly.invalid_reason)
          assert(poly.valid?)
        end

        def test_invalid_multi_point_invalid_coordinate
          mp = @factory.multi_point([@invalid_point, @point1])
          assert_includes(mp.invalid_reason, RGeo::ImplHelper::TopologyErrors::INVALID_COORDINATE)
          assert_equal(false, mp.valid?)
        end

        def test_valid_multi_point
          mp = @factory.multi_point([@point1, @point2])
          assert_nil(mp.invalid_reason)
          assert(mp.valid?)
        end

        def test_multi_polygon_consistent_area
          pt1 = @factory.point(0.5, 0.5)
          pt2 = @factory.point(1.5, 0.5)
          pt3 = @factory.point(1.5, 1.5)
          pt4 = @factory.point(0.5, 1.5)

          shell1 = @little_square
          shell2 = @factory.linear_ring([pt1, pt2, pt3, pt4, pt1])
          mp = @factory.multi_polygon([@factory.polygon(shell1), @factory.polygon(shell2)])
          assert_includes(mp.invalid_reason, RGeo::ImplHelper::TopologyErrors::SELF_INTERSECTION)
          assert_equal(false, mp.valid?)
        end

        def test_multi_polygon_nested_shell
          shell1 = @little_square
          shell2 = @big_square
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
          shell2 = @little_square
          mp = @factory.multi_polygon([@factory.polygon(shell1), @factory.polygon(shell2)])

          assert_nil(mp.invalid_reason)
          assert(mp.valid?)
        end
      end
    end
  end
end
