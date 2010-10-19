# -----------------------------------------------------------------------------
# 
# LineString feature interface
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
  
  module Features
    
    
    # == SFS 1.1 Description
    # 
    # A LineString is a Curve with linear interpolation between Points.
    # Each consecutive pair of Points defines a Line segment.
    # 
    # == Notes
    # 
    # LineString is defined as a module and is provided primarily
    # for the sake of documentation. Implementations need not necessarily
    # include this module itself. Therefore, you should not depend on the
    # kind_of? method to check type. Instead, use the provided check_type
    # class method. A corresponding === operator is also provided to
    # to support case-when constructs.
    
    module LineString
      
      include Curve
      
      
      # === SFS 1.1 Description
      # 
      # The number of Points in this LineString.
      # 
      # === Notes
      # 
      # Returns an integer.
      
      def num_points
        raise Errors::MethodUnimplemented
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns the specified Point N in this LineString.
      # 
      # === Notes
      # 
      # Returns an object that supports the Point interface, or nil
      # if the given n is out of range.
      
      def point_n(n_)
        raise Errors::MethodUnimplemented
      end
      
      
      # Returns the constituent points as an array of objects that
      # support the Point interface.
      
      def points
        raise Errors::MethodUnimplemented
      end
      
      
    end
  
    
  end
  
end
