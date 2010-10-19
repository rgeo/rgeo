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
      # in RGeo::Features, or an appropriate GeoJSON wrapper entity such
      # as RGeo::GeoJSON::Feature or RGeo::GeoJSON::FeatureCollection.
      # 
      # The only option supported is <tt>:entity_factory</tt>, which lets
      # you override the types of GeoJSON entities supported. See
      # RGeo::GeoJSON::EntityFactory for more information. By default,
      # encode supports objects of type RGeo::GeoJSON::Feature and
      # RGeo::GeoJSON::FeatureCollection.
      
      def encode(object_, opts_={})
        Coder.new(nil, opts_).encode(object_)
      end
      
      
      # High-level convenience routine for decoding an object from GeoJSON.
      # The input may be a JSON hash, a String, or an IO object from which
      # to read the JSON string. You must also provide the
      # RGeo::Features::Factory to use to create geometric objects.
      # 
      # The only option supported is <tt>:entity_factory</tt>, which lets
      # you override the types of GeoJSON entities that can be created.
      # See RGeo::GeoJSON::EntityFactory for more information. By default,
      # decode generates objects of type RGeo::GeoJSON::Feature and
      # RGeo::GeoJSON::FeatureCollection.
      
      def decode(input_, geo_factory_, opts_={})
        Coder.new(geo_factory_, opts_).decode(input_)
      end
      
      
      # Creates and returns a coder object of type RGeo::GeoJSON::Coder
      # that encapsulates encoding and decoding settings (principally the
      # RGeo::Features::Factory and the RGeo::GeoJSON::EntityFactory to be
      # used).
      # The geo factory is a required argument. The entity factory is
      # optional. To provide one, pass an option with key
      # <tt>:entity_factory</tt>. It defaults to the default
      # RGeo::GeoJSON::EntityFactory, which generates objects of type
      # RGeo::GeoJSON::Feature or RGeo::GeoJSON::FeatureCollection.
      
      def coder(geo_factory_, opts_={})
        Coder.new(geo_factory_, opts_)
      end
      
      
    end
    
  end
  
end
