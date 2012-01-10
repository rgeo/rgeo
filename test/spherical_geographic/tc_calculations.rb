# -----------------------------------------------------------------------------
#
# Tests for the internal calculations for simple spherical
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
    module SphericalGeographic  # :nodoc:

      class TestCalculations < ::Test::Unit::TestCase  # :nodoc:


        def assert_close_enough(v1_, v2_)
          diff_ = (v1_ - v2_).abs
          # denom_ = (v1_ + v2_).abs
          # diff_ /= denom_ if denom_ > 0.01
          assert(diff_ < 0.00000001, "#{v1_} is not close to #{v2_}")
        end


        def test_point_eql
          point1_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
          point2_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
          assert_equal(point1_, point2_)
        end


        def test_point_from_latlng
          point1_ = ::RGeo::Geographic::SphericalMath::PointXYZ.from_latlon(45, -45)
          assert_close_enough(0.5, point1_.x)
          assert_close_enough(-0.5, point1_.y)
          assert_close_enough(::Math.sqrt(2) * 0.5, point1_.z)
        end


        def test_point_dot_one
          point1_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 1, 1)
          point2_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 1, 1)
          assert_close_enough(1.0, point1_ * point2_)
        end


        def test_point_dot_minusone
          point1_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 1, 1)
          point2_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(-1, -1, -1)
          assert_close_enough(-1.0, point1_ * point2_)
        end


        def test_point_dot_zero
          point1_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 1, 0)
          point2_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, -1, 0)
          assert_close_enough(0.0, point1_ * point2_)
        end


        def test_point_cross
          point1_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 1, 0)
          point2_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, -1, 0)
          assert_close_enough(-1.0, (point1_ % point2_).z)
        end


        def test_point_cross_coincident
          point1_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
          point2_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
          assert_nil(point1_ % point2_)
        end


        def test_point_cross_opposite
          point1_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
          point2_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(-1, 0, 0)
          assert_nil(point1_ % point2_)
        end


        def test_arc_axis
          point1_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 1, 0)
          point2_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, -1, 0)
          arc1_ = ::RGeo::Geographic::SphericalMath::ArcXYZ.new(point1_, point2_)
          assert_close_enough(-1.0, arc1_.axis.z)
        end


        def test_arc_axis2
          point1_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
          point2_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0.000001, 0)
          arc1_ = ::RGeo::Geographic::SphericalMath::ArcXYZ.new(point1_, point2_)
          assert_close_enough(1.0, arc1_.axis.z)
        end


        def test_arc_intersects_point_off
          point1_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
          point2_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0.000002, 0)
          point3_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0.000001, 0.1)
          arc1_ = ::RGeo::Geographic::SphericalMath::ArcXYZ.new(point1_, point2_)
          assert_equal(false, arc1_.contains_point?(point3_))
        end


        def test_arc_intersects_point_between
          point1_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
          point2_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0.000002, 0)
          point3_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0.000001, 0)
          arc1_ = ::RGeo::Geographic::SphericalMath::ArcXYZ.new(point1_, point2_)
          assert_equal(true, arc1_.contains_point?(point3_))
        end


        def test_arc_intersects_point_endpoint
          point1_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0, 0)
          point2_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(1, 0.000002, 0)
          arc1_ = ::RGeo::Geographic::SphericalMath::ArcXYZ.new(point1_, point2_)
          assert_equal(true, arc1_.contains_point?(point1_))
        end


        def test_arc_intersects_arc_true
          point1_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(0, 0.1, 1)
          point2_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(0, -0.1, 1)
          point3_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(-0.1, 0, 1)
          point4_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(0.1, 0, 1)
          arc1_ = ::RGeo::Geographic::SphericalMath::ArcXYZ.new(point1_, point2_)
          arc2_ = ::RGeo::Geographic::SphericalMath::ArcXYZ.new(point3_, point4_)
          assert_equal(true, arc1_.intersects_arc?(arc2_))
        end


        def test_arc_intersects_arc_parallel
          point1_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(0, 0.1, 1)
          point2_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(0, -0.1, 1)
          point3_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(0.1, 0.1, 1)
          point4_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(0.1, -0.1, 1)
          arc1_ = ::RGeo::Geographic::SphericalMath::ArcXYZ.new(point1_, point2_)
          arc2_ = ::RGeo::Geographic::SphericalMath::ArcXYZ.new(point3_, point4_)
          assert_equal(false, arc1_.intersects_arc?(arc2_))
        end


        def test_arc_intersects_arc_separated_tee
          point1_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(0, 0.1, 1)
          point2_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(0, -0.1, 1)
          point3_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(0.1, 0, 1)
          point4_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(0.2, 0, 1)
          arc1_ = ::RGeo::Geographic::SphericalMath::ArcXYZ.new(point1_, point2_)
          arc2_ = ::RGeo::Geographic::SphericalMath::ArcXYZ.new(point3_, point4_)
          assert_equal(false, arc1_.intersects_arc?(arc2_))
        end


        def test_arc_intersects_arc_connected_tee
          point1_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(0, 0.1, 1)
          point2_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(0, -0.1, 1)
          point3_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(0, 0, 1)
          point4_ = ::RGeo::Geographic::SphericalMath::PointXYZ.new(0.1, 0, 1)
          arc1_ = ::RGeo::Geographic::SphericalMath::ArcXYZ.new(point1_, point2_)
          arc2_ = ::RGeo::Geographic::SphericalMath::ArcXYZ.new(point3_, point4_)
          assert_equal(true, arc1_.intersects_arc?(arc2_))
        end


      end

    end
  end
end
