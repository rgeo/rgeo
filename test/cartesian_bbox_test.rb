# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for basic GeoJSON usage
#
# -----------------------------------------------------------------------------

require_relative "test_helper"

class CartesianBBoxTest < Minitest::Test # :nodoc:
  def setup
    @factory = RGeo::Cartesian.factory
  end

  def test_empty_bbox
    bbox = RGeo::Cartesian::BoundingBox.new(@factory)
    assert_equal(true, bbox.empty?)
    assert_equal(false, bbox.has_z)
    assert_nil(bbox.min_x)
    assert_equal(@factory, bbox.factory)
    assert_nil(bbox.min_point)
    assert_equal(true, bbox.to_geometry.empty?)
    assert_equal(true, bbox.contains?(bbox))
    assert_equal(false, bbox.contains?(@factory.point(1, 1)))
    assert_nil(bbox.center_x)
    assert_equal(0, bbox.x_span)
    assert_equal(0, bbox.subdivide.size)
  end

  def test_point_bbox
    empty_bbox = RGeo::Cartesian::BoundingBox.new(@factory)
    bbox = RGeo::Cartesian::BoundingBox.new(@factory)
    bbox.add(@factory.point(1, 2))
    assert_equal(false, bbox.empty?)
    assert_equal(false, bbox.has_z)
    assert_equal(1.0, bbox.min_x)
    assert_equal(2.0, bbox.min_y)
    assert_equal(1.0, bbox.max_x)
    assert_equal(2.0, bbox.max_y)
    assert_equal(@factory, bbox.factory)
    assert_equal(@factory.point(1, 2), bbox.min_point)
    assert_equal(@factory.point(1, 2), bbox.max_point)
    assert_equal(@factory.point(1, 2), bbox.to_geometry)
    assert_equal(true, bbox.contains?(empty_bbox))
    assert_equal(false, empty_bbox.contains?(bbox))
    assert_equal(true, bbox.contains?(@factory.point(1, 2)))
    assert_equal(false, bbox.contains?(@factory.point(2, 1)))
    assert_equal(1, bbox.center_x)
    assert_equal(0, bbox.x_span)
    assert_equal(2, bbox.center_y)
    assert_equal(0, bbox.y_span)
    assert_equal([bbox], bbox.subdivide)
  end

  def test_rect_bbox
    empty_bbox = RGeo::Cartesian::BoundingBox.new(@factory)
    bbox = RGeo::Cartesian::BoundingBox.new(@factory)
    bbox.add(@factory.point(1, 4))
    bbox.add(@factory.point(2, 3))
    assert_equal(false, bbox.empty?)
    assert_equal(false, bbox.has_z)
    assert_equal(1.0, bbox.min_x)
    assert_equal(3.0, bbox.min_y)
    assert_equal(2.0, bbox.max_x)
    assert_equal(4.0, bbox.max_y)
    assert_equal(@factory, bbox.factory)
    assert_equal(@factory.point(1, 3), bbox.min_point)
    assert_equal(@factory.point(2, 4), bbox.max_point)
    assert_equal(1.0, bbox.to_geometry.area)
    assert_equal(true, bbox.contains?(empty_bbox))
    assert_equal(false, empty_bbox.contains?(bbox))
    assert_equal(true, bbox.contains?(@factory.point(1, 3)))
    assert_equal(false, bbox.contains?(@factory.point(2, 1)))
    assert_equal(1.5, bbox.center_x)
    assert_equal(1, bbox.x_span)
    assert_equal(3.5, bbox.center_y)
    assert_equal(1, bbox.y_span)
  end

  def test_bbox_from_points
    bbox = RGeo::Cartesian::BoundingBox.new(@factory)
    bbox.add(@factory.point(1, 4))
    bbox.add(@factory.point(2, 3))
    bbox2 = RGeo::Cartesian::BoundingBox.create_from_points(
      @factory.point(2, 3), @factory.point(1, 4))
    assert_equal(bbox, bbox2)
  end

  def test_basic_rect_subdivide
    bbox = RGeo::Cartesian::BoundingBox.new(@factory)
    bbox.add(@factory.point(1, 2))
    bbox.add(@factory.point(5, 4))
    quads = bbox.subdivide
    quads.each { |q| assert_equal(2.0, q.to_geometry.area) }
    quadsum = quads[0].to_geometry + quads[1].to_geometry +
      quads[2].to_geometry + quads[3].to_geometry
    assert_equal(bbox.to_geometry, quadsum)
  end

  def test_horiz_line_subdivide
    bbox = RGeo::Cartesian::BoundingBox.new(@factory)
    bbox.add(@factory.point(1, 2))
    bbox.add(@factory.point(5, 2))
    lines = bbox.subdivide
    lines.each { |line| assert_equal(2.0, line.to_geometry.length) }
    linesum = lines[0].to_geometry + lines[1].to_geometry
    assert_equal(bbox.to_geometry, linesum)
  end

  def test_vert_line_subdivide
    bbox = RGeo::Cartesian::BoundingBox.new(@factory)
    bbox.add(@factory.point(1, 2))
    bbox.add(@factory.point(1, 6))
    lines = bbox.subdivide
    lines.each { |line| assert_equal(2.0, line.to_geometry.length) }
    linesum = lines[0].to_geometry + lines[1].to_geometry
    assert_equal(bbox.to_geometry, linesum)
  end
end
