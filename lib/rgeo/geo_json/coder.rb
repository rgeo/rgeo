# -----------------------------------------------------------------------------
# 
# GeoJSON encoder object
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


module RGeo
  
  module GeoJSON
    
    
    # This object encapsulates encoding and decoding settings (principally
    # the RGeo::Feature::Factory and the RGeo::GeoJSON::EntityFactory to
    # be used) so that you can encode and decode without specifying those
    # settings every time.
    
    class Coder
      
      
      @@json_available = nil
      @@yajl_available = nil
      @@activesupport_available = nil
      
      
      # Create a new coder settings object. The geo factory is passed as
      # a required argument.
      # 
      # Options include:
      # 
      # <tt>:geo_factory</tt>::
      #   Specifies the geo factory to use to create geometry objects.
      #   Defaults to the preferred cartesian factory.
      # <tt>:entity_factory</tt>::
      #   Specifies an entity factory, which lets you override the types
      #   of GeoJSON entities that are created. It defaults to the default
      #   RGeo::GeoJSON::EntityFactory, which generates objects of type
      #   RGeo::GeoJSON::Feature or RGeo::GeoJSON::FeatureCollection.
      #   See RGeo::GeoJSON::EntityFactory for more information.
      # <tt>:json_parser</tt>::
      #   Specifies a JSON parser to use when decoding a String or IO
      #   object. The value may be a Proc object taking the string as the
      #   sole argument and returning the JSON hash, or it may be one of
      #   the special values <tt>:json</tt>, <tt>:yajl</tt>, or
      #   <tt>:active_support</tt>. Setting one of those special values
      #   will require the corresponding library to be available. Note
      #   that the <tt>:json</tt> library is present in the standard
      #   library in Ruby 1.9, but requires the "json" gem in Ruby 1.8.
      #   If a parser is not specified, then the decode method will not
      #   accept a String or IO object; it will require a Hash.
      
      def initialize(opts_={})
        @geo_factory = opts_[:geo_factory] || ::RGeo::Cartesian.preferred_factory
        @entity_factory = opts_[:entity_factory] || EntityFactory.instance
        @json_parser = opts_[:json_parser]
        case @json_parser
        when :json
          if @@json_available.nil?
            begin
              require 'json'
              @@json_available = true
            rescue ::LoadError
              @@json_available = false
            end
          end
          if @@json_available
            @json_parser = ::Proc.new{ |str_| ::JSON.parse(str_) }
          else
            raise Error::RGeoError, "JSON library is not available. You may need to install the 'json' gem."
          end
        when :yajl
          if @@yajl_available.nil?
            begin
              require 'yajl'
              @@yajl_available = true
            rescue ::LoadError
              @@yajl_available = false
            end
          end
          if @@yajl_available
            @json_parser = ::Proc.new{ |str_| ::Yajl::Parser.new.parse(str_) }
          else
            raise Error::RGeoError, "Yajl library is not available. You may need to install the 'yajl' gem."
          end
        when :active_support
          if @@activesupport_available.nil?
            begin
              require 'active_support/json'
              @@activesupport_available = true
            rescue ::LoadError
              @@activesupport_available = false
            end
          end
          if @@activesupport_available
            @json_parser = ::Proc.new{ |str_| ::ActiveSupport::JSON.decode(str_) }
          else
            raise Error::RGeoError, "ActiveSupport::JSON library is not available. You may need to install the 'activesupport' gem."
          end
        when ::Proc, nil
          # Leave as is
        else
          raise ::ArgumentError, "Unrecognzied json_parser: #{@json_parser.inspect}"
        end
        @num_coordinates = 2
        @num_coordinates += 1 if @geo_factory.property(:has_z_coordinate)
        @num_coordinates += 1 if @geo_factory.property(:has_m_coordinate)
      end
      
      
      # Encode the given object as GeoJSON. The object may be one of the
      # geometry objects specified in RGeo::Feature, or an appropriate
      # GeoJSON wrapper entity supported by this coder's entity factory.
      # 
      # This method returns a JSON object (i.e. a hash). In order to
      # generate a string suitable for transmitting to a service, you
      # will need to JSON-encode it. This is usually accomplished by
      # calling <tt>to_json</tt> on the hash object, if you have the
      # appropriate JSON library installed.
      
      def encode(object_)
        if @entity_factory.is_feature_collection?(object_)
          {
            'type' => 'FeatureCollection',
            'features' => @entity_factory.map_feature_collection(object_){ |f_| _encode_feature(f_) },
          }
        elsif @entity_factory.is_feature?(object_)
          _encode_feature(object_)
        else
          _encode_geometry(object_)
        end
      end
      
      
      # Decode an object from GeoJSON. The input may be a JSON hash, a
      # String, or an IO object from which to read the JSON string.
      # If an error occurs, nil is returned.
      
      def decode(input_)
        if input_.kind_of?(::IO)
          input_ = input_.read rescue nil
        end
        if input_.kind_of?(::String)
          input_ = @json_parser.call(input_) rescue nil
        end
        unless input_.kind_of?(::Hash)
          return nil
        end
        case input_['type']
        when 'FeatureCollection'
          features_ = input_['features']
          features_ = [] unless features_.kind_of?(::Array)
          decoded_features_ = []
          features_.each do |f_|
            if f_['type'] == 'Feature'
              decoded_features_ << _decode_feature(f_)
            end
          end
          @entity_factory.feature_collection(decoded_features_)
        when 'Feature'
          _decode_feature(input_)
        else
          _decode_geometry(input_)
        end
      end
      
      
      # Returns the RGeo::Feature::Factory used to generate geometry objects.
      
      def geo_factory
        @geo_factory
      end
      
      
      # Returns the RGeo::GeoJSON::EntityFactory used to generate GeoJSON
      # wrapper entities.
      
      def entity_factory
        @entity_factory
      end
      
      
      def _encode_feature(object_)  # :nodoc:
        json_ = {
          'type' => 'Feature',
          'geometry' => _encode_geometry(@entity_factory.get_feature_geometry(object_)),
          'properties' => @entity_factory.get_feature_properties(object_).dup,
        }
        id_ = @entity_factory.get_feature_id(object_)
        json_['id'] = id_ if id_
        json_
      end
      
      
      def _encode_geometry(object_, point_encoder_=nil)  # :nodoc:
        unless point_encoder_
          if object_.factory.property(:has_z_coordinate)
            if object_.factory.property(:has_m_coordinate)
              point_encoder_ = ::Proc.new{ |p_| [p_.x, p_.y, p_.z, p_.m] }
            else
              point_encoder_ = ::Proc.new{ |p_| [p_.x, p_.y, p_.z] }
            end
          else
            if object_.factory.property(:has_m_coordinate)
              point_encoder_ = ::Proc.new{ |p_| [p_.x, p_.y, p_.m] }
            else
              point_encoder_ = ::Proc.new{ |p_| [p_.x, p_.y] }
            end
          end
        end
        case object_
        when ::RGeo::Feature::Point
          {
            'type' => 'Point',
            'coordinates' => point_encoder_.call(object_),
          }
        when ::RGeo::Feature::LineString
          {
            'type' => 'LineString',
            'coordinates' => object_.points.map(&point_encoder_),
          }
        when ::RGeo::Feature::Polygon
          {
            'type' => 'Polygon',
            'coordinates' => [object_.exterior_ring.points.map(&point_encoder_)] + object_.interior_rings.map{ |r_| r_.points.map(&point_encoder_) }
          }
        when ::RGeo::Feature::MultiPoint
          {
            'type' => 'MultiPoint',
            'coordinates' => object_.map(&point_encoder_),
          }
        when ::RGeo::Feature::MultiLineString
          {
            'type' => 'MultiLineString',
            'coordinates' => object_.map{ |ls_| ls_.points.map(&point_encoder_) },
          }
        when ::RGeo::Feature::MultiPolygon
          {
            'type' => 'MultiPolygon',
            'coordinates' => object_.map{ |poly_| [poly_.exterior_ring.points.map(&point_encoder_)] + poly_.interior_rings.map{ |r_| r_.points.map(&point_encoder_) } },
          }
        when ::RGeo::Feature::GeometryCollection
          {
            'type' => 'GeometryCollection',
            'geometries' => object_.map{ |geom_| _encode_geometry(geom_, point_encoder_) },
          }
        else
          nil
        end
      end
      
      
      def _decode_feature(input_)  # :nodoc:
        geometry_ = input_['geometry']
        if geometry_
          geometry_ = _decode_geometry(geometry_)
          return nil unless geometry_
        end
        @entity_factory.feature(geometry_, input_['id'], input_['properties'])
      end
      
      
      def _decode_geometry(input_)  # :nodoc:
        case input_['type']
        when 'GeometryCollection'
          _decode_geometry_collection(input_)
        when 'Point'
          _decode_point_coords(input_['coordinates'])
        when 'LineString'
          _decode_line_string_coords(input_['coordinates'])
        when 'Polygon'
          _decode_polygon_coords(input_['coordinates'])
        when 'MultiPoint'
          _decode_multi_point_coords(input_['coordinates'])
        when 'MultiLineString'
          _decode_multi_line_string_coords(input_['coordinates'])
        when 'MultiPolygon'
          _decode_multi_polygon_coords(input_['coordinates'])
        else
          nil
        end
      end
      
      
      def _decode_geometry_collection(input_)  # :nodoc:
        geometries_ = input_['geometries']
        geometries_ = [] unless geometries_.kind_of?(::Array)
        decoded_geometries_ = []
        geometries_.each do |g_|
          g_ = _decode_geometry(g_)
          decoded_geometries_ << g_ if g_
        end
        @geo_factory.collection(decoded_geometries_)
      end
      
      
      def _decode_point_coords(point_coords_)  # :nodoc:
        return nil unless point_coords_.kind_of?(::Array)
        @geo_factory.point(*(point_coords_[0...@num_coordinates].map{ |c_| c_.to_f })) rescue nil
      end
      
      
      def _decode_line_string_coords(line_coords_)  # :nodoc:
        return nil unless line_coords_.kind_of?(::Array)
        points_ = []
        line_coords_.each do |point_coords_|
          point_ = _decode_point_coords(point_coords_)
          points_ << point_ if point_
        end
        @geo_factory.line_string(points_)
      end
      
      
      def _decode_polygon_coords(poly_coords_)  # :nodoc:
        return nil unless poly_coords_.kind_of?(::Array)
        rings_ = []
        poly_coords_.each do |ring_coords_|
          return nil unless ring_coords_.kind_of?(::Array)
          points_ = []
          ring_coords_.each do |point_coords_|
            point_ = _decode_point_coords(point_coords_)
            points_ << point_ if point_
          end
          ring_ = @geo_factory.linear_ring(points_)
          rings_ << ring_ if ring_
        end
        if rings_.size == 0
          nil
        else
          @geo_factory.polygon(rings_[0], rings_[1..-1])
        end
      end
      
      
      def _decode_multi_point_coords(multi_point_coords_)  # :nodoc:
        return nil unless multi_point_coords_.kind_of?(::Array)
        points_ = []
        multi_point_coords_.each do |point_coords_|
          point_ = _decode_point_coords(point_coords_)
          points_ << point_ if point_
        end
        @geo_factory.multi_point(points_)
      end
      
      
      def _decode_multi_line_string_coords(multi_line_coords_)  # :nodoc:
        return nil unless multi_line_coords_.kind_of?(::Array)
        lines_ = []
        multi_line_coords_.each do |line_coords_|
          line_ = _decode_line_string_coords(line_coords_)
          lines_ << line_ if line_
        end
        @geo_factory.multi_line_string(lines_)
      end
      
      
      def _decode_multi_polygon_coords(multi_polygon_coords_)  # :nodoc:
        return nil unless multi_polygon_coords_.kind_of?(::Array)
        polygons_ = []
        multi_polygon_coords_.each do |poly_coords_|
          poly_ = _decode_polygon_coords(poly_coords_)
          polygons_ << poly_ if poly_
        end
        @geo_factory.multi_polygon(polygons_)
      end
      
      
    end
    
    
  end
  
end
