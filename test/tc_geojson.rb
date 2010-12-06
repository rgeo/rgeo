# -----------------------------------------------------------------------------
# 
# Tests for basic GeoJSON usage
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
    
    class TestGeoJSON < ::Test::Unit::TestCase  # :nodoc:
      
      
      def setup
        @geo_factory = ::RGeo::Cartesian.simple_factory(:srid => 4326)
        @geo_factory_z = ::RGeo::Cartesian.simple_factory(:srid => 4326, :has_z_coordinate => true)
        @geo_factory_m = ::RGeo::Cartesian.simple_factory(:srid => 4326, :has_m_coordinate => true)
        @geo_factory_zm = ::RGeo::Cartesian.simple_factory(:srid => 4326, :has_z_coordinate => true, :has_m_coordinate => true)
        @entity_factory = ::RGeo::GeoJSON::EntityFactory.instance
      end
      
      
      def test_point
        object_ = @geo_factory.point(10, 20)
        json_ = {
          'type' => 'Point',
          'coordinates' => [10.0, 20.0],
        }
        assert_equal(json_, ::RGeo::GeoJSON.encode(object_))
        assert(::RGeo::GeoJSON.decode(json_, :geo_factory => @geo_factory).eql?(object_))
      end
      
      
      def test_point_z
        object_ = @geo_factory_z.point(10, 20, -1)
        json_ = {
          'type' => 'Point',
          'coordinates' => [10.0, 20.0, -1.0],
        }
        assert_equal(json_, ::RGeo::GeoJSON.encode(object_))
        assert(::RGeo::GeoJSON.decode(json_, :geo_factory => @geo_factory_z).eql?(object_))
      end
      
      
      def test_point_m
        object_ = @geo_factory_m.point(10, 20, -1)
        json_ = {
          'type' => 'Point',
          'coordinates' => [10.0, 20.0, -1.0],
        }
        assert_equal(json_, ::RGeo::GeoJSON.encode(object_))
        assert(::RGeo::GeoJSON.decode(json_, :geo_factory => @geo_factory_m).eql?(object_))
      end
      
      
      def test_point_zm
        object_ = @geo_factory_zm.point(10, 20, -1, -2)
        json_ = {
          'type' => 'Point',
          'coordinates' => [10.0, 20.0, -1.0, -2.0],
        }
        assert_equal(json_, ::RGeo::GeoJSON.encode(object_))
        assert(::RGeo::GeoJSON.decode(json_, :geo_factory => @geo_factory_zm).eql?(object_))
      end
      
      
      def test_line_string
        object_ = @geo_factory.line_string([@geo_factory.point(10, 20), @geo_factory.point(12, 22), @geo_factory.point(-3, 24)])
        json_ = {
          'type' => 'LineString',
          'coordinates' => [[10.0, 20.0], [12.0, 22.0], [-3.0, 24.0]],
        }
        assert_equal(json_, ::RGeo::GeoJSON.encode(object_))
        assert(::RGeo::GeoJSON.decode(json_, :geo_factory => @geo_factory).eql?(object_))
      end
      
      
      def test_polygon
        object_ = @geo_factory.polygon(@geo_factory.linear_ring([@geo_factory.point(10, 20), @geo_factory.point(12, 22), @geo_factory.point(-3, 24), @geo_factory.point(10, 20)]))
        json_ = {
          'type' => 'Polygon',
          'coordinates' => [[[10.0, 20.0], [12.0, 22.0], [-3.0, 24.0], [10.0, 20.0]]],
        }
        assert_equal(json_, ::RGeo::GeoJSON.encode(object_))
        assert(::RGeo::GeoJSON.decode(json_, :geo_factory => @geo_factory).eql?(object_))
      end
      
      
      def test_polygon_complex
        object_ = @geo_factory.polygon(@geo_factory.linear_ring([@geo_factory.point(0, 0), @geo_factory.point(10, 0), @geo_factory.point(10, 10), @geo_factory.point(0, 10), @geo_factory.point(0, 0)]), [@geo_factory.linear_ring([@geo_factory.point(4, 4), @geo_factory.point(6, 5), @geo_factory.point(4, 6), @geo_factory.point(4, 4)])])
        json_ = {
          'type' => 'Polygon',
          'coordinates' => [[[0.0, 0.0], [10.0, 0.0], [10.0, 10.0], [0.0, 10.0], [0.0, 0.0]], [[4.0, 4.0], [6.0, 5.0], [4.0, 6.0], [4.0, 4.0]]],
        }
        assert_equal(json_, ::RGeo::GeoJSON.encode(object_))
        assert(::RGeo::GeoJSON.decode(json_, :geo_factory => @geo_factory).eql?(object_))
      end
      
      
      def test_multi_point
        object_ = @geo_factory.multi_point([@geo_factory.point(10, 20), @geo_factory.point(12, 22), @geo_factory.point(-3, 24)])
        json_ = {
          'type' => 'MultiPoint',
          'coordinates' => [[10.0, 20.0], [12.0, 22.0], [-3.0, 24.0]],
        }
        assert_equal(json_, ::RGeo::GeoJSON.encode(object_))
        assert(::RGeo::GeoJSON.decode(json_, :geo_factory => @geo_factory).eql?(object_))
      end
      
      
      def test_multi_line_string
        object_ = @geo_factory.multi_line_string([@geo_factory.line_string([@geo_factory.point(10, 20), @geo_factory.point(12, 22), @geo_factory.point(-3, 24)]), @geo_factory.line_string([@geo_factory.point(1, 2), @geo_factory.point(3, 4)])])
        json_ = {
          'type' => 'MultiLineString',
          'coordinates' => [[[10.0, 20.0], [12.0, 22.0], [-3.0, 24.0]], [[1.0, 2.0], [3.0, 4.0]]],
        }
        assert_equal(json_, ::RGeo::GeoJSON.encode(object_))
        assert(::RGeo::GeoJSON.decode(json_, :geo_factory => @geo_factory).eql?(object_))
      end
      
      
      def test_multi_polygon
        object_ = @geo_factory.multi_polygon([@geo_factory.polygon(@geo_factory.linear_ring([@geo_factory.point(0, 0), @geo_factory.point(10, 0), @geo_factory.point(10, 10), @geo_factory.point(0, 10), @geo_factory.point(0, 0)]), [@geo_factory.linear_ring([@geo_factory.point(4, 4), @geo_factory.point(6, 5), @geo_factory.point(4, 6), @geo_factory.point(4, 4)])]), @geo_factory.polygon(@geo_factory.linear_ring([@geo_factory.point(-10,-10), @geo_factory.point(-15, -10), @geo_factory.point(-10, -15), @geo_factory.point(-10, -10)]))])
        json_ = {
          'type' => 'MultiPolygon',
          'coordinates' => [[[[0.0, 0.0], [10.0, 0.0], [10.0, 10.0], [0.0, 10.0], [0.0, 0.0]], [[4.0, 4.0], [6.0, 5.0], [4.0, 6.0], [4.0, 4.0]]], [[[-10.0, -10.0], [-15.0, -10.0], [-10.0, -15.0], [-10.0, -10.0]]]]
        }
        assert_equal(json_, ::RGeo::GeoJSON.encode(object_))
        assert(::RGeo::GeoJSON.decode(json_, :geo_factory => @geo_factory).eql?(object_))
      end
      
      
      def test_geometry_collection
        object_ = @geo_factory.collection([@geo_factory.point(10, 20), @geo_factory.collection([@geo_factory.point(12, 22), @geo_factory.point(-3, 24)])])
        json_ = {
          'type' => 'GeometryCollection',
          'geometries' => [
            {
              'type' => 'Point',
              'coordinates' => [10.0, 20.0],
            },
            {
              'type' => 'GeometryCollection',
              'geometries' => [
                {
                  'type' => 'Point',
                  'coordinates' => [12.0, 22.0],
                },
                {
                  'type' => 'Point',
                  'coordinates' => [-3.0, 24.0],
                },
              ],
            },
          ],
        }
        assert_equal(json_, ::RGeo::GeoJSON.encode(object_))
        assert(::RGeo::GeoJSON.decode(json_, :geo_factory => @geo_factory).eql?(object_))
      end
      
      
      def test_feature
        object_ = @entity_factory.feature(@geo_factory.point(10, 20))
        json_ = {
          'type' => 'Feature',
          'geometry' => {
            'type' => 'Point',
            'coordinates' => [10.0, 20.0],
          },
          'properties' => {},
        }
        assert_equal(json_, ::RGeo::GeoJSON.encode(object_))
        assert(::RGeo::GeoJSON.decode(json_, :geo_factory => @geo_factory).eql?(object_))
      end
      
      
      def test_feature_nulls
        json_ = {
          'type' => 'Feature',
          'geometry' => nil,
          'properties' => nil,
        }
        obj_ = ::RGeo::GeoJSON.decode(json_, :geo_factory => @geo_factory)
        assert_not_nil(obj_)
        assert_nil(obj_.geometry)
        assert_equal({}, obj_.properties)
      end
      
      
      def test_feature_complex
        object_ = @entity_factory.feature(@geo_factory.point(10, 20), 2, {'prop1' => 'foo', 'prop2' => 'bar'})
        json_ = {
          'type' => 'Feature',
          'geometry' => {
            'type' => 'Point',
            'coordinates' => [10.0, 20.0],
          },
          'id' => 2,
          'properties' => {'prop1' => 'foo', 'prop2' => 'bar'},
        }
        assert_equal(json_, ::RGeo::GeoJSON.encode(object_))
        assert(::RGeo::GeoJSON.decode(json_, :geo_factory => @geo_factory).eql?(object_))
      end
      
      
      def test_feature_collection
        object_ = @entity_factory.feature_collection([@entity_factory.feature(@geo_factory.point(10, 20)), @entity_factory.feature(@geo_factory.point(11, 22)), @entity_factory.feature(@geo_factory.point(10, 20), 8)])
        json_ = {
          'type' => 'FeatureCollection',
          'features' => [
            {
              'type' => 'Feature',
              'geometry' => {
                'type' => 'Point',
                'coordinates' => [10.0, 20.0],
              },
              'properties' => {},
            },
            {
              'type' => 'Feature',
              'geometry' => {
                'type' => 'Point',
                'coordinates' => [11.0, 22.0],
              },
              'properties' => {},
            },
            {
              'type' => 'Feature',
              'geometry' => {
                'type' => 'Point',
                'coordinates' => [10.0, 20.0],
              },
              'id' => 8,
              'properties' => {},
            },
          ]
        }
        assert_equal(json_, ::RGeo::GeoJSON.encode(object_))
        assert(::RGeo::GeoJSON.decode(json_, :geo_factory => @geo_factory).eql?(object_))
      end
      
      
    end
    
  end
end
