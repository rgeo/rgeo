# -----------------------------------------------------------------------------
# 
# Cartesian features for RGeo
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


# Parent file
require 'rgeo'


module RGeo
  
  
  # The Cartesian module provides a simple spatial implementation using
  # the Cartesian coordinate system. This is the default implementation
  # used by RGeo if no full-featured implementation, such as Geos, is
  # available.
  # 
  # The Cartesian implementation can handle all the SFS 1.1 types, and
  # provides extensions for Z and M coordinates. It also provides WKT
  # and WKB serialization using the WKRep module.
  # 
  # However, the Cartesian implementation does not implement many of
  # the more advanced geometric operations. Limitations include:
  # * relational operators such as Features::Geometry#intersects? are
  #   not implemented for most types.
  # * relational constructors such as Features::Geometry#union are
  #   not implemented for most types.
  # * buffer, boundary, and convex hull calculation are not implemented
  #   for most types.
  # * distance and area calculation are not implemented for most types,
  #   though length for LineStrings is implemented.
  # * equality and simplicity evaluation are implemented for some types
  #   but not all types.
  # * assertions for polygons and multipolygons are not implemented.
  
  module Cartesian
  end
  
  
end


# Dependency files.
require 'rgeo/features'
require 'rgeo/wkrep'
require 'rgeo/impl_helpers'

# Implementation files.
require 'rgeo/cartesian/calculations'
require 'rgeo/cartesian/feature_methods'
require 'rgeo/cartesian/feature_classes'
require 'rgeo/cartesian/factory'
require 'rgeo/cartesian/interface'
require 'rgeo/cartesian/analysis'
