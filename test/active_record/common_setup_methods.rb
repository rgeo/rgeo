# -----------------------------------------------------------------------------
# 
# Common setup methods for ActiveRecord adapter tests
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


require 'rgeo'
require 'yaml'
require 'active_record'
require 'logger'


module RGeo
  module Tests  # :nodoc:
    module ActiveRecord  # :nodoc:
      
      
      if ::File.exists?(::File.dirname(__FILE__)+'/database.yml')
        
        TESTS_AVAILABLE = true
        
        ALL_DATABASES_CONFIG = ::YAML.load_file(::File.dirname(__FILE__)+'/database.yml')
        
        
        module CommonSetupMethods  # :nodoc:
          
          @class_num = 0
          
          
          def self.included(klass_)
            database_config_ = ALL_DATABASES_CONFIG[klass_.const_get(:ADAPTER_NAME)]
            database_config_.symbolize_keys!
            if klass_.respond_to?(:before_open_database)
              klass_.before_open_database(:config => database_config_)
            end
            klass_.const_set(:DATABASE_CONFIG, database_config_)
            ar_class_ = CommonSetupMethods.new_class(database_config_)
            klass_.const_set(:DEFAULT_AR_CLASS, ar_class_)
            if klass_.respond_to?(:initialize_database)
              klass_.initialize_database(:ar_class => ar_class_, :connection => ar_class_.connection)
            end
          end
          
          
          def self.new_class(param_)
            base_ = param_.kind_of?(::Class) ? param_ : ::ActiveRecord::Base
            config_ = param_.kind_of?(::Hash) ? param_ : nil
            klass_ = ::Class.new(base_)
            @class_num += 1
            self.const_set("Klass#{@class_num}".to_sym, klass_)
            klass_.class_eval do
              establish_connection(config_) if config_
              set_table_name(:spatial_test)
            end
            klass_
          end
          
          
          def setup
            @factory = ::RGeo::Cartesian.preferred_factory(:srid => 4326)
            cleanup_tables
          end
          
          
          def teardown
            # cleanup_tables
          end
          
          
          def cleanup_tables
            klass_ = self.class.const_get(:DEFAULT_AR_CLASS)
            if klass_.connection.tables.include?('spatial_test')
              klass_.connection.drop_table(:spatial_test)
            end
          end
          
          
          def create_ar_class(opts_={})
            @ar_class = CommonSetupMethods.new_class(self.class.const_get(:DEFAULT_AR_CLASS))
          end
          
          
        end
        
        
      else
        
        TESTS_AVAILABLE = false
        
        puts "WARNING: database.yml not found. Skipping ActiveRecord tests."
        puts "         See tests/active_record/readme.txt for more info."
        
      end
      
      
    end
  end
end
