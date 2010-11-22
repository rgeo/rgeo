# -----------------------------------------------------------------------------
# 
# A container file for one-off tests
# 
# -----------------------------------------------------------------------------
# Copyright 2010 Daniel Azuma
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
    module Shapefile
      
      class TestShapelibTests < ::Test::Unit::TestCase  # :nodoc:
        
        def _open_shapefile(name_, &block_)
          RGeo::Shapefile::Reader.open(::File.expand_path("shapelib_testcases/#{name_}", ::File.dirname(__FILE__)), :factory_generator => ::RGeo::Cartesian.method(:simple_factory), &block_)
        end
        
        
        def test_rewind
          _open_shapefile('test') do |file_|
            assert_equal(0, file_.cur_index)
            rec_ = file_.next
            assert_equal(0, rec_.index)
            assert_equal(1, rec_.geometry[0].num_interior_rings)
            assert_equal(1, file_.cur_index)
            file_.rewind
            assert_equal(0, file_.cur_index)
            rec_ = file_.next
            assert_equal(0, rec_.index)
            assert_equal(1, rec_.geometry[0].num_interior_rings)
          end
        end
        
        
        def test_seek
          _open_shapefile('test') do |file_|
            assert_equal(0, file_.cur_index)
            assert_equal(false, file_.seek_index(4))
            assert_equal(0, file_.cur_index)
            file_.seek_index(3)
            assert_equal(3, file_.cur_index)
            assert_nil(file_.next)
            file_.seek_index(2)
            assert_equal(2, file_.cur_index)
            rec_ = file_.next
            assert_equal(2, rec_.index)
            assert_equal(0, rec_.geometry[0].num_interior_rings)
            assert_equal('', rec_['Descriptio'])
            file_.seek_index(0)
            assert_equal(0, file_.cur_index)
            rec_ = file_.next
            assert_equal(0, rec_.index)
            assert_equal(1, rec_.geometry[0].num_interior_rings)
          end
        end
        
        
        def test_attributes
          _open_shapefile('test') do |file_|
            rec_ = file_.next
            assert_equal('Square with triangle missing', rec_['Descriptio'])
            assert_equal(1, rec_['TestInt'])
            assert_equal(2.5, rec_['TestDouble'])
            assert_nil(rec_['NotAKey'])
            rec_ = file_.next
            assert_equal('Smaller triangle', rec_['Descriptio'])
            assert_equal(100, rec_['TestInt'])
            assert_equal(1000.25, rec_['TestDouble'])
            rec_ = file_.next
            assert_equal('', rec_['Descriptio'])
            assert_equal(0, rec_['TestInt'])
            assert_equal(0, rec_['TestDouble'])
          end
        end
        
        
        def test_test0
          _open_shapefile('test0') do |file_|
            assert_equal(0, file_.shape_type_code)
            assert_equal(2, file_.num_records)
            rec_ = file_.next
            assert_equal(0, rec_.index)
            assert_nil(rec_.geometry)
            rec_ = file_.next
            assert_equal(1, rec_.index)
            assert_nil(rec_.geometry)
            assert_nil(file_.next)
          end
        end
        
        
        def _test_point_shapefile(filename_, has_z_, has_m_)
          _open_shapefile(filename_) do |file_|
            assert_equal(has_z_ ? 11 : has_m_ ? 21 : 1, file_.shape_type_code)
            assert_equal(2, file_.num_records)
            assert_equal(has_z_, file_.factory.has_capability?(:z_coordinate))
            assert_equal(has_m_, file_.factory.has_capability?(:m_coordinate))
            rec_ = file_.next
            assert_equal(0, rec_.index)
            assert_equal(::RGeo::Features::Point, rec_.geometry.geometry_type)
            assert_equal(1, rec_.geometry.x)
            assert_equal(2, rec_.geometry.y)
            assert_equal(3, rec_.geometry.z) if has_z_
            assert_equal(4, rec_.geometry.m) if has_m_
            rec_ = file_.next
            assert_equal(1, rec_.index)
            assert_equal(::RGeo::Features::Point, rec_.geometry.geometry_type)
            assert_equal(10, rec_.geometry.x)
            assert_equal(20, rec_.geometry.y)
            assert_equal(30, rec_.geometry.z) if has_z_
            assert_equal(40, rec_.geometry.m) if has_m_
            assert_nil(file_.next)
          end
        end
        
        
        def test_test1
          _test_point_shapefile('test1', false, false)
        end
        
        
        def test_test2
          _test_point_shapefile('test2', true, true)
        end
        
        
        def test_test3
          _test_point_shapefile('test3', false, true)
        end
        
        
        def _test_multipoint_shapefile(filename_, has_z_, has_m_)
          _open_shapefile(filename_) do |file_|
            assert_equal(has_z_ ? 18 : has_m_ ? 28 : 8, file_.shape_type_code)
            assert_equal(3, file_.num_records)
            assert_equal(has_z_, file_.factory.has_capability?(:z_coordinate))
            assert_equal(has_m_, file_.factory.has_capability?(:m_coordinate))
            rec_ = file_.next
            assert_equal(::RGeo::Features::MultiPoint, rec_.geometry.geometry_type)
            assert_equal(4, rec_.geometry.num_geometries)
            assert_equal(1.15, rec_.geometry[0].x)
            assert_equal(2.25, rec_.geometry[0].y)
            assert_equal(3.35, rec_.geometry[0].z) if has_z_
            assert_equal(4.45, rec_.geometry[0].m) if has_m_
            assert_equal(4.15, rec_.geometry[3].x)
            assert_equal(5.25, rec_.geometry[3].y)
            assert_equal(6.35, rec_.geometry[3].z) if has_z_
            assert_equal(7.45, rec_.geometry[3].m) if has_m_
            rec_ = file_.next
            assert_equal(::RGeo::Features::MultiPoint, rec_.geometry.geometry_type)
            assert_equal(4, rec_.geometry.num_geometries)
            rec_ = file_.next
            assert_equal(::RGeo::Features::MultiPoint, rec_.geometry.geometry_type)
            assert_equal(4, rec_.geometry.num_geometries)
            assert_equal(21.15, rec_.geometry[0].x)
            assert_equal(22.25, rec_.geometry[0].y)
            assert_equal(23.35, rec_.geometry[0].z) if has_z_
            assert_equal(24.45, rec_.geometry[0].m) if has_m_
            assert_equal(24.15, rec_.geometry[3].x)
            assert_equal(25.25, rec_.geometry[3].y)
            assert_equal(26.35, rec_.geometry[3].z) if has_z_
            assert_equal(27.45, rec_.geometry[3].m) if has_m_
            assert_nil(file_.next)
          end
        end
        
        
        def test_test4
          _test_multipoint_shapefile('test4', false, false)
        end
        
        
        def test_test5
          _test_multipoint_shapefile('test5', true, true)
        end
        
        
        def test_test6
          _test_multipoint_shapefile('test6', false, true)
        end
        
        
        def _test_polyline_shapefile(filename_, has_z_, has_m_)
          _open_shapefile(filename_) do |file_|
            assert_equal(has_z_ ? 13 : has_m_ ? 23 : 3, file_.shape_type_code)
            assert_equal(4, file_.num_records)
            assert_equal(has_z_, file_.factory.has_capability?(:z_coordinate))
            assert_equal(has_m_, file_.factory.has_capability?(:m_coordinate))
            rec_ = file_.next
            assert_equal(::RGeo::Features::MultiLineString, rec_.geometry.geometry_type)
            assert_equal(1, rec_.geometry.num_geometries)
            assert_equal(5, rec_.geometry[0].num_points)
            assert_equal(1, rec_.geometry[0].point_n(0).x)
            assert_equal(1, rec_.geometry[0].point_n(0).y)
            assert_equal(3.35, rec_.geometry[0].point_n(0).z) if has_z_
            assert_equal(4.45, rec_.geometry[0].point_n(0).m) if has_m_
            assert_equal(2, rec_.geometry[0].point_n(1).x)
            assert_equal(1, rec_.geometry[0].point_n(1).y)
            assert_equal(4.35, rec_.geometry[0].point_n(1).z) if has_z_
            assert_equal(5.45, rec_.geometry[0].point_n(1).m) if has_m_
            assert_equal(2, rec_.geometry[0].point_n(2).x)
            assert_equal(2, rec_.geometry[0].point_n(2).y)
            assert_equal(5.35, rec_.geometry[0].point_n(2).z) if has_z_
            assert_equal(6.45, rec_.geometry[0].point_n(2).m) if has_m_
            assert_equal(1, rec_.geometry[0].point_n(4).x)
            assert_equal(1, rec_.geometry[0].point_n(4).y)
            assert_equal(7.35, rec_.geometry[0].point_n(4).z) if has_z_
            assert_equal(8.45, rec_.geometry[0].point_n(4).m) if has_m_
            rec_ = file_.next
            assert_equal(::RGeo::Features::MultiLineString, rec_.geometry.geometry_type)
            assert_equal(1, rec_.geometry.num_geometries)
            rec_ = file_.next
            assert_equal(::RGeo::Features::MultiLineString, rec_.geometry.geometry_type)
            assert_equal(1, rec_.geometry.num_geometries)
            assert_equal(5, rec_.geometry[0].num_points)
            assert_equal(1, rec_.geometry[0].point_n(0).x)
            assert_equal(7, rec_.geometry[0].point_n(0).y)
            assert_equal(23.35, rec_.geometry[0].point_n(0).z) if has_z_
            assert_equal(24.45, rec_.geometry[0].point_n(0).m) if has_m_
            assert_equal(2, rec_.geometry[0].point_n(1).x)
            assert_equal(7, rec_.geometry[0].point_n(1).y)
            assert_equal(24.35, rec_.geometry[0].point_n(1).z) if has_z_
            assert_equal(25.45, rec_.geometry[0].point_n(1).m) if has_m_
            assert_equal(2, rec_.geometry[0].point_n(2).x)
            assert_equal(8, rec_.geometry[0].point_n(2).y)
            assert_equal(25.35, rec_.geometry[0].point_n(2).z) if has_z_
            assert_equal(26.45, rec_.geometry[0].point_n(2).m) if has_m_
            assert_equal(1, rec_.geometry[0].point_n(4).x)
            assert_equal(7, rec_.geometry[0].point_n(4).y)
            assert_equal(27.35, rec_.geometry[0].point_n(4).z) if has_z_
            assert_equal(28.45, rec_.geometry[0].point_n(4).m) if has_m_
            rec_ = file_.next
            assert_equal(::RGeo::Features::MultiLineString, rec_.geometry.geometry_type)
            assert_equal(3, rec_.geometry.num_geometries)
            assert_equal(5, rec_.geometry[0].num_points)
            assert_equal(0, rec_.geometry[0].point_n(0).x)
            assert_equal(0, rec_.geometry[0].point_n(0).y)
            assert_equal(0, rec_.geometry[0].point_n(0).z) if has_z_
            assert_equal(0, rec_.geometry[0].point_n(0).m) if has_m_
            assert_equal(0, rec_.geometry[0].point_n(1).x)
            assert_equal(100, rec_.geometry[0].point_n(1).y)
            assert_equal(1, rec_.geometry[0].point_n(1).z) if has_z_
            assert_equal(2, rec_.geometry[0].point_n(1).m) if has_m_
            assert_equal(0, rec_.geometry[0].point_n(4).x)
            assert_equal(0, rec_.geometry[0].point_n(4).y)
            assert_equal(4, rec_.geometry[0].point_n(4).z) if has_z_
            assert_equal(8, rec_.geometry[0].point_n(4).m) if has_m_
            assert_equal(5, rec_.geometry[1].num_points)
            assert_equal(10, rec_.geometry[1].point_n(0).x)
            assert_equal(20, rec_.geometry[1].point_n(0).y)
            assert_equal(5, rec_.geometry[1].point_n(0).z) if has_z_
            assert_equal(10, rec_.geometry[1].point_n(0).m) if has_m_
            assert_equal(30, rec_.geometry[1].point_n(1).x)
            assert_equal(20, rec_.geometry[1].point_n(1).y)
            assert_equal(6, rec_.geometry[1].point_n(1).z) if has_z_
            assert_equal(12, rec_.geometry[1].point_n(1).m) if has_m_
            assert_equal(30, rec_.geometry[1].point_n(2).x)
            assert_equal(40, rec_.geometry[1].point_n(2).y)
            assert_equal(7, rec_.geometry[1].point_n(2).z) if has_z_
            assert_equal(14, rec_.geometry[1].point_n(2).m) if has_m_
            assert_equal(5, rec_.geometry[2].num_points)
            assert_equal(60, rec_.geometry[2].point_n(0).x)
            assert_equal(20, rec_.geometry[2].point_n(0).y)
            assert_equal(10, rec_.geometry[2].point_n(0).z) if has_z_
            assert_equal(20, rec_.geometry[2].point_n(0).m) if has_m_
            assert_equal(90, rec_.geometry[2].point_n(1).x)
            assert_equal(20, rec_.geometry[2].point_n(1).y)
            assert_equal(11, rec_.geometry[2].point_n(1).z) if has_z_
            assert_equal(22, rec_.geometry[2].point_n(1).m) if has_m_
            assert_equal(60, rec_.geometry[2].point_n(4).x)
            assert_equal(20, rec_.geometry[2].point_n(4).y)
            assert_equal(14, rec_.geometry[2].point_n(4).z) if has_z_
            assert_equal(28, rec_.geometry[2].point_n(4).m) if has_m_
          end
        end
        
        
        def test_test7
          _test_polyline_shapefile('test7', false, false)
        end
        
        
        def test_test8
          _test_polyline_shapefile('test8', true, true)
        end
        
        
        def test_test9
          _test_polyline_shapefile('test9', false, true)
        end
        
        
        def _test_polygon_shapefile(filename_, has_z_, has_m_)
          _open_shapefile(filename_) do |file_|
            assert_equal(has_z_ ? 15 : has_m_ ? 25 : 5, file_.shape_type_code)
            assert_equal(4, file_.num_records)
            assert_equal(has_z_, file_.factory.has_capability?(:z_coordinate))
            assert_equal(has_m_, file_.factory.has_capability?(:m_coordinate))
            rec_ = file_.next
            assert_equal(::RGeo::Features::MultiPolygon, rec_.geometry.geometry_type)
            assert_equal(1, rec_.geometry.num_geometries)
            assert_equal(0, rec_.geometry[0].num_interior_rings)
            assert_equal(5, rec_.geometry[0].exterior_ring.num_points)
            assert_equal(1, rec_.geometry[0].exterior_ring.point_n(0).x)
            assert_equal(1, rec_.geometry[0].exterior_ring.point_n(0).y)
            assert_equal(3.35, rec_.geometry[0].exterior_ring.point_n(0).z) if has_z_
            assert_equal(4.45, rec_.geometry[0].exterior_ring.point_n(0).m) if has_m_
            assert_equal(2, rec_.geometry[0].exterior_ring.point_n(1).x)
            assert_equal(1, rec_.geometry[0].exterior_ring.point_n(1).y)
            assert_equal(4.35, rec_.geometry[0].exterior_ring.point_n(1).z) if has_z_
            assert_equal(5.45, rec_.geometry[0].exterior_ring.point_n(1).m) if has_m_
            assert_equal(2, rec_.geometry[0].exterior_ring.point_n(2).x)
            assert_equal(2, rec_.geometry[0].exterior_ring.point_n(2).y)
            assert_equal(5.35, rec_.geometry[0].exterior_ring.point_n(2).z) if has_z_
            assert_equal(6.45, rec_.geometry[0].exterior_ring.point_n(2).m) if has_m_
            assert_equal(1, rec_.geometry[0].exterior_ring.point_n(4).x)
            assert_equal(1, rec_.geometry[0].exterior_ring.point_n(4).y)
            assert_equal(7.35, rec_.geometry[0].exterior_ring.point_n(4).z) if has_z_
            assert_equal(8.45, rec_.geometry[0].exterior_ring.point_n(4).m) if has_m_
            rec_ = file_.next
            assert_equal(::RGeo::Features::MultiPolygon, rec_.geometry.geometry_type)
            assert_equal(1, rec_.geometry.num_geometries)
            rec_ = file_.next
            assert_equal(::RGeo::Features::MultiPolygon, rec_.geometry.geometry_type)
            assert_equal(1, rec_.geometry.num_geometries)
            assert_equal(0, rec_.geometry[0].num_interior_rings)
            assert_equal(5, rec_.geometry[0].exterior_ring.num_points)
            assert_equal(1, rec_.geometry[0].exterior_ring.point_n(0).x)
            assert_equal(7, rec_.geometry[0].exterior_ring.point_n(0).y)
            assert_equal(23.35, rec_.geometry[0].exterior_ring.point_n(0).z) if has_z_
            assert_equal(24.45, rec_.geometry[0].exterior_ring.point_n(0).m) if has_m_
            assert_equal(2, rec_.geometry[0].exterior_ring.point_n(1).x)
            assert_equal(7, rec_.geometry[0].exterior_ring.point_n(1).y)
            assert_equal(24.35, rec_.geometry[0].exterior_ring.point_n(1).z) if has_z_
            assert_equal(25.45, rec_.geometry[0].exterior_ring.point_n(1).m) if has_m_
            assert_equal(2, rec_.geometry[0].exterior_ring.point_n(2).x)
            assert_equal(8, rec_.geometry[0].exterior_ring.point_n(2).y)
            assert_equal(25.35, rec_.geometry[0].exterior_ring.point_n(2).z) if has_z_
            assert_equal(26.45, rec_.geometry[0].exterior_ring.point_n(2).m) if has_m_
            assert_equal(1, rec_.geometry[0].exterior_ring.point_n(4).x)
            assert_equal(7, rec_.geometry[0].exterior_ring.point_n(4).y)
            assert_equal(27.35, rec_.geometry[0].exterior_ring.point_n(4).z) if has_z_
            assert_equal(28.45, rec_.geometry[0].exterior_ring.point_n(4).m) if has_m_
            rec_ = file_.next
            assert_equal(::RGeo::Features::MultiPolygon, rec_.geometry.geometry_type)
            assert_equal(1, rec_.geometry.num_geometries)
            assert_equal(2, rec_.geometry[0].num_interior_rings)
            assert_equal(5, rec_.geometry[0].exterior_ring.num_points)
            assert_equal(0, rec_.geometry[0].exterior_ring.point_n(0).x)
            assert_equal(0, rec_.geometry[0].exterior_ring.point_n(0).y)
            assert_equal(0, rec_.geometry[0].exterior_ring.point_n(0).z) if has_z_
            assert_equal(0, rec_.geometry[0].exterior_ring.point_n(0).m) if has_m_
            assert_equal(0, rec_.geometry[0].exterior_ring.point_n(1).x)
            assert_equal(100, rec_.geometry[0].exterior_ring.point_n(1).y)
            assert_equal(1, rec_.geometry[0].exterior_ring.point_n(1).z) if has_z_
            assert_equal(2, rec_.geometry[0].exterior_ring.point_n(1).m) if has_m_
            assert_equal(0, rec_.geometry[0].exterior_ring.point_n(4).x)
            assert_equal(0, rec_.geometry[0].exterior_ring.point_n(4).y)
            assert_equal(4, rec_.geometry[0].exterior_ring.point_n(4).z) if has_z_
            assert_equal(8, rec_.geometry[0].exterior_ring.point_n(4).m) if has_m_
            assert_equal(5, rec_.geometry[0].interior_ring_n(0).num_points)
            assert_equal(10, rec_.geometry[0].interior_ring_n(0).point_n(0).x)
            assert_equal(20, rec_.geometry[0].interior_ring_n(0).point_n(0).y)
            assert_equal(5, rec_.geometry[0].interior_ring_n(0).point_n(0).z) if has_z_
            assert_equal(10, rec_.geometry[0].interior_ring_n(0).point_n(0).m) if has_m_
            assert_equal(30, rec_.geometry[0].interior_ring_n(0).point_n(1).x)
            assert_equal(20, rec_.geometry[0].interior_ring_n(0).point_n(1).y)
            assert_equal(6, rec_.geometry[0].interior_ring_n(0).point_n(1).z) if has_z_
            assert_equal(12, rec_.geometry[0].interior_ring_n(0).point_n(1).m) if has_m_
            assert_equal(30, rec_.geometry[0].interior_ring_n(0).point_n(2).x)
            assert_equal(40, rec_.geometry[0].interior_ring_n(0).point_n(2).y)
            assert_equal(7, rec_.geometry[0].interior_ring_n(0).point_n(2).z) if has_z_
            assert_equal(14, rec_.geometry[0].interior_ring_n(0).point_n(2).m) if has_m_
            assert_equal(5, rec_.geometry[0].interior_ring_n(1).num_points)
            assert_equal(60, rec_.geometry[0].interior_ring_n(1).point_n(0).x)
            assert_equal(20, rec_.geometry[0].interior_ring_n(1).point_n(0).y)
            assert_equal(10, rec_.geometry[0].interior_ring_n(1).point_n(0).z) if has_z_
            assert_equal(20, rec_.geometry[0].interior_ring_n(1).point_n(0).m) if has_m_
            assert_equal(90, rec_.geometry[0].interior_ring_n(1).point_n(1).x)
            assert_equal(20, rec_.geometry[0].interior_ring_n(1).point_n(1).y)
            assert_equal(11, rec_.geometry[0].interior_ring_n(1).point_n(1).z) if has_z_
            assert_equal(22, rec_.geometry[0].interior_ring_n(1).point_n(1).m) if has_m_
            assert_equal(60, rec_.geometry[0].interior_ring_n(1).point_n(4).x)
            assert_equal(20, rec_.geometry[0].interior_ring_n(1).point_n(4).y)
            assert_equal(14, rec_.geometry[0].interior_ring_n(1).point_n(4).z) if has_z_
            assert_equal(28, rec_.geometry[0].interior_ring_n(1).point_n(4).m) if has_m_
          end
        end
        
        
        def test_test10
          _test_polygon_shapefile('test10', false, false)
        end
        
        
        def test_test11
          _test_polygon_shapefile('test11', true, true)
        end
        
        
        def test_test12
          _test_polygon_shapefile('test12', false, true)
        end
        
        
        def test_test13
          _open_shapefile('test13') do |file_|
            assert_equal(31, file_.shape_type_code)
            assert_equal(4, file_.num_records)
            assert_equal(true, file_.factory.has_capability?(:z_coordinate))
            # I believe shapefile's test13 incorrectly includes bounding
            # box data for m, since there is no actual m data. So I 
            # disabled this test:
            # assert_equal(false, file_.factory.has_capability?(:m_coordinate))
            rec_ = file_.next
            assert_equal(::RGeo::Features::GeometryCollection, rec_.geometry.geometry_type)
            assert_equal(1, rec_.geometry.num_geometries)
            assert_equal(0, rec_.geometry[0].num_interior_rings)
            assert_equal(5, rec_.geometry[0].exterior_ring.num_points)
            assert_equal(1, rec_.geometry[0].exterior_ring.point_n(0).x)
            assert_equal(1, rec_.geometry[0].exterior_ring.point_n(0).y)
            assert_equal(3.35, rec_.geometry[0].exterior_ring.point_n(0).z)
            assert_equal(2, rec_.geometry[0].exterior_ring.point_n(1).x)
            assert_equal(1, rec_.geometry[0].exterior_ring.point_n(1).y)
            assert_equal(4.35, rec_.geometry[0].exterior_ring.point_n(1).z)
            assert_equal(2, rec_.geometry[0].exterior_ring.point_n(2).x)
            assert_equal(2, rec_.geometry[0].exterior_ring.point_n(2).y)
            assert_equal(5.35, rec_.geometry[0].exterior_ring.point_n(2).z)
            assert_equal(1, rec_.geometry[0].exterior_ring.point_n(4).x)
            assert_equal(1, rec_.geometry[0].exterior_ring.point_n(4).y)
            assert_equal(7.35, rec_.geometry[0].exterior_ring.point_n(4).z)
            rec_ = file_.next
            assert_equal(::RGeo::Features::GeometryCollection, rec_.geometry.geometry_type)
            assert_equal(1, rec_.geometry.num_geometries)
            rec_ = file_.next
            assert_equal(::RGeo::Features::GeometryCollection, rec_.geometry.geometry_type)
            assert_equal(1, rec_.geometry.num_geometries)
            assert_equal(0, rec_.geometry[0].num_interior_rings)
            assert_equal(5, rec_.geometry[0].exterior_ring.num_points)
            assert_equal(1, rec_.geometry[0].exterior_ring.point_n(0).x)
            assert_equal(7, rec_.geometry[0].exterior_ring.point_n(0).y)
            assert_equal(23.35, rec_.geometry[0].exterior_ring.point_n(0).z)
            assert_equal(2, rec_.geometry[0].exterior_ring.point_n(1).x)
            assert_equal(7, rec_.geometry[0].exterior_ring.point_n(1).y)
            assert_equal(24.35, rec_.geometry[0].exterior_ring.point_n(1).z)
            assert_equal(2, rec_.geometry[0].exterior_ring.point_n(2).x)
            assert_equal(8, rec_.geometry[0].exterior_ring.point_n(2).y)
            assert_equal(25.35, rec_.geometry[0].exterior_ring.point_n(2).z)
            assert_equal(1, rec_.geometry[0].exterior_ring.point_n(4).x)
            assert_equal(7, rec_.geometry[0].exterior_ring.point_n(4).y)
            assert_equal(27.35, rec_.geometry[0].exterior_ring.point_n(4).z)
            rec_ = file_.next
            assert_equal(::RGeo::Features::GeometryCollection, rec_.geometry.geometry_type)
            assert_equal(1, rec_.geometry.num_geometries)
            assert_equal(2, rec_.geometry[0].num_interior_rings)
            assert_equal(5, rec_.geometry[0].exterior_ring.num_points)
            assert_equal(0, rec_.geometry[0].exterior_ring.point_n(0).x)
            assert_equal(0, rec_.geometry[0].exterior_ring.point_n(0).y)
            assert_equal(0, rec_.geometry[0].exterior_ring.point_n(0).z)
            assert_equal(0, rec_.geometry[0].exterior_ring.point_n(1).x)
            assert_equal(100, rec_.geometry[0].exterior_ring.point_n(1).y)
            assert_equal(1, rec_.geometry[0].exterior_ring.point_n(1).z)
            assert_equal(0, rec_.geometry[0].exterior_ring.point_n(4).x)
            assert_equal(0, rec_.geometry[0].exterior_ring.point_n(4).y)
            assert_equal(4, rec_.geometry[0].exterior_ring.point_n(4).z)
            assert_equal(5, rec_.geometry[0].interior_ring_n(0).num_points)
            assert_equal(10, rec_.geometry[0].interior_ring_n(0).point_n(0).x)
            assert_equal(20, rec_.geometry[0].interior_ring_n(0).point_n(0).y)
            assert_equal(5, rec_.geometry[0].interior_ring_n(0).point_n(0).z)
            assert_equal(30, rec_.geometry[0].interior_ring_n(0).point_n(1).x)
            assert_equal(20, rec_.geometry[0].interior_ring_n(0).point_n(1).y)
            assert_equal(6, rec_.geometry[0].interior_ring_n(0).point_n(1).z)
            assert_equal(30, rec_.geometry[0].interior_ring_n(0).point_n(2).x)
            assert_equal(40, rec_.geometry[0].interior_ring_n(0).point_n(2).y)
            assert_equal(7, rec_.geometry[0].interior_ring_n(0).point_n(2).z)
            assert_equal(5, rec_.geometry[0].interior_ring_n(1).num_points)
            assert_equal(60, rec_.geometry[0].interior_ring_n(1).point_n(0).x)
            assert_equal(20, rec_.geometry[0].interior_ring_n(1).point_n(0).y)
            assert_equal(10, rec_.geometry[0].interior_ring_n(1).point_n(0).z)
            assert_equal(90, rec_.geometry[0].interior_ring_n(1).point_n(1).x)
            assert_equal(20, rec_.geometry[0].interior_ring_n(1).point_n(1).y)
            assert_equal(11, rec_.geometry[0].interior_ring_n(1).point_n(1).z)
            assert_equal(60, rec_.geometry[0].interior_ring_n(1).point_n(4).x)
            assert_equal(20, rec_.geometry[0].interior_ring_n(1).point_n(4).y)
            assert_equal(14, rec_.geometry[0].interior_ring_n(1).point_n(4).z)
          end
        end
        
        
      end
      
    end
  end
end
