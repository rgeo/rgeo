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
          end
        end
        
        
        def test_test1
          _open_shapefile('test1') do |file_|
            assert_equal(1, file_.shape_type_code)
            assert_equal(2, file_.num_records)
            assert_equal(false, file_.factory.has_capability?(:z_coordinate))
            assert_equal(false, file_.factory.has_capability?(:m_coordinate))
            rec_ = file_.next
            assert_equal(0, rec_.index)
            assert_equal(::RGeo::Features::Point, rec_.geometry.geometry_type)
            assert_equal(1, rec_.geometry.x)
            assert_equal(2, rec_.geometry.y)
            rec_ = file_.next
            assert_equal(1, rec_.index)
            assert_equal(::RGeo::Features::Point, rec_.geometry.geometry_type)
            assert_equal(10, rec_.geometry.x)
            assert_equal(20, rec_.geometry.y)
          end
        end
        
        
        def test_test2
          _open_shapefile('test2') do |file_|
            assert_equal(11, file_.shape_type_code)
            assert_equal(2, file_.num_records)
            assert_equal(true, file_.factory.has_capability?(:z_coordinate))
            assert_equal(true, file_.factory.has_capability?(:m_coordinate))
            rec_ = file_.next
            assert_equal(0, rec_.index)
            assert_equal(::RGeo::Features::Point, rec_.geometry.geometry_type)
            assert_equal(1, rec_.geometry.x)
            assert_equal(2, rec_.geometry.y)
            assert_equal(3, rec_.geometry.z)
            assert_equal(4, rec_.geometry.m)
            rec_ = file_.next
            assert_equal(1, rec_.index)
            assert_equal(::RGeo::Features::Point, rec_.geometry.geometry_type)
            assert_equal(10, rec_.geometry.x)
            assert_equal(20, rec_.geometry.y)
            assert_equal(30, rec_.geometry.z)
            assert_equal(40, rec_.geometry.m)
          end
        end
        
        
        def test_test3
          _open_shapefile('test3') do |file_|
            assert_equal(21, file_.shape_type_code)
            assert_equal(2, file_.num_records)
            assert_equal(false, file_.factory.has_capability?(:z_coordinate))
            assert_equal(true, file_.factory.has_capability?(:m_coordinate))
            rec_ = file_.next
            assert_equal(0, rec_.index)
            assert_equal(::RGeo::Features::Point, rec_.geometry.geometry_type)
            assert_equal(1, rec_.geometry.x)
            assert_equal(2, rec_.geometry.y)
            assert_equal(4, rec_.geometry.m)
            rec_ = file_.next
            assert_equal(1, rec_.index)
            assert_equal(::RGeo::Features::Point, rec_.geometry.geometry_type)
            assert_equal(10, rec_.geometry.x)
            assert_equal(20, rec_.geometry.y)
            assert_equal(40, rec_.geometry.m)
          end
        end
        
        
      end
      
    end
  end
end
