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
    
    
    # This module contains tools for accessing spatial reference
    # databases. These are databases (either local or remote) from which
    # you can look up coordinate system specifications, typically in
    # either OGC or Proj4 format. For example, you can access the
    # <tt>spatial_ref_sys</tt> table provided with an OGC-compliant RDBMS
    # such as PostGIS. You can also read the database files provided with
    # the proj4 library, or access online databases such as the
    # spatialreference.org site.
    
    module SRSDatabase
      
      
      module Interface
        
        
        def get(ident_)
          nil
        end
        
        
        def clear_cache
          nil
        end
        
        
      end
      
      
      class Entry
        
        def initialize(ident_, data_={})
          @identifier = ident_
          @authority = data_[:authority]
          @authority_code = data_[:authority_code]
          @name = data_[:name]
          @description = data_[:description]
          @coord_sys = data_[:coord_sys]
          if @coord_sys.kind_of?(::String)
            @coord_sys = CS.create_from_wkt(@coord_sys)
          end
          @proj4 = data_[:proj4]
          if Proj4.supported?
            if @proj4.kind_of?(::String) || @proj4.kind_of?(::Hash)
              @proj4 = Proj4.create(@proj4)
            end
          else
            @proj4 = nil
          end
          if @coord_sys
            @name = @coord_sys.name unless @name
            @authority = @coord_sys.authority unless @authority
            @authority_code = @coord_sys.authority unless @authority_code
          end
        end
        
        attr_reader :identifier
        attr_reader :authority
        attr_reader :authority_code
        attr_reader :name
        attr_reader :description
        attr_reader :coord_sys
        attr_reader :proj4
        
      end
      
      
    end
    
  end
  
end
