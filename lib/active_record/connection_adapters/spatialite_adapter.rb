# -----------------------------------------------------------------------------
# 
# SpatiaLite adapter for ActiveRecord
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


require 'rgeo/active_record/common'
require 'active_record/connection_adapters/sqlite3_adapter'


module ActiveRecord
  
  class Base
    
    
    # Create a spatialite connection adapter.
    # 
    # What's done:
    # * Data type conversion
    # * Creating tables with geometric columns
    # * Adding geometric columns to existing tables
    # * Creating and removing spatial indexes
    # * Getting spatial index info (separate from normal indexes)
    # 
    # What's not done:
    # * Anything that requires alter_table, because the algorithm doesn't
    #   properly preserve the spatial metadata.
    # * Removing geometric columns, because it involves alter_table.
    
    
    def self.spatialite_connection(config_)
      unless 'spatialite' == config_[:adapter]
        raise ::ArgumentError, 'adapter name should be "spatialite"'
      end
      unless config_[:database]
        raise ::ArgumentError, "No database file specified. Missing argument: database"
      end
      
      # Allow database path relative to Rails.root, but only if
      # the database path is not the special path that tells
      # Sqlite to build a database only in memory.
      if defined?(::Rails.root) && ':memory:' != config_[:database]
        config_[:database] = ::File.expand_path(config_[:database], ::Rails.root)
      end
      
      unless self.class.const_defined?(:SQLite3)
        require_library_or_gem('sqlite3')
      end
      db_ = ::SQLite3::Database.new(config_[:database], :results_as_hash => true)
      db_.busy_timeout(config_[:timeout]) unless config_[:timeout].nil?
      
      # Load SpatiaLite
      path_ = config_[:libspatialite]
      if path_ && (!::File.file?(path_) || !::File.readable?(path_))
        raise "Cannot read libspatialite library at #{path_}"
      end
      unless path_
        prefixes_ = ['/usr/local/spatialite', '/usr/local/libspatialite', '/usr/local', '/opt/local', '/sw/local', '/usr']
        suffixes_ = ['so', 'dylib'].join(',')
        prefixes_.each do |prefix_|
          pa_ = ::Dir.glob("#{prefix_}/lib/libspatialite.{#{suffixes_}}")
          if pa_.size > 0
            path_ = pa_.first
            break
          end
        end
      end
      unless path_
        raise 'Cannot find libspatialite in the usual places. Please provide the path in the "libspatialite" config parameter.'
      end
      db_.enable_load_extension(1)
      db_.load_extension(path_)
      
      ConnectionAdapters::SpatiaLiteAdapter.new(db_, logger, config_)
    end
    
    
  end
  
  
  module ConnectionAdapters  # :nodoc:
    
    
    class SpatiaLiteAdapter < SQLite3Adapter  # :nodoc:
      
      
      ADAPTER_NAME = 'SpatiaLite'.freeze
      
      @@native_database_types = nil
      
      
      def native_database_types
        unless @@native_database_types
          @@native_database_types = super.dup
          @@native_database_types.merge!(:geometry => {:name => "geometry"}, :point => {:name => "point"}, :line_string => {:name => "linestring"}, :polygon => {:name => "polygon"}, :geometry_collection => {:name => "geometrycollection"}, :multi_point => {:name => "multipoint"}, :multi_line_string => {:name => "multilinestring"}, :multi_polygon => {:name => "multipolygon"})
        end
        @@native_database_types
      end
      
      
      def adapter_name
        ADAPTER_NAME
      end
      
      
      def spatialite_version
        @spatialite_version ||= SQLiteAdapter::Version.new(select_value('SELECT spatialite_version()'))
      end
      
      
      def quote(value_, column_=nil)
        if ::RGeo::Feature::Geometry.check_type(value_)
          "GeomFromWKB(X'#{::RGeo::WKRep::WKBGenerator.new(:hex_format => true).generate(value_)}', #{value_.srid})"
        else
          super
        end
      end
      
      
      def columns(table_name_, name_=nil)  #:nodoc:
        spatial_info_ = spatial_column_info(table_name_)
        table_structure(table_name_).map do |field_|
          col_ = SpatialColumn.new(field_['name'], field_['dflt_value'], field_['type'], field_['notnull'].to_i == 0)
          info_ = spatial_info_[field_['name']]
          if info_
            col_.set_srid(info_[:srid])
          end
          col_
        end
      end
      
      
      def spatial_indexes(table_name_, name_=nil)
        table_name_ = table_name_.to_s
        names_ = select_values("SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'idx_#{quote_string(table_name_)}_%' AND rootpage=0") || []
        names_.map do |name_|
          col_name_ = name_.sub("idx_#{table_name_}_", '')
          ::RGeo::ActiveRecord::Common::IndexDefinition.new(table_name_, name_, false, [col_name_], [], true)
        end
      end
      
      
      def create_table(table_name_, options_={})
        table_name_ = table_name_.to_s
        table_definition_ = SpatialTableDefinition.new(self)
        table_definition_.primary_key(options_[:primary_key] || ::ActiveRecord::Base.get_primary_key(table_name_.singularize)) unless options_[:id] == false
        yield table_definition_ if block_given?
        if options_[:force] && table_exists?(table_name_)
          drop_table(table_name_, options_)
        end
        
        create_sql_ = "CREATE#{' TEMPORARY' if options_[:temporary]} TABLE "
        create_sql_ << "#{quote_table_name(table_name_)} ("
        create_sql_ << table_definition_.to_sql
        create_sql_ << ") #{options_[:options]}"
        execute create_sql_
        
        table_definition_.spatial_columns.each do |col_|
          execute("SELECT AddGeometryColumn('#{quote_string(table_name_)}', '#{quote_string(col_.name)}', #{col_.srid}, '#{quote_string(col_.type.to_s.gsub('_','').upcase)}', 'XY', #{col_.null ? 0 : 1})")
        end
      end
      
      
      def drop_table(table_name_, options_={})
        execute("DELETE from geometry_columns where f_table_name='#{quote_string(table_name_.to_s)}'")
        super
      end
      
      
      def add_column(table_name_, column_name_, type_, options_={})
        if ::RGeo::ActiveRecord::GEOMETRY_TYPES.include?(type_.to_sym)
          execute("SELECT AddGeometryColumn('#{quote_string(table_name_.to_s)}', '#{quote_string(column_name_.to_s)}', #{options_[:srid].to_i}, '#{quote_string(type_.to_s)}', 'XY', #{options_[:null] == false ? 0 : 1})")
        else
          super
        end
      end
      
      
      def add_index(table_name_, column_name_, options_={})
        if options_[:spatial]
          column_name_ = column_name_.first if column_name_.kind_of?(::Array) && column_name_.size == 1
          table_name_ = table_name_.to_s
          column_name_ = column_name_.to_s
          spatial_info_ = spatial_column_info(table_name_)
          unless spatial_info_[column_name_]
            raise ::ArgumentError, "Can't create spatial index because column '#{column_name_}' in table '#{table_name_}' is not a geometry column"
          end
          result_ = select_value("SELECT CreateSpatialIndex('#{quote_string(table_name_)}', '#{quote_string(column_name_)}')").to_i
          if result_ == 0
            raise ::ArgumentError, "Spatial index already exists on table '#{table_name_}', column '#{column_name_}'"
          end
          result_
        else
          super
        end
      end
      
      
      def remove_index(table_name_, options_={})
        if options_[:spatial]
          column_ = options_[:column]
          unless column_
            raise ::ArgumentError, "You need to specify a column to remove a spatial index."
          end
          table_name_ = table_name_.to_s
          column_ = column_.to_s
          spatial_info_ = spatial_column_info(table_name_)
          unless spatial_info_[column_]
            raise ::ArgumentError, "Can't remove spatial index because column '#{column_name_}' in table '#{table_name_}' is not a geometry column"
          end
          index_name_ = "idx_#{table_name_}_#{column_}"
          has_index_ = select_value("SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='#{quote_string(index_name_)}'").to_i > 0
          unless has_index_
            raise ::ArgumentError, "Spatial index not present on table '#{table_name_}', column '#{column_name_}'"
          end
          execute("SELECT DisableSpatialIndex('#{quote_string(table_name_)}', '#{quote_string(column_)}')")
          execute("DROP TABLE #{quote_table_name(index_name_)}")
        else
          super
        end
      end
      
      
      def spatial_column_info(table_name_)
        info_ = execute("SELECT * FROM geometry_columns WHERE f_table_name='#{quote_string(table_name_.to_s)}'")
        result_ = {}
        info_.each do |row_|
          result_[row_['f_geometry_column']] = {
            :name => row_['f_geometry_column'],
            :type => row_['type'],
            :dimension => row_['coord_dimension'],
            :srid => row_['srid'],
            :has_index => row_['spatial_index_enabled'],
          }
        end
        result_
      end
      
      
      class SpatialTableDefinition < ConnectionAdapters::TableDefinition  # :nodoc:
        
        attr_reader :spatial_columns
        
        def initialize(base_)
          super
        end
        
        def column(name_, type_, options_={})
          super
          col_ = self[name_]
          if ::RGeo::ActiveRecord::GEOMETRY_TYPES.include?(col_.type.to_sym)
            col_.extend(GeometricColumnDefinitionMethods) unless col_.respond_to?(:srid)
            col_.set_srid(options_[:srid].to_i)
          end
          self
        end
        
        def to_sql
          @columns.find_all{ |c_| !c_.respond_to?(:srid) }.map{ |c_| c_.to_sql } * ', '
        end
        
        def spatial_columns
          @columns.find_all{ |c_| c_.respond_to?(:srid) }
        end
        
      end
      
      
      module GeometricColumnDefinitionMethods  # :nodoc:
        
        def srid
          defined?(@srid) ? @srid : 4326
        end
        
        def set_srid(value_)
          @srid = value_
        end
        
      end
      
      
      class SpatialColumn < ConnectionAdapters::SQLiteColumn  # :nodoc:
        
        
        def initialize(name_, default_, sql_type_=nil, null_=true)
          super(name_, default_, sql_type_, null_)
          @geometric_type = ::RGeo::ActiveRecord::Common.geometric_type_from_name(sql_type_)
          @ar_class = ::ActiveRecord::Base
          @srid = 0
        end
        
        
        def set_ar_class(val_)
          @ar_class = val_
        end
        
        def set_srid(val_)
          @srid = val_
        end
        
        
        attr_reader :srid
        attr_reader :geometric_type
        
        
        def spatial?
          type == :geometry
        end
        
        
        def klass
          type == :geometry ? ::RGeo::Feature::Geometry : super
        end
        
        
        def type_cast(value_)
          type == :geometry ? SpatialColumn.string_to_geometry(value_, @ar_class, @srid) : super
        end
        
        
        def type_cast_code(var_name_)
          type == :geometry ? "::ActiveRecord::ConnectionAdapters::SpatiaLiteAdapter::SpatialColumn.string_to_geometry(#{var_name_}, self.class, #{@srid})" : super
        end
        
        
        private
        
        
        def simplified_type(sql_type_)
          sql_type_ =~ /geometry|point|linestring|polygon/i ? :geometry : super
        end
        
        
        def self.string_to_geometry(str_, ar_class_, column_srid_)
          case str_
          when ::RGeo::Feature::Geometry
            str_
          when ::String
            if str_.length == 0
              nil
            else
              factory_generator_ = ar_class_.rgeo_factory_generator
              if str_[0,1] == "\x00"
                NativeFormatParser.new(factory_generator_).parse(str_) rescue nil
              else
                ::RGeo::WKRep::WKTParser.new(factory_generator_.call(:srid => column_srid_), :support_ewkt => true).parse(str_)
              end
            end
          else
            nil
          end
        end
        
        
      end
      
      
      class NativeFormatParser  # :nodoc:
        
        
        def initialize(factory_generator_)
          @factory_generator = factory_generator_
        end
        
        
        def parse(data_)
          @little_endian = data_[1,1] == "\x01"
          srid_ = data_[2,4].unpack(@little_endian ? 'V' : 'N').first
          @cur_factory = @factory_generator.call(:srid => srid_)
          begin
            _start_scanner(data_)
            obj_ = _parse_object(false)
            _get_byte(0xfe)
          ensure
            _clean_scanner
          end
          obj_
        end
        
        
        def _parse_object(contained_)
          _get_byte(contained_ ? 0x69 : 0x7c)
          type_code_ = _get_integer
          case type_code_
          when 1
            coords_ = _get_doubles(2)
            @cur_factory.point(*coords_)
          when 2
            _parse_line_string
          when 3
            interior_rings_ = (1.._get_integer).map{ _parse_line_string }
            exterior_ring_ = interior_rings_.shift || @cur_factory.linear_ring([])
            @cur_factory.polygon(exterior_ring_, interior_rings_)
          when 4
            @cur_factory.multi_point((1.._get_integer).map{ _parse_object(1) })
          when 5
            @cur_factory.multi_line_string((1.._get_integer).map{ _parse_object(2) })
          when 6
            @cur_factory.multi_polygon((1.._get_integer).map{ _parse_object(3) })
          when 7
            @cur_factory.collection((1.._get_integer).map{ _parse_object(true) })
          else
            raise ::RGeo::Error::ParseError, "Unknown type value: #{type_code_}."
          end
        end
        
        
        def _parse_line_string
          count_ = _get_integer
          coords_ = _get_doubles(2 * count_)
          @cur_factory.line_string((0...count_).map{ |i_| @cur_factory.point(*coords_[2*i_,2]) })
        end
        
        
        def _start_scanner(data_)
          @_data = data_
          @_len = data_.length
          @_pos = 38
        end
        
        
        def _clean_scanner
          @_data = nil
        end
        
        
        def _get_byte(expect_=nil)
          if @_pos + 1 > @_len
            raise ::RGeo::Error::ParseError, "Not enough bytes left to fulfill 1 byte"
          end
          str_ = @_data[@_pos, 1]
          @_pos += 1
          val_ = str_.unpack("C").first
          if expect_ && expect_ != val_
            raise ::RGeo::Error::ParseError, "Expected byte 0x#{expect_.to_s(16)} but got 0x#{val_.to_s(16)}"
          end
          val_
        end
        
        
        def _get_integer
          if @_pos + 4 > @_len
            raise ::RGeo::Error::ParseError, "Not enough bytes left to fulfill 1 integer"
          end
          str_ = @_data[@_pos, 4]
          @_pos += 4
          str_.unpack("#{@little_endian ? 'V' : 'N'}").first
        end
        
        
        def _get_doubles(count_)
          len_ = 8 * count_
          if @_pos + len_ > @_len
            raise ::RGeo::Error::ParseError, "Not enough bytes left to fulfill #{count_} doubles"
          end
          str_ = @_data[@_pos, len_]
          @_pos += len_
          str_.unpack("#{@little_endian ? 'E' : 'G'}*")
        end
        
        
      end
      
      
    end
    
  end
  
  
end
