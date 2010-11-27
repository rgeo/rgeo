# -----------------------------------------------------------------------------
# 
# GeoJSON toplevel interface
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
    
    class << self
      
      
      # High-level convenience routine for encoding an object as GeoJSON.
      # Pass the object, which may one of the geometry objects specified
      # in RGeo::Feature, or an appropriate GeoJSON wrapper entity such
      # as RGeo::GeoJSON::Feature or RGeo::GeoJSON::FeatureCollection.
      # 
      # The only option supported is <tt>:entity_factory</tt>, which lets
      # you override the types of GeoJSON entities supported. See
      # RGeo::GeoJSON::EntityFactory for more information. By default,
      # encode supports objects of type RGeo::GeoJSON::Feature and
      # RGeo::GeoJSON::FeatureCollection.
      
      def encode(object_, opts_={})
        Coder.new(opts_).encode(object_)
      end
      
      
      # High-level convenience routine for decoding an object from GeoJSON.
      # The input may be a JSON hash, a String, or an IO object from which
      # to read the JSON string.
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
      
      def decode(input_, opts_={})
        Coder.new(opts_).decode(input_)
      end
      
      
      # Creates and returns a coder object of type RGeo::GeoJSON::Coder
      # that encapsulates encoding and decoding settings (principally the
      # RGeo::Feature::Factory and the RGeo::GeoJSON::EntityFactory to be
      # used).
      # 
      # The geo factory is a required argument. Other options include:
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
      
      def coder(opts_={})
        Coder.new(opts_)
      end
      
      
    end
    
  end
  
end
