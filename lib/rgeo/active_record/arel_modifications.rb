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


require 'arel'


# :stopdoc:

module Arel
  
  module Attributes
    
    class Geometry < Attribute; end
    
    class << self
      alias_method :for_without_geometry, :for
      def for(column_)
        column_.type == :geometry ? Geometry : for_without_geometry(column_)
      end
    end
    
  end
  
  module Visitors
    
    class Dot
      alias :visit_Arel_Attributes_Geometry :visit_Arel_Attribute
      alias :visit_RGeo_Feature_Geometry :visit_String
    end
    
    class ToSql
      alias :visit_Arel_Attributes_Geometry :visit_Arel_Attributes_Attribute
      alias :visit_RGeo_Feature_Geometry :visit_String
    end
    
    VISITORS['postgis'] = ::Arel::Visitors::PostgreSQL
    VISITORS['mysqlspatial'] = ::Arel::Visitors::MySQL
    VISITORS['spatialite'] = ::Arel::Visitors::SQLite
    
  end
  
end

# :startdoc:
