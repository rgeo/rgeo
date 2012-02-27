# -----------------------------------------------------------------------------
#
# Common tests for point implementations
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


require 'rgeo'


module RGeo
  module Tests  # :nodoc:
    module Common  # :nodoc:

      module PointTests  # :nodoc:


        def assert_close_enough(p1_, p2_)
          assert((p1_.x - p2_.x).abs < 0.00000001 && (p1_.y - p2_.y).abs < 0.00000001)
        end


        def assert_contains_approx(p_, mp_)
          assert(mp_.any?{ |q_| (p_.x - q_.x).abs < 0.00000001 && (p_.y - q_.y).abs < 0.00000001 })
        end


        def test_creation
          point_ = @factory.point(21, -22)
          assert_equal(21, point_.x)
          assert_equal(-22, point_.y)
        end


        def test_wkt_creation
          point1_ = @factory.parse_wkt('Point (21 -22)')
          assert_equal(21, point1_.x)
          assert_equal(-22, point1_.y)
        end


        def test_clone
          point1_ = @factory.point(11, 12)
          point2_ = point1_.clone
          assert_equal(point1_, point2_)
          point3_ = @factory.point(13, 12)
          point4_ = point3_.dup
          assert_equal(point3_, point4_)
          assert_not_equal(point2_, point4_)
        end


        def test_type_check
          point_ = @factory.point(21, 22)
          assert(::RGeo::Feature::Geometry.check_type(point_))
          assert(::RGeo::Feature::Point.check_type(point_))
          assert(!::RGeo::Feature::GeometryCollection.check_type(point_))
          assert(!::RGeo::Feature::Curve.check_type(point_))
        end


        def test_geometry_type
          point_ = @factory.point(11, 12)
          assert_equal(::RGeo::Feature::Point, point_.geometry_type)
        end


        def test_dimension
          point_ = @factory.point(11, 12)
          assert_equal(0, point_.dimension)
        end


        def test_envelope
          point_ = @factory.point(11, 12)
          assert_close_enough(point_, point_.envelope)
        end


        def test_as_text
          point_ = @factory.point(11, 12)
          assert_equal('POINT (11.0 12.0)', point_.as_text)
        end


        def test_as_text_wkt_round_trip
          point1_ = @factory.point(11, 12)
          text_ = point1_.as_text
          point2_ = @factory.parse_wkt(text_)
          assert_equal(point2_, point1_)
        end


        def test_as_binary_wkb_round_trip
          point1_ = @factory.point(211, 12)
          binary_ = point1_.as_binary
          point2_ = @factory.parse_wkb(binary_)
          assert_equal(point2_, point1_)
        end


        def test_is_empty
          point1_ = @factory.point(0, 0)
          assert(!point1_.is_empty?)
        end


        def test_is_simple
          point1_ = @factory.point(0, 0)
          assert(point1_.is_simple?)
        end


        def test_boundary
          point_ = @factory.point(11, 12)
          boundary_ = point_.boundary
          assert(boundary_.is_empty?)
        end


        def test_equals
          point1_ = @factory.point(11, 12)
          point2_ = @factory.point(11, 12)
          point3_ = @factory.point(13, 12)
          assert(point1_.equals?(point2_))
          assert(point1_ == point2_)
          assert(point1_.rep_equals?(point2_))
          assert(point1_.eql?(point2_))
          assert(!point1_.equals?(point3_))
          assert(point1_ != point3_)
          assert(!point1_.rep_equals?(point3_))
          assert(!point1_.eql?(point3_))
          assert(point1_ != 'hello')
          assert(!point1_.eql?('hello'))
        end


        def test_disjoint
          point1_ = @factory.point(11, 12)
          point2_ = @factory.point(11, 12)
          point3_ = @factory.point(12, 12)
          assert(!point1_.disjoint?(point2_))
          assert(point1_.disjoint?(point3_))
        end


        def test_intersects
          point1_ = @factory.point(11, 12)
          point2_ = @factory.point(11, 12)
          point3_ = @factory.point(12, 12)
          assert(point1_.intersects?(point2_))
          assert(!point1_.intersects?(point3_))
        end


        def test_touches
          point1_ = @factory.point(11, 12)
          point2_ = @factory.point(11, 12)
          point3_ = @factory.point(12, 12)
          assert(!point1_.touches?(point2_))
          assert(!point1_.touches?(point3_))
        end


        def test_crosses
          point1_ = @factory.point(11, 12)
          point2_ = @factory.point(11, 12)
          point3_ = @factory.point(12, 12)
          assert(!point1_.crosses?(point2_))
          assert(!point1_.crosses?(point3_))
        end


        def test_within
          point1_ = @factory.point(11, 12)
          point2_ = @factory.point(11, 12)
          point3_ = @factory.point(12, 12)
          assert(point1_.within?(point2_))
          assert(!point1_.within?(point3_))
        end


        def test_contains
          point1_ = @factory.point(11, 12)
          point2_ = @factory.point(11, 12)
          point3_ = @factory.point(12, 12)
          assert(point1_.contains?(point2_))
          assert(!point1_.contains?(point3_))
        end


        def test_overlaps
          point1_ = @factory.point(11, 12)
          point2_ = @factory.point(11, 12)
          point3_ = @factory.point(12, 12)
          assert(!point1_.overlaps?(point2_))
          assert(!point1_.overlaps?(point3_))
        end


        def test_convex_hull
          point_ = @factory.point(11, 12)
          assert_close_enough(point_, point_.convex_hull)
        end


        def test_intersection
          point1_ = @factory.point(11, 12)
          point2_ = @factory.point(11, 12)
          point3_ = @factory.point(12, 12)
          assert_close_enough(point1_, point1_.intersection(point2_))
          int13_ = point1_.intersection(point3_)
          assert(int13_.is_empty?)
        end


        def test_union
          point1_ = @factory.point(11, 12)
          point2_ = @factory.point(11, 12)
          point3_ = @factory.point(12, 12)
          union12_ = point1_.union(point2_)
          union13_ = point1_.union(point3_)
          assert_close_enough(point1_, union12_)
          assert_equal(::RGeo::Feature::MultiPoint, union13_.geometry_type)
          assert_contains_approx(point1_, union13_)
          assert_contains_approx(point3_, union13_)
        end


        def test_difference
          point1_ = @factory.point(11, 12)
          point2_ = @factory.point(11, 12)
          point3_ = @factory.point(12, 12)
          diff12_ = point1_.difference(point2_)
          diff13_ = point1_.difference(point3_)
          assert_equal(::RGeo::Feature::GeometryCollection, diff12_.geometry_type)
          assert(diff12_.is_empty?)
          assert_close_enough(point1_, diff13_)
        end


        def test_sym_difference
          point1_ = @factory.point(11, 12)
          point2_ = @factory.point(11, 12)
          point3_ = @factory.point(12, 12)
          diff12_ = point1_.sym_difference(point2_)
          diff13_ = point1_.sym_difference(point3_)
          assert_equal(::RGeo::Feature::GeometryCollection, diff12_.geometry_type)
          assert(diff12_.is_empty?)
          assert_equal(::RGeo::Feature::MultiPoint, diff13_.geometry_type)
          assert_contains_approx(point1_, diff13_)
          assert_contains_approx(point3_, diff13_)
        end


        def test_3dz_creation
          point_ = @zfactory.point(11, 12, 13)
          assert_equal(11, point_.x)
          assert_equal(12, point_.y)
          assert_equal(13, point_.z)
          point2_ = @zfactory.point(21, 22)
          assert_equal(21, point2_.x)
          assert_equal(22, point2_.y)
          assert_equal(0, point2_.z)
        end


        def test_3dm_creation
          point_ = @mfactory.point(11, 12, 13)
          assert_equal(11, point_.x)
          assert_equal(12, point_.y)
          assert_equal(13, point_.m)
          point2_ = @mfactory.point(21, 22)
          assert_equal(21, point2_.x)
          assert_equal(22, point2_.y)
          assert_equal(0, point2_.m)
        end


        def test_4d_creation
          point_ = @zmfactory.point(11, 12, 13, 14)
          assert_equal(11, point_.x)
          assert_equal(12, point_.y)
          assert_equal(13, point_.z)
          assert_equal(14, point_.m)
          point2_ = @zmfactory.point(21, 22)
          assert_equal(21, point2_.x)
          assert_equal(22, point2_.y)
          assert_equal(0, point2_.z)
          assert_equal(0, point2_.m)
        end


        def test_wkt_creation_3d
          point2_ = @zfactory.parse_wkt('POINT(11 12 13)')
          assert_equal(11, point2_.x)
          assert_equal(12, point2_.y)
          assert_equal(13, point2_.z)
          point1_ = @zfactory.parse_wkt('POINT(21 22)')
          assert_equal(21, point1_.x)
          assert_equal(22, point1_.y)
          # Z is undefined in this case.
          # We'd like to define it to be 0, but the GEOS
          # parser doesn't behave that way.
        end


      end

    end
  end
end
