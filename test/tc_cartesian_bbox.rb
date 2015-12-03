# -----------------------------------------------------------------------------
#
# Tests for basic GeoJSON usage
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

module RGeo
  module Tests # :nodoc:
    class TestCartesianBBox < ::Test::Unit::TestCase # :nodoc:
      def setup
        @factory = ::RGeo::Cartesian.factory
      end

      def test_empty_bbox
        bbox_ = ::RGeo::Cartesian::BoundingBox.new(@factory)
        assert_equal(true, bbox_.empty?)
        assert_equal(false, bbox_.has_z)
        assert_nil(bbox_.min_x)
        assert_equal(@factory, bbox_.factory)
        assert_nil(bbox_.min_point)
        assert_equal(true, bbox_.to_geometry.is_empty?)
        assert_equal(true, bbox_.contains?(bbox_))
        assert_equal(false, bbox_.contains?(@factory.point(1, 1)))
        assert_nil(bbox_.center_x)
        assert_equal(0, bbox_.x_span)
        assert_equal(0, bbox_.subdivide.size)
      end

      def test_point_bbox
        empty_bbox_ = ::RGeo::Cartesian::BoundingBox.new(@factory)
        bbox_ = ::RGeo::Cartesian::BoundingBox.new(@factory)
        bbox_.add(@factory.point(1, 2))
        assert_equal(false, bbox_.empty?)
        assert_equal(false, bbox_.has_z)
        assert_equal(1.0, bbox_.min_x)
        assert_equal(2.0, bbox_.min_y)
        assert_equal(1.0, bbox_.max_x)
        assert_equal(2.0, bbox_.max_y)
        assert_equal(@factory, bbox_.factory)
        assert_equal(@factory.point(1, 2), bbox_.min_point)
        assert_equal(@factory.point(1, 2), bbox_.max_point)
        assert_equal(@factory.point(1, 2), bbox_.to_geometry)
        assert_equal(true, bbox_.contains?(empty_bbox_))
        assert_equal(false, empty_bbox_.contains?(bbox_))
        assert_equal(true, bbox_.contains?(@factory.point(1, 2)))
        assert_equal(false, bbox_.contains?(@factory.point(2, 1)))
        assert_equal(1, bbox_.center_x)
        assert_equal(0, bbox_.x_span)
        assert_equal(2, bbox_.center_y)
        assert_equal(0, bbox_.y_span)
        assert_equal([bbox_], bbox_.subdivide)
      end

      def test_rect_bbox
        empty_bbox_ = ::RGeo::Cartesian::BoundingBox.new(@factory)
        bbox_ = ::RGeo::Cartesian::BoundingBox.new(@factory)
        bbox_.add(@factory.point(1, 4))
        bbox_.add(@factory.point(2, 3))
        assert_equal(false, bbox_.empty?)
        assert_equal(false, bbox_.has_z)
        assert_equal(1.0, bbox_.min_x)
        assert_equal(3.0, bbox_.min_y)
        assert_equal(2.0, bbox_.max_x)
        assert_equal(4.0, bbox_.max_y)
        assert_equal(@factory, bbox_.factory)
        assert_equal(@factory.point(1, 3), bbox_.min_point)
        assert_equal(@factory.point(2, 4), bbox_.max_point)
        assert_equal(1.0, bbox_.to_geometry.area)
        assert_equal(true, bbox_.contains?(empty_bbox_))
        assert_equal(false, empty_bbox_.contains?(bbox_))
        assert_equal(true, bbox_.contains?(@factory.point(1, 3)))
        assert_equal(false, bbox_.contains?(@factory.point(2, 1)))
        assert_equal(1.5, bbox_.center_x)
        assert_equal(1, bbox_.x_span)
        assert_equal(3.5, bbox_.center_y)
        assert_equal(1, bbox_.y_span)
      end

      def test_bbox_from_points
        bbox_ = ::RGeo::Cartesian::BoundingBox.new(@factory)
        bbox_.add(@factory.point(1, 4))
        bbox_.add(@factory.point(2, 3))
        bbox2_ = ::RGeo::Cartesian::BoundingBox.create_from_points(
          @factory.point(2, 3), @factory.point(1, 4))
        assert_equal(bbox_, bbox2_)
      end

      def test_basic_rect_subdivide
        bbox_ = ::RGeo::Cartesian::BoundingBox.new(@factory)
        bbox_.add(@factory.point(1, 2))
        bbox_.add(@factory.point(5, 4))
        quads_ = bbox_.subdivide
        quads_.each { |q_| assert_equal(2.0, q_.to_geometry.area) }
        quadsum_ = quads_[0].to_geometry + quads_[1].to_geometry +
          quads_[2].to_geometry + quads_[3].to_geometry
        assert_equal(bbox_.to_geometry, quadsum_)
      end

      def test_horiz_line_subdivide
        bbox_ = ::RGeo::Cartesian::BoundingBox.new(@factory)
        bbox_.add(@factory.point(1, 2))
        bbox_.add(@factory.point(5, 2))
        lines_ = bbox_.subdivide
        lines_.each { |line_| assert_equal(2.0, line_.to_geometry.length) }
        linesum_ = lines_[0].to_geometry + lines_[1].to_geometry
        assert_equal(bbox_.to_geometry, linesum_)
      end

      def test_vert_line_subdivide
        bbox_ = ::RGeo::Cartesian::BoundingBox.new(@factory)
        bbox_.add(@factory.point(1, 2))
        bbox_.add(@factory.point(1, 6))
        lines_ = bbox_.subdivide
        lines_.each { |line_| assert_equal(2.0, line_.to_geometry.length) }
        linesum_ = lines_[0].to_geometry + lines_[1].to_geometry
        assert_equal(bbox_.to_geometry, linesum_)
      end
    end
  end
end
