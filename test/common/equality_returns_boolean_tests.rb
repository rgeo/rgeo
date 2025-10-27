# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests to ensure equality methods return boolean values, not arrays
# Regression test for issue where rep_equals? returned arrays
#
# -----------------------------------------------------------------------------

module RGeo
  module Tests # :nodoc:
    module Common # :nodoc:
      module EqualityReturnsBooleanTests # :nodoc:
        def test_polygon_equality_returns_boolean_with_holes
          outer = @factory.line_string([
                                         @factory.point(0, 0),
                                         @factory.point(10, 0),
                                         @factory.point(10, 10),
                                         @factory.point(0, 10),
                                         @factory.point(0, 0)
                                       ])
          inner = @factory.line_string([
                                         @factory.point(2, 2),
                                         @factory.point(8, 2),
                                         @factory.point(8, 8),
                                         @factory.point(2, 8),
                                         @factory.point(2, 2)
                                       ])

          poly_a = @factory.polygon(outer, [inner])
          poly_b = @factory.polygon(
            @factory.line_string(outer.points),
            [@factory.line_string(inner.points)]
          )

          result = poly_a.eql?(poly_b)
          assert_equal(TrueClass, result.class, "eql? should return boolean, not #{result.class}")
          assert_equal(true, result)

          result2 = (poly_a == poly_b)
          assert_equal(TrueClass, result2.class, "== should return boolean, not #{result2.class}")
          assert_equal(true, result2)
        end

        def test_polygon_equality_returns_boolean_without_holes
          outer = @factory.line_string([
                                         @factory.point(0, 0),
                                         @factory.point(10, 0),
                                         @factory.point(10, 10),
                                         @factory.point(0, 10),
                                         @factory.point(0, 0)
                                       ])

          poly_a = @factory.polygon(outer, [])
          poly_b = @factory.polygon(@factory.line_string(outer.points), [])

          result = poly_a.eql?(poly_b)
          assert_equal(TrueClass, result.class, "eql? should return boolean, not #{result.class}")
          assert_equal(true, result)
        end

        def test_line_string_equality_returns_boolean
          line_a = @factory.line_string([
                                          @factory.point(0, 0),
                                          @factory.point(1, 1),
                                          @factory.point(2, 2)
                                        ])
          line_b = @factory.line_string([
                                          @factory.point(0, 0),
                                          @factory.point(1, 1),
                                          @factory.point(2, 2)
                                        ])

          result = line_a.eql?(line_b)
          assert_equal(TrueClass, result.class, "eql? should return boolean, not #{result.class}")
          assert_equal(true, result)

          result2 = (line_a == line_b)
          assert_equal(TrueClass, result2.class, "== should return boolean, not #{result2.class}")
          assert_equal(true, result2)
        end

        def test_geometry_collection_equality_returns_boolean
          coll_a = @factory.collection([
                                         @factory.point(0, 0),
                                         @factory.point(1, 1)
                                       ])
          coll_b = @factory.collection([
                                         @factory.point(0, 0),
                                         @factory.point(1, 1)
                                       ])

          result = coll_a.eql?(coll_b)
          assert_equal(TrueClass, result.class, "eql? should return boolean, not #{result.class}")
          assert_equal(true, result)

          result2 = (coll_a == coll_b)
          assert_equal(TrueClass, result2.class, "== should return boolean, not #{result2.class}")
          assert_equal(true, result2)
        end

        def test_polygon_inequality_returns_boolean
          outer1 = @factory.line_string([
                                          @factory.point(0, 0),
                                          @factory.point(10, 0),
                                          @factory.point(10, 10),
                                          @factory.point(0, 10),
                                          @factory.point(0, 0)
                                        ])
          outer2 = @factory.line_string([
                                          @factory.point(0, 0),
                                          @factory.point(5, 0),
                                          @factory.point(5, 5),
                                          @factory.point(0, 5),
                                          @factory.point(0, 0)
                                        ])

          poly_a = @factory.polygon(outer1)
          poly_b = @factory.polygon(outer2)

          result = poly_a.eql?(poly_b)
          assert_equal(FalseClass, result.class, "eql? should return boolean, not #{result.class}")
          assert_equal(false, result)
        end

        def test_line_string_inequality_returns_boolean
          line_a = @factory.line_string([
                                          @factory.point(0, 0),
                                          @factory.point(1, 1)
                                        ])
          line_b = @factory.line_string([
                                          @factory.point(0, 0),
                                          @factory.point(2, 2)
                                        ])

          result = line_a.eql?(line_b)
          assert_equal(FalseClass, result.class, "eql? should return boolean, not #{result.class}")
          assert_equal(false, result)
        end

        def test_geometry_collection_inequality_returns_boolean
          coll_a = @factory.collection([
                                         @factory.point(0, 0)
                                       ])
          coll_b = @factory.collection([
                                         @factory.point(1, 1)
                                       ])

          result = coll_a.eql?(coll_b)
          assert_equal(FalseClass, result.class, "eql? should return boolean, not #{result.class}")
          assert_equal(false, result)
        end
      end
    end
  end
end
