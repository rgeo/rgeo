# -----------------------------------------------------------------------------
#
# SRS database interface
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


module RGeo

  module CoordSys

    module SRSDatabase


      # A spatial reference database implementation that uses ActiveRecord
      # to access a spatial reference table provided by a spatial database
      # implementation. You can use this class to obtain coordinate system
      # information from your installation of, e.g. PostGIS.

      class ActiveRecordTable

        @@class_counter = 0


        # Create a new ActiveRecord-backed database connection.
        #
        # Options include:
        #
        # [<tt>:ar_class</tt>]
        #   An ActiveRecord class to use. You may provide this if you
        #   already have an ActiveRecord class that accesses the table.
        #   If not provided, an ActiveRecord class will be generated
        #   for you, using the <tt>:ar_base_class</tt>,
        #   <tt>:database_config</tt>, and <tt>:table_name</tt> options.
        # [<tt>:ar_base_class</tt>]
        #   Specify an ActiveRecord base class to use when generating an
        #   ActiveRecord class. Default is ::ActiveRecord::Base. You may
        #   want to use this if you have a base class already that
        #   specifies an existing database connection and/or other
        #   class-scope options.
        # [<tt>:database_config</tt>]
        #   If provided, <tt>establish_connection</tt> will be called on
        #   the generated ActiveRecord class, with the given value.
        # [<tt>:table_name</tt>]
        #   The table name for the new ActiveRecord class. Defaults to
        #   the value <tt>spatial_ref_sys</tt>, which is the OGC-specified
        #   name for this table.
        # [<tt>:srid_column</tt>]
        #   The name of the SRID column. Defaults to "srid", which is the
        #   OGC-specified name for this column.
        # [<tt>:auth_name_column</tt>]
        #   The name of the authority name column. On an OGC-compliant
        #   database, this column should be named "auth_name". However,
        #   the default is set to nil; you should set this option
        #   explicitly if you want to read the authority name.
        # [<tt>:auth_srid_column</tt>]
        #   The name of the authority srid column. On an OGC-compliant
        #   database, this column should be named "auth_srid". However,
        #   the default is set to nil; you should set this option
        #   explicitly if you want to read the authority's srid.
        # [<tt>:name_column</tt>]
        #   The name of the coordinate system name column. This column is
        #   not part of the OGC spec, but it is included in some spatial
        #   database implementations. Default is nil.
        # [<tt>:description_column</tt>]
        #   The name of the coordinate system description column. This
        #   column is not part of the OGC spec, but may be included in
        #   some spatial database implementations. Default is nil.
        # [<tt>:srtext_column</tt>]
        #   The name of the spatial reference WKT column. On an
        #   OGC-compliant database, this column should be named "srtext".
        #   However, not all databases include this column, so the default
        #   is set to nil; you should set this option explicitly if you
        #   want to read the OGC coordinate system specification.
        # [<tt>:proj4text_column</tt>]
        #   The name of the Proj4 format projection spec column. This
        #   column is not part of the OGC spec, but may be included in
        #   some spatial database implementations. Default is nil.
        # [<tt>:cache</tt>]
        #   If set to true, entries are cached when first retrieved, so
        #   subsequent requests do not have to make a database round trip.
        #   Default is false.
        #
        # Some option settings may be provided by the ActiveRecord
        # connection adapter, if the ActiveRecord class's connection uses
        # an adapter that is RGeo-savvy. The "postgis" and "spatialite"
        # adapters are such adapters. They automatically provide the
        # <tt>:table_name</tt> and all the relevant column settings for
        # the database-provided spatial reference table as defaults.
        # However, you can still override those settings if you want to
        # use a custom table.

        def initialize(opts_={})
          @cache = opts_[:cache] ? {} : nil
          @ar_class = opts_[:ar_class]
          unless @ar_class
            ar_base_class_ = opts_[:ar_base_class] || ::ActiveRecord::Base
            @ar_class = ::Class.new(ar_base_class_)
            self.class.const_set("Klass#{@@class_counter}", @ar_class)
            @@class_counter += 1
            if opts_[:database_config]
              @ar_class.class_eval do
                establish_connection(opts_[:database_config])
              end
            end
          end
          connection_ = @ar_class.connection
          if connection_.respond_to?(:srs_database_columns)
            opts_ = connection_.srs_database_columns.merge(opts_)
          end
          unless opts_[:ar_class]
            @ar_class.class_eval do
              self.table_name = opts_[:table_name] || 'spatial_ref_sys'
            end
          end
          @srid_column = opts_[:srid_column] || 'srid'
          @auth_name_column = opts_[:auth_name_column]
          @auth_srid_column = opts_[:auth_srid_column]
          @name_column = opts_[:name_column]
          @description_column = opts_[:description_column]
          @srtext_column = opts_[:srtext_column]
          @proj4text_column = opts_[:proj4text_column]
        end


        # Retrieve an Entry given an integer SRID.

        def get(ident_)
          ident_ = ident_.to_i
          return @cache[ident_] if @cache && @cache.include?(ident_)
          obj_ = @ar_class.where(@srid_column => ident_).first
          unless obj_
            @cache[ident_] = nil if @cache
            return nil
          end
          auth_name_ = @auth_name_column ? obj_[@auth_name_column] : nil
          auth_srid_ = @auth_srid_column ? obj_[@auth_srid_column] : nil
          name_ = @name_column ? obj_[@name_column] : nil
          description_ = @description_column ? obj_[@description_column] : nil
          coord_sys_ = proj4_ = nil
          if @srtext_column
            coord_sys_ = CS.create_from_wkt(obj_[@srtext_column]) rescue nil
          end
          if @proj4text_column && Proj4.supported?
            proj4_ = Proj4.create(obj_[@proj4text_column].strip) rescue nil
          end
          result_ = Entry.new(ident_, :authority => auth_name_, :authority_code => auth_srid_, :name => name_, :description => description_, :coord_sys => coord_sys_, :proj4 => proj4_)
          @cache[ident_] = result_ if @cache
          result_
        end


        # Clears the cache if a cache is active.

        def clear_cache
          @cache.clear if @cache
        end


      end


    end

  end

end
