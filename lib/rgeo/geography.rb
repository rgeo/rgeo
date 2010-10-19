# -----------------------------------------------------------------------------
# 
# Geographic data for RGeo
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
  
  
  # The Geography implementation provides geographic features using
  # latitude/longitude coordinates measured in degrees.
  
  module Geography
  end
  
  
end


# Dependency source files.
paths_ = [
  'features',
  'geography/common/helper',
  'geography/common/geometry_methods',
  'geography/common/point_methods',
  'geography/common/line_string_methods',
  'geography/common/polygon_methods',
  'geography/common/geometry_collection_methods',
  'geography/simple_spherical/calculations',
  'geography/simple_spherical/geometry_methods',
  'geography/simple_spherical/point_impl',
  'geography/simple_spherical/line_string_impl',
  'geography/simple_spherical/polygon_impl',
  'geography/simple_spherical/geometry_collection_impl',
  'geography/simple_spherical/multi_point_impl',
  'geography/simple_spherical/multi_line_string_impl',
  'geography/simple_spherical/multi_polygon_impl',
  'geography/simple_mercator/projector',
  'geography/simple_mercator/feature_methods',
  'geography/simple_mercator/feature_classes',
  'geography/factory',
  'geography/projected_window',
  'geography/factories',
]
paths_.each{ |path_| require "rgeo/#{path_}" }
