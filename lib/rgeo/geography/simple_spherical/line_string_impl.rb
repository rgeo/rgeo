# -----------------------------------------------------------------------------
# 
# Spherical LineString implementation
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
  
  module Geography
    
    module SimpleSpherical
      
      
      class LineStringImpl
        
        
        include Features::LineString
        include Common::GeometryMethods
        include GeometryMethods
        include Common::LineStringMethods
        
        
        def initialize(factory_, points_)
          _set_factory(factory_)
          _setup(points_)
        end
        
        
      end
      
      
      class LineImpl
        
        
        include Features::Line
        include Common::GeometryMethods
        include GeometryMethods
        include Common::LineStringMethods
        include Common::LineMethods
        
        
        def initialize(factory_, start_, end_)
          _set_factory(factory_)
          _setup([start_, end_])
        end
        
        
      end
      
      
      class LinearRingImpl
        
        
        include Features::Line
        include Common::GeometryMethods
        include GeometryMethods
        include Common::LineStringMethods
        include Common::LinearRingMethods
        
        
        def initialize(factory_, points_)
          _set_factory(factory_)
          _setup(points_)
        end
        
        
      end
      
      
    end
    
  end
  
end
