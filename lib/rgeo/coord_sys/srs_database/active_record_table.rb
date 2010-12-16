# -----------------------------------------------------------------------------
# 
# SRS database interface
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
  
  module CoordSys
    
    module SRSDatabase
      
      
      class ActiveRecordTable
        
        @@class_counter = 0
        
        
        def initialize(opts_={})
          @cache = opts_[:cache] ? {} : nil
          @ar_class = opts_[:ar_class]
          unless @ar_class
            ar_base_class_ = opts_[:ar_base_class] || ::ActiveRecord::Base
            @ar_class = ::Class.new(ar_base_class_)
            self.class.const_set("Klass#{@@class_counter}", @ar_class)
            @@class_counter += 1
            @ar_class.class_eval do
              set_table_name(opts_[:table_name] || 'spatial_ref_sys')
            end
          end
          connection_ = @ar_class.connection
          if connection_.respond_to?(:srs_database_columns)
            opts_ = connection_.srs_database_columns.merge(opts_)
          end
          @srid_column = opts_[:srid_column] || 'srid'
          @auth_name_column = opts_[:auth_name_column]
          @auth_srid_column = opts_[:auth_srid_column]
          @name_column = opts_[:name_column]
          @description_column = opts_[:description_column]
          @srtext_column = opts_[:srtext_column]
          @proj4text_column = opts_[:proj4text_column]
        end
        
        
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
        
        
        def clear_cache
          @cache.clear if @cache
        end
        
        
      end
      
      
    end
    
  end
  
end
