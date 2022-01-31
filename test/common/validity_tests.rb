# frozen_string_literal: true

module RGeo
  module Tests # :nodoc:
    module Common # :nodoc:
      module ValidityTests # :nodoc:
        def test_validity_correct_implementation
          skip "Implementation #{@factory.class} does not implement ValidityCheck" unless implements_validity_check?

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
          skip "Implementation #{@factory.class} does not implement ValidityCheck" unless implements_validity_check?
          skip "#area not handled by current implementation" unless implements_area?

          assert_equal(0, bowtie_polygon.unsafe_area)
          assert_raises(RGeo::Error::InvalidGeometry) do
            bowtie_polygon.area
          end
          assert_equal(square_polygon_expected_area, square_polygon.area)
        end

        def test_validity_arguments
          skip "Implementation #{@factory.class} does not implement ValidityCheck" unless implements_validity_check?
          skip "#area not handled by current implementation" unless implements_area?

          poly1 = square_polygon
          poly2 = bowtie_polygon

          assert_raises(RGeo::Error::InvalidGeometry) do
            poly1.intersects?(poly2)
          end

          assert_raises(RGeo::Error::InvalidGeometry) do
            poly2.intersects?(poly1)
          end
        end

        def test_validity_make_valid
          skip "Implementation #{@factory.class} does not implement ValidityCheck" unless implements_validity_check?
          skip "#make_valid not handled by current implementation" unless implements_make_valid?

          assert_equal(bowtie_polygon_expected_area, bowtie_polygon.make_valid.area)
          assert_raises(RGeo::Error::UnsupportedOperation) do
            # A self intersecting ring cannot be made valid.
            bowtie_polygon.exterior_ring.make_valid
          end
        end

        def test_validity_no_symbol_methods
          rand_point = Enumerator.new do |yielder|
            loop { yielder << @factory.point(rand, rand) }
          end

          symbol_methods = [ # Check for every kind of geometry.
            point = rand_point.next,
            @factory.multi_point([point]),
            line_string = @factory.line_string([point, rand_point.next]),
            @factory.multi_line_string([line_string]),
            ring = @factory.linear_ring([point, rand_point.next, rand_point.next, point]),
            polygon = @factory.polygon(ring),
            @factory.multi_polygon([polygon])
          ].flat_map(&:methods).grep(/\Aunsafe_/).reject { |met| met.match?(/\A[a-z_?]+\z/) }
          assert(
            symbol_methods.empty?,
            "Some methods cannot be called in their simple form: #{symbol_methods.inspect}"
          )
        end

        def test_validity_invalid_reason
          assert_nil(square_polygon.invalid_reason)
          assert_equal("Self-intersection", bowtie_polygon.invalid_reason)
        end

        def implements_validity_check?
          square_polygon.is_a? RGeo::ImplHelper::ValidityCheck
        end

        def implements_make_valid?
          square_polygon.method(:make_valid).owner != RGeo::ImplHelper::ValidityCheck
        rescue NameError
          false
        end

        def implements_area?
          return @implements_area_p if defined?(@implements_area_p)

          begin
            square_polygon.unsafe_area
          rescue RGeo::Error::UnsupportedOperation
            @implements_area_p = false
          else
            @implements_area_p = true
          end
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

        def square_polygon_expected_area
          1
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

        def bowtie_polygon_expected_area
          square_polygon_expected_area / 2.0 # Once valid!
        end

        def test_invalid_point_invalid_coordinate
          assert_equal(RGeo::ImplHelper::TopologyErrors::INVALID_COORDINATE, invalid_point.invalid_reason)
          assert_equal(false, invalid_point.valid?)
        end

        def test_valid_point
          pt = point1
          assert_nil(pt.invalid_reason)
          assert(pt.valid?)
        end

        def test_invalid_line_string_invalid_coord
          ls = @factory.line_string([invalid_point, point1])
          assert_equal(RGeo::ImplHelper::TopologyErrors::INVALID_COORDINATE, ls.invalid_reason)
          assert_equal(false, ls.valid?)
        end

        def test_valid_line_string
          ls = @factory.line_string([point1, @factory.point(1, 1)])
          assert_nil(ls.invalid_reason)
          assert(ls.valid?)
        end

        def test_invalid_linear_ring_invalid_coordinate
          lr = @factory.linear_ring([point1, invalid_point, point2, invalid_point, point1])
          assert_equal(RGeo::ImplHelper::TopologyErrors::INVALID_COORDINATE, lr.invalid_reason)
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
          assert_equal(RGeo::ImplHelper::TopologyErrors::INVALID_COORDINATE, poly1.invalid_reason)
          assert_equal(false, poly1.valid?)

          # test in hole
          poly2 = @factory.polygon(big_square, [lr])
          assert_equal(RGeo::ImplHelper::TopologyErrors::INVALID_COORDINATE, poly2.invalid_reason)
          assert_equal(false, poly2.valid?)
        end

        def test_invalid_polygon_inconsistent_area
          pt1 = @factory.point(0, 0)
          pt2 = @factory.point(-6, 3)
          pt3 = @factory.point(0, 3)
          lr = @factory.linear_ring([pt1, pt2, pt3, pt1])
          poly = @factory.polygon(big_square, [lr])

          assert_equal(RGeo::ImplHelper::TopologyErrors::SELF_INTERSECTION, poly.invalid_reason)
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

          assert_equal(RGeo::ImplHelper::TopologyErrors::SELF_INTERSECTION, poly2.invalid_reason)
          assert_equal(false, poly2.valid?)
        end

        def test_invalid_polygon_duplicate_rings
          poly = @factory.polygon(big_square, [little_square, little_square])
          assert_equal(RGeo::ImplHelper::TopologyErrors::SELF_INTERSECTION, poly.invalid_reason)
          assert_equal(false, poly.valid?)
        end

        def test_invalid_polygon_self_intersecting_ring
          hourglass = @factory.linear_ring([point1, point2, point3, point4, point1])
          poly = @factory.polygon(hourglass)
          assert_equal(RGeo::ImplHelper::TopologyErrors::SELF_INTERSECTION, poly.invalid_reason)
          assert_equal(false, poly.valid?)
        end

        def test_invalid_polygon_holes_not_in_shell
          pt1 = @factory.point(2, 2)
          pt2 = @factory.point(3, 2)
          pt3 = @factory.point(3, 3)
          pt4 = @factory.point(2, 3)
          disjoint_hole = @factory.linear_ring([pt1, pt2, pt3, pt4, pt1])

          poly = @factory.polygon(little_square, [disjoint_hole])
          assert_equal(RGeo::ImplHelper::TopologyErrors::HOLE_OUTSIDE_SHELL, poly.invalid_reason)
          assert_equal(false, poly.valid?)

          # test a containing hole
          poly2 = @factory.polygon(little_square, [big_square])
          assert_equal(RGeo::ImplHelper::TopologyErrors::HOLE_OUTSIDE_SHELL, poly2.invalid_reason)
          assert_equal(false, poly2.valid?)
        end

        def test_invalid_polygon_nested_holes
          pt1 = @factory.point(0.33, 0.33)
          pt2 = @factory.point(0.66, 0.33)
          pt3 = @factory.point(0.66, 0.66)
          pt4 = @factory.point(0.33, 0.66)
          nested_hole = @factory.linear_ring([pt1, pt2, pt3, pt4, pt1])

          poly = @factory.polygon(big_square, [little_square, nested_hole])
          assert_equal(RGeo::ImplHelper::TopologyErrors::NESTED_HOLES, poly.invalid_reason)
          assert_equal(false, poly.valid?)
        end

        def test_invalid_polygon_disconnected_interior
          pt1 = @factory.point(0, 0.5)
          pt2 = @factory.point(0.5, 0)
          pt3 = @factory.point(1, 0.5)
          pt4 = @factory.point(0.5, 1)
          inscribed_diamond = @factory.linear_ring([pt1, pt2, pt3, pt4, pt1])

          poly = @factory.polygon(little_square, [inscribed_diamond])
          assert_equal(RGeo::ImplHelper::TopologyErrors::DISCONNECTED_INTERIOR, poly.invalid_reason)
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
          assert_equal(RGeo::ImplHelper::TopologyErrors::DISCONNECTED_INTERIOR, poly2.invalid_reason)
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
          assert_equal(RGeo::ImplHelper::TopologyErrors::INVALID_COORDINATE, mp.invalid_reason)
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
          assert_equal(RGeo::ImplHelper::TopologyErrors::SELF_INTERSECTION, mp.invalid_reason)
          assert_equal(false, mp.valid?)
        end

        def test_multi_polygon_nested_shell
          shell1 = little_square
          shell2 = big_square
          mp = @factory.multi_polygon([@factory.polygon(shell1), @factory.polygon(shell2)])
          assert_equal(RGeo::ImplHelper::TopologyErrors::NESTED_SHELLS, mp.invalid_reason)
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
