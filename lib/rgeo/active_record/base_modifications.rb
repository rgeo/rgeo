# -----------------------------------------------------------------------------
# 
# Mysqlgeo adapter for ActiveRecord
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


require 'active_record'


# RGeo extensions to ActiveRecord are installed when one of the spatial
# connection adapters is needed. These modifications require ActiveRecord
# 3.0.3 or later.

module ActiveRecord
  
  
  # RGeo extends ActiveRecord::Base to include the following new class
  # attributes. These attributes are inherited by subclasses, and can
  # be overridden in subclasses.
  # 
  # === ActiveRecord::Base::rgeo_factory_generator
  # 
  # The value of this attribute is a RGeo::Feature::FactoryGenerator
  # that is used to generate the proper factory when loading geometry
  # objects from the database. For example, if the data being loaded
  # has M but not Z coordinates, and an embedded SRID, then this
  # FactoryGenerator is called with the appropriate configuration to
  # obtain a factory with those properties. This factory is the one
  # associated with the actual geometry properties of the ActiveRecord
  # object.
  # 
  # === ActiveRecord::Base::rgeo_default_factory
  # 
  # The default factory used to load RGeo geometry objects from the
  # database. This is used when there is no rgeo_factory_generator.
  
  class Base
    
    
    self.attribute_types_cached_by_default << :geometry
    
    
    class_attribute :rgeo_default_factory, :instance_writer => false
    self.rgeo_default_factory = nil
    
    class_attribute :rgeo_factory_generator, :instance_writer => false
    self.rgeo_factory_generator = nil
    
    
    # This is a convenient way to set the rgeo_factory_generator by
    # passing a block.
    
    def self.to_generate_rgeo_factory(&block_)
      self.rgeo_factory_generator = block_
    end
    
    
    class << self
      
      # :stopdoc:
      alias_method :columns_without_rgeo_modification, :columns
      def columns
        unless defined?(@columns) && @columns
          columns_without_rgeo_modification.each do |column_|
            column_.set_ar_class(self) if column_.respond_to?(:set_ar_class)
          end
        end
        @columns
      end
      # :startdoc:
      
    end
    
  end
  
  
  module ConnectionAdapters  # :nodoc:
    
    class TableDefinition  # :nodoc:
      
      ::RGeo::ActiveRecord::GEOMETRY_TYPES.each do |type_|
        method_ = <<-END_METHOD
          def #{type_}(*args_)
            opts_ = args_.extract_options!
            args_.each{ |name_| column(name_, '#{type_}', opts_) }
          end
        END_METHOD
        class_eval(method_, __FILE__, __LINE__-5)
      end
      
    end
    
  end
  
  
end
