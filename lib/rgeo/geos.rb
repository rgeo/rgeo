# -----------------------------------------------------------------------------
# 
# GEOS wrapper for RGeo
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
  
  
  # The Geos module provides general tools for creating and manipulating
  # a GEOS-backed implementation of the SFS. This is a full implementation
  # of the SFS using a Cartesian coordinate system. It uses the GEOS C++
  # library to perform most operations, and hence is available only if
  # GEOS version 3.2 or later is installed and accessible when the rgeo
  # gem is installed. RGeo feature calls are translated into appropriate
  # GEOS calls and directed to the library's C api. RGeo also corrects a
  # few cases of missing or non-standard behavior in GEOS.
  # 
  # This module also provides a namespace for the implementation classes
  # themselves; however, those classes are meant to be opaque and are
  # therefore not documented.
  # 
  # To use the Geos implementation, first obtain a factory using the
  # ::RGeo::Geos::factory method. You may then call any of the standard
  # factory methods on the resulting object.
  
  module Geos
  end
  
  
end


# Implementation files
require 'rgeo/geos/factory'
require 'rgeo/geos/interface'
require 'rgeo/geos/geos_c_impl'
require 'rgeo/geos/impl_additions'
require 'rgeo/geos/zm_factory'
require 'rgeo/geos/zm_impl'
