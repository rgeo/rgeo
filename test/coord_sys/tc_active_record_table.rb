# -----------------------------------------------------------------------------
#
# Tests for OGC CS classes
#
# -----------------------------------------------------------------------------
# Copyright 2010-2012 Daniel Azuma
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
require 'yaml'


module RGeo
  module Tests  # :nodoc:
    module CoordSys  # :nodoc:
      module ActiveRecordTableTests  # :nodoc:

        database_configs_ = ::YAML.load_file(::File.dirname(__FILE__)+'/database.yml') rescue nil
        if database_configs_
          begin
            require 'active_record'
          rescue ::LoadError
            database_configs_ = nil
          end
        end

        if database_configs_

          PostGIS_CONFIG = database_configs_['postgis'] rescue nil


          if PostGIS_CONFIG

            class TestPostGIS < ::Test::Unit::TestCase  # :nodoc:

              @@db = ::RGeo::CoordSys::SRSDatabase::ActiveRecordTable.new(
                :database_config => PostGIS_CONFIG,
                :auth_name_column => 'auth_name', :auth_srid_column => 'auth_srid',
                :srtext_column => 'srtext', :proj4text_column => 'proj4text')


              def test_4326
                entry_ = @@db.get(4326)
                assert_equal('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs', entry_.proj4.original_str)
                assert_kind_of(::RGeo::CoordSys::CS::GeographicCoordinateSystem, entry_.coord_sys)
                assert_equal('WGS 84', entry_.name)
              end


              def test_3785
                entry_ = @@db.get(3785)
                assert_equal('+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +units=m +k=1.0 +nadgrids=@null +no_defs', entry_.proj4.original_str)
                assert_kind_of(::RGeo::CoordSys::CS::ProjectedCoordinateSystem, entry_.coord_sys)
                assert_equal('Popular Visualisation CRS / Mercator (deprecated)', entry_.name)
              end


            end

          else
            puts "WARNING: No postgis section in database.yml; skipping PostGIS tests."
          end


        else
          puts "WARNING: Couldn't find database.yml or ActiveRecord gem is not present; skipping ActiveRecord tests."
        end

      end
    end
  end
end
