# -----------------------------------------------------------------------------
# 
# Basic methods used by geometry objects
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
  
  module ImplHelpers  # :nodoc:
    
    
    module Serialization  # :nodoc:
      
      @helper_factory = false
      
      class << self
        
        
        def _helper_factory
          if @helper_factory == false
            if Geos.supported?
              @helper_factory = Geos.factory(:srid => 0)
            else
              @helper_factory = nil
            end
          end
          @helper_factory
        end
        
        
        def parse_wkt(str_, factory_)
          helper_factory_ = _helper_factory
          if helper_factory_
            obj_ = helper_factory_.parse_wkt(str_)
            obj_ ? Features.cast(obj_, factory_) : nil
          else
            default_parse_wkt(str_, factory_)
          end
        end
        
        
        def parse_wkb(str_, factory_)
          helper_factory_ = _helper_factory
          if helper_factory_
            obj_ = helper_factory_.parse_wkb(str_)
            obj_ ? Features.cast(obj_, factory_) : nil
          else
            default_parse_wkb(str_, factory_)
          end
        end
        
        
        def unparse_wkt(obj_)
          helper_factory_ = _helper_factory
          if helper_factory_
            Features.cast(obj_, helper_factory_).as_text
          else
            default_unparse_wkt(obj_)
          end
        end
        
        
        def unparse_wkb(obj_)
          helper_factory_ = _helper_factory
          if helper_factory_
            Features.cast(obj_, helper_factory_).as_binary
          else
            default_unparse_wkb(obj_)
          end
        end
        
        
        def default_parse_wkt(str_, factory_)
          nil  # TODO
        end
        
        
        def default_parse_wkb(str_, factory_)
          nil  # TODO
        end
        
        
        def default_unparse_wkt(obj_)
          nil  # TODO
        end
        
        
        def default_unparse_wkb(obj_)
          nil  # TODO
        end
        
        
      end
      
    end
    
    
  end
  
end
