# -----------------------------------------------------------------------------
# 
# Common tools for spatial adapters for ActiveRecord
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


require 'rgeo/feature'
require 'rgeo/cartesian'
require 'rgeo/geography'


module RGeo
  
  
  # RGeo provides ActiveRecord connection adapters for common spatial
  # databases. They cause ActiveRecord to make spatial database fields
  # available as RGeo feature objects instead of internally-coded data.
  # They also provide extensions to the schema management APIs for
  # creating spatial columns and spatial indexes.
  # 
  # You can specify and use these connection adapters in the same way you
  # use any other connection adapter, for example by specifying the
  # adapter name in a Rails application's database.yml file. You do not
  # need to require any files to gain access to these adapters. RGeo
  # makes them available to ActiveRecord automatically.
  # 
  # The RGeo::ActiveRecord module itself is a namespace for the internal
  # adapter implementation. You generally do not need to interact with
  # this module yourself.
  # 
  # Following is a list of the adapters supported by RGeo.
  # 
  # === mysqlspatial
  # 
  # An adapter based on the standard mysql adapter. It extends the stock
  # adapter to provide support for spatial columns in MySQL, mapping the
  # values properly to RGeo spatial objects. Like the standard mysql
  # adapter, this requires the mysql gem (version 2.8 or later).
  # 
  # In a database.yml configuration, mysqlspatial uses the same config
  # parameters as the stock mysql adapter.
  # 
  # STATUS: The mysqlspatial adapter is fairly complete, and there are no
  # known functionality holes at this time. However, it is not yet
  # well-tested.
  # 
  # === mysql2spatial
  # 
  # An adapter for MySQL spatial based on the mysql2 adapter. It requires
  # the mysql2 gem (version 0.2.6 or later).
  # 
  # In a database.yml configuration, mysql2spatial uses the same config
  # parameters as the stock mysql2 adapter.
  # 
  # STATUS: The mysql2spatial adapter is fairly complete, and there are
  # no known functionality holes at this time. However, it is not yet
  # well-tested.
  # 
  # === spatialite
  # 
  # An adapter for the SpatiaLite extension to Sqlite3. It is based on
  # the stock sqlite3 adapter, and requires the sqlite3-ruby gem.
  # 
  # In a database.yml configuration, in addition to the config parameters
  # used by the stock sqlite3 adapter, spatialite recognizes the
  # following parameters:
  # 
  # <tt>libspatialite</tt>::
  #   The path to the libspatialite shared library. By default, the
  #   adapter tries to look for this library in several usual places,
  #   including /usr/local, /usr/local/spatialite, /opt/local, /usr,
  #   and a few others. If it does not find libspatialite installed in
  #   one of these locations, it will raise an exception. If your
  #   library is installed in a different place, you can explicitly
  #   provide the path using this configuration key.
  # 
  # STATUS: The spatialite adapter works in principle, but there are a
  # few known holes in the functionality. Notably, things that require
  # the alter_table mechanism may not function properly, because the
  # current sqlite3 implementation doesn't properly preserve triggers.
  # This includes, among other things, removing columns. However, most
  # simple things work, including creating tables with geometric columns,
  # adding geometric columns to existing tables, and creating and
  # removing spatial R*tree indexes. Note that this adapter is not yet
  # well-tested.
  # 
  # === postgis
  # 
  # An adapter for the PostGIS extension to Postgresql. It is based on
  # the stock postgresql adapter, and requires the pg gem.
  # 
  # In a database.yml configuration, postgis uses the same config
  # parameters as the stock postgresql adapter.
  # 
  # STATUS: The postgis adapter works in principle, but there are a
  # few known holes in the functionality. Notably, getting index info
  # doesn't recognize spatial (GiST) indexes. Also be aware that this
  # adapter is not yet well-tested.
  
  module ActiveRecord
    
    # Additional column types for geometries.
    GEOMETRY_TYPES = [:geometry, :point, :line_string, :polygon, :geometry_collection, :multi_line_string, :multi_point, :multi_polygon].freeze
    
    module Common  # :nodoc:
      
      class IndexDefinition < ::Struct.new(:table, :name, :unique, :columns, :lengths, :spatial)  # :nodoc:
      end
      
      class << self
        
        def geometric_type_from_name(name_)
          case name_.downcase
          when 'geometry' then ::RGeo::Feature::Geometry
          when 'point' then ::RGeo::Feature::Point
          when 'linestring' then ::RGeo::Feature::LineString
          when 'polygon' then ::RGeo::Feature::Polygon
          when 'geometrycollection' then ::RGeo::Feature::GeometryCollection
          when 'multipoint' then ::RGeo::Feature::MultiPoint
          when 'multilinestring' then ::RGeo::Feature::MultiLineString
          when 'multipolygon' then ::RGeo::Feature::MultiPolygon
          else nil
          end
        end
        
      end
      
    end
    
  end
  
end


require 'rgeo/active_record/arel_modifications'
require 'rgeo/active_record/base_modifications'
