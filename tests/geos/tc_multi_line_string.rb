# -----------------------------------------------------------------------------
# 
# Tests for the GEOS multi line string implementation
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
    module Geos
      
      class TestMultiLineString < ::Test::Unit::TestCase  # :nodoc:
        
        
        def setup
          @factory = ::RGeo::Geos.factory
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(1, 0)
          point3_ = @factory.point(-4, 2)
          point4_ = @factory.point(-5, 3)
          point5_ = @factory.point(-3, 5)
          @linestring1 = @factory.line_string([point1_, point2_])
          @linestring2 = @factory.line_string([point3_, point4_, point5_])
          @linearring1 = @factory.linear_ring([point5_, point3_, point4_, point5_])
          @line1 = @factory.line(point1_, point2_)
        end
        
        
        def test_creation_simple
          geom_ = @factory.multi_line_string([@linestring1, @linestring2])
          assert_not_nil(geom_)
          assert_kind_of(::RGeo::Geos::MultiLineStringImpl, geom_)
          assert(::RGeo::Features::MultiLineString === geom_)
          assert_equal(::RGeo::Features::MultiLineString, geom_.geometry_type)
          assert_equal(2, geom_.num_geometries)
          assert_equal([@linestring1, @linestring2], geom_.to_a)
        end
        
        
        def test_creation_empty
          geom_ = @factory.multi_line_string([])
          assert_not_nil(geom_)
          assert_kind_of(::RGeo::Geos::MultiLineStringImpl, geom_)
          assert(::RGeo::Features::MultiLineString === geom_)
          assert_equal(::RGeo::Features::MultiLineString, geom_.geometry_type)
          assert_equal(0, geom_.num_geometries)
          assert_equal([], geom_.to_a)
        end
        
        
        def test_creation_save_types
          geom_ = @factory.multi_line_string([@linestring1, @linearring1, @line1])
          assert_not_nil(geom_)
          assert_kind_of(::RGeo::Geos::MultiLineStringImpl, geom_)
          assert(::RGeo::Features::MultiLineString === geom_)
          assert_equal(::RGeo::Features::MultiLineString, geom_.geometry_type)
          assert_equal(3, geom_.num_geometries)
          assert(geom_[1].eql?(@linearring1))
          assert(geom_[2].eql?(@line1))
        end
        
        
        def test_creation_compound
          mls1_ = @factory.multi_line_string([@linestring1, @linestring2])
          mls2_ = @factory.collection([@line1])
          mls3_ = @factory.collection([mls1_])
          geom_ = @factory.multi_line_string([mls3_, mls2_, @linearring1])
          assert_not_nil(geom_)
          assert_kind_of(::RGeo::Geos::MultiLineStringImpl, geom_)
          assert(::RGeo::Features::MultiLineString === geom_)
          assert_equal(::RGeo::Features::MultiLineString, geom_.geometry_type)
          assert_equal(4, geom_.num_geometries)
          assert(geom_.to_a.eql?([@linestring1, @linestring2, @line1, @linearring1]))
        end
        
        
        def test_fully_equal
          geom1_ = @factory.multi_line_string([@linestring1, @linestring2])
          geom2_ = @factory.multi_line_string([@linestring1, @linestring2])
          assert(geom1_.eql?(geom2_))
          assert(geom1_.equals?(geom2_))
        end
        
        
        def test_geometrically_equal
          geom1_ = @factory.multi_line_string([@linestring1, @linestring2, @linearring1])
          geom2_ = @factory.multi_line_string([@line1, @linearring1])
          assert(!geom1_.eql?(geom2_))
          assert(geom1_.equals?(geom2_))
        end
        
        
        def test_not_equal
          geom1_ = @factory.multi_line_string([@linestring2])
          geom2_ = @factory.multi_line_string([@linearring1])
          assert(!geom1_.eql?(geom2_))
          assert(!geom1_.equals?(geom2_))
        end
        
        
        def test_wkt_creation_simple
          parsed_geom_ = @factory.parse_wkt('MULTILINESTRING((0 0, 1 0), (-4 2, -5 3, -3 5))')
          built_geom_ = @factory.multi_line_string([@linestring1, @linestring2])
          assert_equal(built_geom_, parsed_geom_)
        end
        
        
        def test_wkt_creation_empty
          parsed_geom_ = @factory.parse_wkt('MULTILINESTRING EMPTY')
          assert_equal(::RGeo::Features::MultiLineString, parsed_geom_.geometry_type)
          assert_equal(0, parsed_geom_.num_geometries)
          assert_equal([], parsed_geom_.to_a)
        end
        
        
        def test_clone
          geom1_ = @factory.multi_line_string([@linestring1, @linestring2])
          geom2_ = geom1_.clone
          assert_equal(geom1_, geom2_)
          assert_equal(::RGeo::Features::MultiLineString, geom2_.geometry_type)
          assert_equal(2, geom2_.num_geometries)
          assert_equal([@linestring1, @linestring2], geom2_.to_a)
        end
        
        
        def test_type_check
          geom1_ = @factory.multi_line_string([@linestring1, @linestring2])
          assert(::RGeo::Features::Geometry.check_type(geom1_))
          assert(!::RGeo::Features::LineString.check_type(geom1_))
          assert(::RGeo::Features::GeometryCollection.check_type(geom1_))
          assert(!::RGeo::Features::MultiPoint.check_type(geom1_))
          assert(::RGeo::Features::MultiLineString.check_type(geom1_))
          geom2_ = @factory.multi_line_string([])
          assert(::RGeo::Features::Geometry.check_type(geom2_))
          assert(!::RGeo::Features::LineString.check_type(geom2_))
          assert(::RGeo::Features::GeometryCollection.check_type(geom2_))
          assert(!::RGeo::Features::MultiPoint.check_type(geom2_))
          assert(::RGeo::Features::MultiLineString.check_type(geom2_))
        end
        
        
        def test_as_text_wkt_round_trip
          geom1_ = @factory.multi_line_string([@linestring1, @linestring2])
          text_ = geom1_.as_text
          geom2_ = @factory.parse_wkt(text_)
          assert_equal(geom1_, geom2_)
        end
        
        
        def test_as_binary_wkb_round_trip
          geom1_ = @factory.multi_line_string([@linestring1, @linestring2])
          binary_ = geom1_.as_binary
          geom2_ = @factory.parse_wkb(binary_)
          assert_equal(geom1_, geom2_)
        end
        
        
        def test_dimension
          geom1_ = @factory.multi_line_string([@linestring1, @linestring2])
          assert_equal(1, geom1_.dimension)
          geom2_ = @factory.multi_line_string([])
          assert_equal(-1, geom2_.dimension)
        end
        
        
        def test_is_empty
          geom1_ = @factory.multi_line_string([@linestring1, @linestring2])
          assert(!geom1_.is_empty?)
          geom2_ = @factory.multi_line_string([])
          assert(geom2_.is_empty?)
        end
        
        
      end
      
    end
  end
end
