# -----------------------------------------------------------------------------
# 
# MysqlSpatial adapter common tools for ActiveRecord
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
require 'rgeo/wkrep'
require 'rgeo/active_record/common'


module RGeo
  
  module ActiveRecord  # :nodoc:
    
    
    module MysqlCommon  # :nodoc:
      
      
      module AdapterMethods  # :nodoc:
        
        
        def quote(value_, column_=nil)
          if ::RGeo::Feature::Geometry.check_type(value_)
            "GeomFromWKB(0x#{::RGeo::WKRep::WKBGenerator.new(:hex_format => true).generate(value_)},#{value_.srid})"
          else
            super
          end
        end
        
        
        def add_index(table_name_, column_name_, options_={})
          if options_[:spatial]
            index_name_ = index_name(table_name_, :column => Array(column_name_))
            if ::Hash === options_
              index_name_ = options_[:name] || index_name_
            end
            execute "CREATE SPATIAL INDEX #{index_name_} ON #{table_name_} (#{Array(column_name_).join(", ")})"
          else
            super
          end
        end
        
        
      end
      
      
      class IndexDefinition < ::ActiveRecord::ConnectionAdapters::IndexDefinition  # :nodoc:
        
        attr_accessor :spatial
        
      end
      
      
      module ColumnMethods  # :nodoc:
        
        
        def initialize(name_, default_, sql_type_=nil, null_=true)
          super(name_, default_,sql_type_, null_)
          @geometric_type = extract_geometric_type(sql_type_)
          @ar_class = nil
        end
        
        
        attr_writer :ar_class
        
        attr_reader :geometric_type
        
        
        def geometry?
          type == :geometry
        end
        
        
        def klass
          type == :geometry ? ::RGeo::Feature::Geometry : super
        end
        
        
        def type_cast(value_)
          self.geometry? ? ColumnMethods.string_to_geometry(value_, @ar_class) : super
        end
        
        
        def type_cast_code(var_name_)
          self.geometry? ? "::RGeo::ActiveRecord::MysqlCommon::ColumnMethods.string_to_geometry(#{var_name_}, self.class)" : super
        end
        
        
        private
        
        def extract_geometric_type(sql_type_)
          case sql_type_
          when /^geometry$/i then ::RGeo::Feature::Geometry
          when /^point$/i then ::RGeo::Feature::Point
          when /^linestring$/i then ::RGeo::Feature::LineString
          when /^polygon$/i then ::RGeo::Feature::Polygon
          when /^geometrycollection$/i then ::RGeo::Feature::GeometryCollection
          when /^multipoint$/i then ::RGeo::Feature::MultiPoint
          when /^multilinestring$/i then ::RGeo::Feature::MultiLineString
          when /^multipolygon$/i then ::RGeo::Feature::MultiPolygon
          else nil
          end
        end
        
        
        def simplified_type(sql_type_)
          sql_type_ =~ /geometry|point|linestring|polygon/i ? :geometry : super
        end
        
        
        def self.string_to_geometry(str_, ar_class_)
          case str_
          when ::RGeo::Feature::Geometry
            str_
          when ::String
            marker_ = str_[4,1]
            little_endian_ = marker_ == "\x01"
            wkt_ = !little_endian_ && marker_ != "\x00"
            srid_ = wkt_ ? 0 : str_[0,4].unpack(little_endian_ ? 'V' : 'N').first
            factory_generator_ = nil
            in_factory_generator_ = ar_class_ ? ar_class_.rgeo_factory_generator : nil
            default_factory_ = ar_class_ ? ar_class_.rgeo_default_factory : nil
            if default_factory_ || in_factory_generator_
              if in_factory_generator_
                default_factory_ ||= factory_generator_.call(:srid => srid_)
                if wkt_
                  factory_generator_ = in_factory_generator_
                end
              end
            else
              default_factory_ = ::RGeo::Cartesian.preferred_factory(:srid => srid_)
              if wkt_
                factory_generator_ = ::RGeo::Cartesian.method(:preferred_factory)
              end
            end
            if wkt_
              ::RGeo::WKRep::WKTParser.new(:support_ewkt => true, :default_factory => default_factory_, :factory_generator => factory_generator_).parse(str_)
            else
              ::RGeo::WKRep::WKBParser.new(:default_factory => default_factory_).parse(str_[4..-1])
            end
          else
            nil
          end
        end
        
        
      end
      
      
    end
    
    
  end
  
end
