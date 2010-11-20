# -----------------------------------------------------------------------------
# 
# Tests for the MysqlSpatial ActiveRecord adapter
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


if ::File.exists?(::File.dirname(__FILE__)+'/databases.yml')
  
  require 'test/unit'
  require 'rgeo'
  require 'yaml'
  require 'active_record'
  
  
  module RGeo
    module Tests  # :nodoc:
      module ActiveRecord  # :nodoc:
        
        ALL_DATABASES_CONFIG = ::YAML.load_file(::File.dirname(__FILE__)+'/databases.yml')
        
        
        module Classes  # :nodoc:
          
          @class_num = 0
          
          def self.new_class(config_)
            klass_ = ::Class.new(::ActiveRecord::Base)
            @class_num += 1
            self.const_set("Klass#{@class_num}".to_sym, klass_)
            klass_.class_eval do
              establish_connection(config_)
              set_table_name(:spatial_test)
            end
            klass_
          end
          
        end
        
        
        module CommonTestMethods  # :nodoc:
          
          def self.included(klass_)
            database_config_ = ALL_DATABASES_CONFIG[klass_.const_get(:ADAPTER_NAME)]
            klass_.const_set(:DATABASE_CONFIG, database_config_)
            klass_.const_set(:DEFAULT_AR_CLASS, Classes.new_class(database_config_))
          end
          
          
          def setup
            @factory = ::RGeo::Cartesian.preferred_factory(:srid => 4326)
            cleanup_tables
          end
          
          
          def teardown
            cleanup_tables
          end
          
          
          def cleanup_tables
            klass_ = self.class.const_get(:DEFAULT_AR_CLASS)
            tables_ = klass_.connection.select_values('SHOW TABLES')
            tables_.each{ |table_| klass_.connection.drop_table(table_) }
          end
          
          
          def create_ar_class(opts_={})
            klass_ = Classes.new_class(self.class.const_get(:DATABASE_CONFIG))
            case opts_[:content]
            when :latlon_point
              klass_.connection.create_table(:spatial_test) do |t_|
                t_.column 'latlon', :point
              end
            end
            @ar_class = klass_
          end
          
          
          def test_create_simple_geometry
            klass_ = create_ar_class
            klass_.connection.create_table(:spatial_test) do |t_|
              t_.column 'latlon', :geometry
            end
            assert_equal(::RGeo::Features::Geometry, klass_.columns.last.geometric_type)
            assert(klass_.cached_attributes.include?('latlon'))
          end
          
          
          def test_create_point_geometry
            klass_ = create_ar_class
            klass_.connection.create_table(:spatial_test) do |t_|
              t_.column 'latlon', :point
            end
            assert_equal(::RGeo::Features::Point, klass_.columns.last.geometric_type)
            assert(klass_.cached_attributes.include?('latlon'))
          end
          
          
          def test_create_geometry_with_index
            klass_ = create_ar_class
            klass_.connection.create_table(:spatial_test, :options => 'ENGINE=MyISAM') do |t_|
              t_.column 'latlon', :geometry, :null => false
            end
            klass_.connection.change_table(:spatial_test) do |t_|
              t_.index([:latlon], :spatial => true)
            end
            assert(klass_.connection.indexes(:spatial_test).last.spatial)
          end
          
          
          def test_set_and_get_point
            klass_ = create_ar_class(:content => :latlon_point)
            obj_ = klass_.new
            assert_nil(obj_.latlon)
            obj_.latlon = @factory.point(1, 2)
            assert_equal(@factory.point(1, 2), obj_.latlon)
            assert_equal(4326, obj_.latlon.srid)
          end
          
          
          def test_set_and_get_point_from_wkt
            klass_ = create_ar_class(:content => :latlon_point)
            obj_ = klass_.new
            assert_nil(obj_.latlon)
            obj_.latlon = 'SRID=1000;POINT(1 2)'
            assert_equal(@factory.point(1, 2), obj_.latlon)
            assert_equal(1000, obj_.latlon.srid)
          end
          
          
          def test_save_and_load_point
            klass_ = create_ar_class(:content => :latlon_point)
            obj_ = klass_.new
            obj_.latlon = @factory.point(1, 2)
            obj_.save!
            id_ = obj_.id
            obj2_ = klass_.find(id_)
            assert_equal(@factory.point(1, 2), obj2_.latlon)
            assert_equal(4326, obj2_.latlon.srid)
          end
          
          
          def test_save_and_load_point_from_wkt
            klass_ = create_ar_class(:content => :latlon_point)
            obj_ = klass_.new
            obj_.latlon = 'SRID=1000;POINT(1 2)'
            obj_.save!
            id_ = obj_.id
            obj2_ = klass_.find(id_)
            assert_equal(@factory.point(1, 2), obj2_.latlon)
            assert_equal(1000, obj2_.latlon.srid)
          end
          
          
        end
        
        
        if ALL_DATABASES_CONFIG.include?('mysqlspatial')
          class TestMysqlSpatial < ::Test::Unit::TestCase  # :nodoc:
            ADAPTER_NAME = 'mysqlspatial'
            include CommonTestMethods
          end
        else
          puts "WARNING: Couldn't find mysqlspatial in databases.yml"
        end
        
        
        if ALL_DATABASES_CONFIG.include?('mysql2spatial')
          class TestMysql2Spatial < ::Test::Unit::TestCase  # :nodoc:
            ADAPTER_NAME = 'mysql2spatial'
            include CommonTestMethods
          end
        else
          puts "WARNING: Couldn't find mysql2spatial in databases.yml"
        end
        
        
      end
      
    end
  end
  
  
else
  puts "WARNING: databases.yml not found. Skipping ActiveRecord tests."
end
