# -----------------------------------------------------------------------------
# 
# Tests for the PostGIS ActiveRecord adapter
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

require 'fileutils'
require 'test/unit'
require ::File.expand_path('common_setup_methods.rb', ::File.dirname(__FILE__))


module RGeo
  module Tests  # :nodoc:
    module ActiveRecord  # :nodoc:
      
      if TESTS_AVAILABLE
        
        
        if ALL_DATABASES_CONFIG.include?('postgis')
          
          class TestPostGis < ::Test::Unit::TestCase  # :nodoc:
            
            
            ADAPTER_NAME = 'postgis'
            
            include CommonSetupMethods
            
            
            def populate_ar_class(content_)
              klass_ = create_ar_class
              case content_
              when :latlon_point
                klass_.connection.create_table(:spatial_test) do |t_|
                  t_.column 'latlon', :point, :srid => 4326
                end
              when :latlon_point_geographic
                klass_.connection.create_table(:spatial_test) do |t_|
                  t_.column 'latlon', :point, :srid => 4326, :geographic => true
                end
              end
              klass_
            end
            
            
            def test_postgis_available
              connection_ = create_ar_class.connection
              assert_equal('PostGIS', connection_.adapter_name)
              assert_not_nil(connection_.postgis_lib_version)
            end
            
            
            def test_create_simple_geometry
              klass_ = create_ar_class
              klass_.connection.create_table(:spatial_test) do |t_|
                t_.column 'latlon', :geometry
              end
              assert_equal(1, klass_.connection.select_value("SELECT COUNT(*) FROM geometry_columns WHERE f_table_name='spatial_test'").to_i)
              col_ = klass_.columns.last
              assert_equal(::RGeo::Feature::Geometry, col_.geometric_type)
              assert_equal(false, col_.geographic?)
              assert_equal(4326, col_.srid)
              assert(klass_.cached_attributes.include?('latlon'))
              klass_.connection.drop_table(:spatial_test)
              assert_equal(0, klass_.connection.select_value("SELECT COUNT(*) FROM geometry_columns WHERE f_table_name='spatial_test'").to_i)
            end
            
            
            def test_create_simple_geography
              klass_ = create_ar_class
              klass_.connection.create_table(:spatial_test) do |t_|
                t_.column 'latlon', :geometry, :geographic => true
              end
              col_ = klass_.columns.last
              assert_equal(::RGeo::Feature::Geometry, col_.geometric_type)
              assert_equal(true, col_.geographic?)
              assert_equal(4326, col_.srid)
              assert(klass_.cached_attributes.include?('latlon'))
              assert_equal(0, klass_.connection.select_value("SELECT COUNT(*) FROM geometry_columns WHERE f_table_name='spatial_test'").to_i)
            end
            
            
            def test_create_point_geometry
              klass_ = create_ar_class
              klass_.connection.create_table(:spatial_test) do |t_|
                t_.column 'latlon', :point
              end
              assert_equal(::RGeo::Feature::Point, klass_.columns.last.geometric_type)
              assert(klass_.cached_attributes.include?('latlon'))
            end
            
            
            def test_create_geometry_with_index
              klass_ = create_ar_class
              klass_.connection.create_table(:spatial_test) do |t_|
                t_.column 'latlon', :geometry
              end
              klass_.connection.change_table(:spatial_test) do |t_|
                t_.index([:latlon], :spatial => true)
              end
            end
            
            
            def test_set_and_get_point
              klass_ = populate_ar_class(:latlon_point)
              obj_ = klass_.new
              assert_nil(obj_.latlon)
              obj_.latlon = @factory.point(1, 2)
              assert_equal(@factory.point(1, 2), obj_.latlon)
              assert_equal(4326, obj_.latlon.srid)
            end
            
            
            def test_set_and_get_point_from_wkt
              klass_ = populate_ar_class(:latlon_point)
              obj_ = klass_.new
              assert_nil(obj_.latlon)
              obj_.latlon = 'POINT(1 2)'
              assert_equal(@factory.point(1, 2), obj_.latlon)
              assert_equal(4326, obj_.latlon.srid)
            end
            
            
            def test_save_and_load_point
              klass_ = populate_ar_class(:latlon_point)
              obj_ = klass_.new
              obj_.latlon = @factory.point(1, 2)
              obj_.save!
              id_ = obj_.id
              obj2_ = klass_.find(id_)
              assert_equal(@factory.point(1, 2), obj2_.latlon)
              assert_equal(4326, obj2_.latlon.srid)
              assert_equal(true, ::RGeo::Geos.is_geos?(obj2_.latlon))
            end
            
            
            def test_save_and_load_geographic_point
              klass_ = populate_ar_class(:latlon_point_geographic)
              obj_ = klass_.new
              obj_.latlon = @factory.point(1, 2)
              obj_.save!
              id_ = obj_.id
              obj2_ = klass_.find(id_)
              assert_equal(@geographic_factory.point(1, 2), obj2_.latlon)
              assert_equal(4326, obj2_.latlon.srid)
              assert_equal(false, ::RGeo::Geos.is_geos?(obj2_.latlon))
            end
            
            
            def test_save_and_load_point_from_wkt
              klass_ = populate_ar_class(:latlon_point)
              obj_ = klass_.new
              obj_.latlon = 'POINT(1 2)'
              obj_.save!
              id_ = obj_.id
              obj2_ = klass_.find(id_)
              assert_equal(@factory.point(1, 2), obj2_.latlon)
              assert_equal(4326, obj2_.latlon.srid)
            end
            
            
            def test_add_geometry_column
              klass_ = create_ar_class
              klass_.connection.create_table(:spatial_test) do |t_|
                t_.column('latlon', :geometry)
              end
              klass_.connection.change_table(:spatial_test) do |t_|
                t_.column('geom2', :point, :srid => 4326)
                t_.column('name', :string)
              end
              assert_equal(2, klass_.connection.select_value("SELECT COUNT(*) FROM geometry_columns WHERE f_table_name='spatial_test'").to_i)
              cols_ = klass_.columns
              assert_equal(::RGeo::Feature::Geometry, cols_[-3].geometric_type)
              assert_equal(4326, cols_[-3].srid)
              assert_equal(::RGeo::Feature::Point, cols_[-2].geometric_type)
              assert_equal(4326, cols_[-2].srid)
              assert_equal(false, cols_[-2].geographic?)
              assert_nil(cols_[-1].geometric_type)
            end
            
            
            def test_add_geography_column
              klass_ = create_ar_class
              klass_.connection.create_table(:spatial_test) do |t_|
                t_.column('latlon', :geometry)
              end
              klass_.connection.change_table(:spatial_test) do |t_|
                t_.column('geom2', :point, :srid => 4326, :geographic => true)
                t_.column('name', :string)
              end
              assert_equal(1, klass_.connection.select_value("SELECT COUNT(*) FROM geometry_columns WHERE f_table_name='spatial_test'").to_i)
              cols_ = klass_.columns
              assert_equal(::RGeo::Feature::Geometry, cols_[-3].geometric_type)
              assert_equal(4326, cols_[-3].srid)
              assert_equal(::RGeo::Feature::Point, cols_[-2].geometric_type)
              assert_equal(4326, cols_[-2].srid)
              assert_equal(true, cols_[-2].geographic?)
              assert_nil(cols_[-1].geometric_type)
            end
            
            
            def test_drop_geometry_column
              klass_ = create_ar_class
              klass_.connection.create_table(:spatial_test) do |t_|
                t_.column('latlon', :geometry)
                t_.column('geom2', :point, :srid => 4326)
              end
              klass_.connection.change_table(:spatial_test) do |t_|
                t_.remove('geom2')
              end
              assert_equal(1, klass_.connection.select_value("SELECT COUNT(*) FROM geometry_columns WHERE f_table_name='spatial_test'").to_i)
              cols_ = klass_.columns
              assert_equal(::RGeo::Feature::Geometry, cols_[-1].geometric_type)
              assert_equal('latlon', cols_[-1].name)
              assert_equal(4326, cols_[-1].srid)
              assert_equal(false, cols_[-1].geographic?)
            end
            
            
            def test_drop_geography_column
              klass_ = create_ar_class
              klass_.connection.create_table(:spatial_test) do |t_|
                t_.column('latlon', :geometry)
                t_.column('geom2', :point, :srid => 4326, :geographic => true)
                t_.column('geom3', :point, :srid => 4326)
              end
              klass_.connection.change_table(:spatial_test) do |t_|
                t_.remove('geom2')
              end
              assert_equal(2, klass_.connection.select_value("SELECT COUNT(*) FROM geometry_columns WHERE f_table_name='spatial_test'").to_i)
              cols_ = klass_.columns
              assert_equal(::RGeo::Feature::Point, cols_[-1].geometric_type)
              assert_equal('geom3', cols_[-1].name)
              assert_equal(false, cols_[-1].geographic?)
              assert_equal(::RGeo::Feature::Geometry, cols_[-2].geometric_type)
              assert_equal('latlon', cols_[-2].name)
              assert_equal(false, cols_[-2].geographic?)
            end
            
            
          end
          
        else
          puts "WARNING: Couldn't find postgis in database.yml. Skipping those tests."
          puts "         See tests/active_record/readme.txt for more info."
        end
        
        
      end
      
    end
    
  end
end
