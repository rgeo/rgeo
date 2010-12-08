# -----------------------------------------------------------------------------
# 
# GeometryCollection feature interface
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
  
  module Feature
    
    
    # == SFS 1.1 Description
    # 
    # A GeometryCollection is a geometric object that is a collection of 1
    # or more geometric objects.
    # 
    # All the elements in a GeometryCollection shall be in the same Spatial
    # Reference. This is also the Spatial Reference for the GeometryCollection.
    # 
    # GeometryCollection places no other constraints on its elements.
    # Subclasses of GeometryCollection may restrict membership based on
    # dimension and may also place other constraints on the degree of spatial
    # overlap between elements.
    # 
    # == Notes
    # 
    # GeometryCollection is defined as a module and is provided primarily
    # for the sake of documentation. Implementations need not necessarily
    # include this module itself. Therefore, you should not depend on the
    # kind_of? method to check type. Instead, use the provided check_type
    # class method (or === operator) defined in the Type module.
    
    module GeometryCollection
      
      extend Type
      
      include Geometry
      include ::Enumerable
      
      
      # === SFS 1.1 Description
      # 
      # Returns the number of geometries in this GeometryCollection.
      # 
      # === Notes
      # 
      # Returns an integer.
      
      def num_geometries
        raise Error::UnsupportedOperation, "Method GeometryCollection#num_geometries not defined."
      end
      
      
      # === SFS 1.1 Description
      # 
      # Returns the Nth geometry in this GeometryCollection.
      # 
      # === Notes
      # 
      # Returns an object that supports the Geometry interface, or nil
      # if the given n is out of range.
      
      def geometry_n(n_)
        raise Error::UnsupportedOperation, "Method GeometryCollection#geometry_n not defined."
      end
      
      
      # Alias of the num_geometries method.
      
      def size
        num_geometries
      end
      
      
      # Alias of the geometry_n method.
      
      def [](n_)
        geometry_n(n_)
      end
      
      
      # Iterates over the geometries of this GeometryCollection.
      # 
      # This is not a standard SFS method, but is provided so that a
      # GeometryCollection can behave as a Ruby enumerable.
      # Note that all GeometryCollection implementations must also
      # include the Enumerable mixin.
      
      def each(&block_)
        raise Error::UnsupportedOperation, "Method GeometryCollection#each not defined."
      end
      
      
    end
  
    
  end
  
end
