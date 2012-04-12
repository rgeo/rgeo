# -----------------------------------------------------------------------------
#
# Tests for basic GeoJSON usage
#
# -----------------------------------------------------------------------------
# Copyright 2010-2012 Daniel Azuma
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the copyright holder, nor the names of any other
#   contributors to this software, may be used to endorse or promote products
#   derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# -----------------------------------------------------------------------------
;


require 'test/unit'
require 'rgeo'


module RGeo
  module Tests  # :nodoc:

    class TestCartesianBBox < ::Test::Unit::TestCase  # :nodoc:


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
        quads_.each{ |q_| assert_equal(2.0, q_.to_geometry.area) }
        quadsum_ = quads_[0].to_geometry + quads_[1].to_geometry +
          quads_[2].to_geometry + quads_[3].to_geometry
        assert_equal(bbox_.to_geometry, quadsum_)
      end


      def test_horiz_line_subdivide
        bbox_ = ::RGeo::Cartesian::BoundingBox.new(@factory)
        bbox_.add(@factory.point(1, 2))
        bbox_.add(@factory.point(5, 2))
        lines_ = bbox_.subdivide
        lines_.each{ |line_| assert_equal(2.0, line_.to_geometry.length) }
        linesum_ = lines_[0].to_geometry + lines_[1].to_geometry
        assert_equal(bbox_.to_geometry, linesum_)
      end


      def test_vert_line_subdivide
        bbox_ = ::RGeo::Cartesian::BoundingBox.new(@factory)
        bbox_.add(@factory.point(1, 2))
        bbox_.add(@factory.point(1, 6))
        lines_ = bbox_.subdivide
        lines_.each{ |line_| assert_equal(2.0, line_.to_geometry.length) }
        linesum_ = lines_[0].to_geometry + lines_[1].to_geometry
        assert_equal(bbox_.to_geometry, linesum_)
      end


    end

  end
end
