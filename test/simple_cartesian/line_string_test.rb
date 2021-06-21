# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the simple cartesian line string implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class CartesianLineStringTest < Minitest::Test # :nodoc:
  def setup
    @factory = RGeo::Cartesian.simple_factory
  end

  include RGeo::Tests::Common::LineStringTests

  def test_linestring_crosses
    # disjoint
    pt1 = @factory.point(0, 0)
    pt2 = @factory.point(1, 0)
    pt3 = @factory.point(1, 1)
    pt4 = @factory.point(0, 1)

    sq = @factory.line_string([pt1, pt2, pt3, pt4, pt1])

    pt6 = @factory.point(2, 2)
    pt7 = @factory.point(3, 3)
    pt8 = @factory.point(3, 2)
    pt9 = @factory.point(2, 3)

    hourglass = @factory.line_string([pt6, pt7, pt8, pt9, pt6])
    refute sq.crosses?(hourglass)

    # touches at point
    pt10 = @factory.point(1, 2)
    pt11 = @factory.point(2, 2)
    pt12 = @factory.point(2, 1)

    sq2 = @factory.line_string([pt3, pt10, pt11, pt12, pt3])
    refute sq.crosses? sq2

    # crosses
    pt13 = @factory.point(0.5, 0.5)
    pt14 = @factory.point(1.5, 0.5)
    pt15 = @factory.point(1.5, 1.5)
    pt16 = @factory.point(0.5, 1.5)

    sq3 = @factory.line_string([pt13, pt14, pt15, pt16, pt13])
    assert sq.crosses? sq3
  end

  undef_method :test_fully_equal
  undef_method :test_geometrically_equal_but_different_type
  undef_method :test_geometrically_equal_but_different_type2
  undef_method :test_geometrically_equal_but_different_overlap
  undef_method :test_empty_equal
  undef_method :test_not_equal
  undef_method :test_point_on_surface
end
