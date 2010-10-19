# -----------------------------------------------------------------------------
# 
# Tests for the GEOS geometry collection implementation
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
      
      class TestGeometryCollection < ::Test::Unit::TestCase  # :nodoc:
        
        
        def setup
          @factory = ::RGeo::Geos.factory
          @point1 = @factory.point(0, 0)
          @point2 = @factory.point(1, 0)
          @point3 = @factory.point(-4, 2)
          @point4 = @factory.point(-5, 3)
          @line1 = @factory.line_string([@point3, @point4])
          @line2 = @factory.line_string([@point3, @point4, @point1])
          @line3 = @factory.line(@point3, @point4)
        end
        
        
        def test_creation_simple
          geom_ = @factory.collection([@point1, @line1])
          assert_not_nil(geom_)
          assert_kind_of(::RGeo::Geos::GeometryCollectionImpl, geom_)
          assert(::RGeo::Features::GeometryCollection === geom_)
          assert_equal(::RGeo::Features::GeometryCollection, geom_.geometry_type)
          assert_equal(2, geom_.num_geometries)
          assert_equal([@point1, @line1], geom_.to_a)
        end
        
        
        def test_creation_empty
          geom_ = @factory.collection([])
          assert_not_nil(geom_)
          assert_kind_of(::RGeo::Geos::GeometryCollectionImpl, geom_)
          assert(::RGeo::Features::GeometryCollection === geom_)
          assert_equal(::RGeo::Features::GeometryCollection, geom_.geometry_type)
          assert_equal(0, geom_.num_geometries)
          assert_equal([], geom_.to_a)
        end
        
        
        def test_creation_save_klass
          geom_ = @factory.collection([@point1, @line3])
          assert_not_nil(geom_)
          assert_kind_of(::RGeo::Geos::GeometryCollectionImpl, geom_)
          assert(::RGeo::Features::GeometryCollection === geom_)
          assert_equal(::RGeo::Features::GeometryCollection, geom_.geometry_type)
          assert_equal(2, geom_.num_geometries)
          assert(geom_[1].eql?(@line3))
        end
        
        
        def test_creation_compound
          geom1_ = @factory.collection([@point1, @line1])
          geom2_ = @factory.collection([@point2, geom1_])
          assert_not_nil(geom2_)
          assert_kind_of(::RGeo::Geos::GeometryCollectionImpl, geom2_)
          assert(::RGeo::Features::GeometryCollection === geom2_)
          assert_equal(::RGeo::Features::GeometryCollection, geom2_.geometry_type)
          assert_equal(2, geom2_.num_geometries)
          assert(geom2_[1].eql?(geom1_))
        end
        
        
        def test_creation_compound_save_klass
          geom1_ = @factory.collection([@point1, @line3])
          geom2_ = @factory.collection([@point2, geom1_])
          ::GC.start
          assert_not_nil(geom2_)
          assert_kind_of(::RGeo::Geos::GeometryCollectionImpl, geom2_)
          assert(::RGeo::Features::GeometryCollection === geom2_)
          assert_equal(::RGeo::Features::GeometryCollection, geom2_.geometry_type)
          assert_equal(2, geom2_.num_geometries)
          assert(::RGeo::Features::Line === geom2_[1][1])
        end
        
        
        def test_fully_equal
          geom1_ = @factory.collection([@point1, @line1])
          geom2_ = @factory.collection([@point1, @line1])
          assert(geom1_.eql?(geom2_))
          assert(geom1_.equals?(geom2_))
        end
        
        
        def test_geometrically_equal
          geom1_ = @factory.collection([@point2, @line2])
          geom2_ = @factory.collection([@point2, @line1, @line2])
          assert(!geom1_.eql?(geom2_))
          assert(geom1_.equals?(geom2_))
        end
        
        
        def test_empty_equal
          geom1_ = @factory.collection([])
          geom2_ = @factory.collection([])
          assert(geom1_.eql?(geom2_))
          assert(geom1_.equals?(geom2_))
        end
        
        
        def test_not_equal
          geom1_ = @factory.collection([@point1, @line1])
          geom2_ = @factory.collection([@point2, @line1])
          assert(!geom1_.eql?(geom2_))
          assert(!geom1_.equals?(geom2_))
        end
        
        
        def test_wkt_creation_simple
          parsed_geom_ = @factory.parse_wkt('GEOMETRYCOLLECTION(POINT(0 0), LINESTRING(-4 2, -5 3))')
          built_geom_ = @factory.collection([@point1, @line1])
          assert_equal(built_geom_, parsed_geom_)
        end
        
        
        def test_wkt_creation_empty
          parsed_geom_ = @factory.parse_wkt('GEOMETRYCOLLECTION EMPTY')
          assert_equal(0, parsed_geom_.num_geometries)
          assert_equal([], parsed_geom_.to_a)
        end
        
        
        def test_clone
          geom1_ = @factory.collection([@point1, @line1])
          geom2_ = geom1_.clone
          assert_equal(geom1_, geom2_)
          assert_equal(::RGeo::Features::GeometryCollection, geom2_.geometry_type)
          assert_equal(2, geom2_.num_geometries)
          assert_equal([@point1, @line1], geom2_.to_a)
        end
        
        
        def test_type_check
          geom1_ = @factory.collection([@point1, @line1])
          assert(::RGeo::Features::Geometry.check_type(geom1_))
          assert(!::RGeo::Features::Point.check_type(geom1_))
          assert(::RGeo::Features::GeometryCollection.check_type(geom1_))
          assert(!::RGeo::Features::MultiPoint.check_type(geom1_))
          geom2_ = @factory.collection([@point1, @point2])
          assert(::RGeo::Features::Geometry.check_type(geom2_))
          assert(!::RGeo::Features::Point.check_type(geom2_))
          assert(::RGeo::Features::GeometryCollection.check_type(geom2_))
          assert(!::RGeo::Features::MultiPoint.check_type(geom2_))
        end
        
        
        def test_as_text_wkt_round_trip
          geom1_ = @factory.collection([@point1, @line1])
          text_ = geom1_.as_text
          geom2_ = @factory.parse_wkt(text_)
          assert_equal(geom1_, geom2_)
        end
        
        
        def test_as_binary_wkb_round_trip
          geom1_ = @factory.collection([@point1, @line1])
          binary_ = geom1_.as_binary
          geom2_ = @factory.parse_wkb(binary_)
          assert_equal(geom1_, geom2_)
        end
        
        
        def test_dimension
          geom1_ = @factory.collection([@point1, @line1])
          assert_equal(1, geom1_.dimension)
          geom2_ = @factory.collection([@point1, @point2])
          assert_equal(0, geom2_.dimension)
          geom3_ = @factory.collection([])
          assert_equal(-1, geom3_.dimension)
        end
        
        
        def test_is_empty
          geom1_ = @factory.collection([@point1, @line1])
          assert(!geom1_.is_empty?)
          geom2_ = @factory.collection([])
          assert(geom2_.is_empty?)
        end
        
        
      end
      
    end
  end
end
