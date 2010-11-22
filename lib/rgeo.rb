# -----------------------------------------------------------------------------
# 
# RGeo main file
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


# RGeo is a spatial data library for Ruby. It focuses on the storage and
# manipulation of spatial data types such as points, lines, and polygons.
# 
# === RGeo Modules
# 
# RGeo comprises a number of modules.
# 
# The RGeo::Features module contains interface specifications for spatial
# objects implemented by RGeo. These interfaces closely follow the OGC
# Simple Features Specifiation (SFS). This module forms the core of RGeo.
# 
# The RGeo::Cartesian module provides a basic pure ruby implementation of
# spatial objects in a Cartesian (flat) coordinate system. It does not
# implement all the geometric analysis operations in the SFS, but it
# implements the data structures without requiring an external C library,
# so it is often sufficient for basic applications.
# 
# The RGeo::Geos module is another cartesian implementation that wraps the
# GEOS library to provide a full, high-performance implementation of
# Cartesian geometry that includes every operation defined in the SFS. It
# requires GEOS 3.2 or later.
# 
# The RGeo::Geography module contains spatial implementations that
# operate in latitude-longitude coordinates and are well-suited for
# geographic location based applications.
# 
# One of the geography implementations is RGeo::Geography::SimpleMercator,
# which uses the same coordinate system and projection as that used by
# Google and Bing Maps, and is ideally suited for visualization
# applications based on those technologies.
# 
# The RGeo::Geography::SimpleSpherical provides another geography
# implementation that does not use a projection, but instead performs
# geometric operations on a spherical approximation of the globe. This
# implementation does not provide all the geometric analysis operations
# in the SFS, but it may be useful for cases when you need more accuracy
# than a projected implementation would provide.
# 
# The RGeo::WKRep module contains tools for reading and writing spatial
# data in the OGC Well-Known Text (WKT) and Well-Known Binary (WKB)
# representations. It also supports their variants such as the PostGIS
# EWKT and EWKB representations.
# 
# The RGeo::GeoJSON module contains tools for GeoJSON serialization of
# spatial objects. These tools work with any of the spatial object
# implementations.
# 
# === Loading the library
# 
# After installing the RGeo gem, you can load the library with:
#  require 'rgeo'
# 
# This will "lazy-load" the modules as they are referenced or needed
# (using autoload).
# 
# If, for performance reasons, or because you want to run RGeo in a
# multithreaded environment, you wish to eagerly load RGeo, you may do so
# with:
#  require 'rgeo/all'
# 
# You may also eagerly load individual modules:
#  require 'rgeo/features'
#  require 'rgeo/cartesian'
#  require 'rgeo/geos'
#  require 'rgeo/geography'
#  require 'rgeo/geography/simple_mercator'
#  require 'rgeo/geography/simple_spherical'
#  require 'rgeo/wkrep'
#  require 'rgeo/geo_json'
# 
# === Future modules
# 
# RGeo is in active development with several additional modules planned
# for future releases. These include:
# 
# * RGeo::Shapefile, which provides tools for reading and writing
#   spatial objects in the ESRI shapefile format.
# * RGeo::Rails, which provides close integration with Ruby On Rails
#   for developing location-based web applications.
# * RGeo::JTS, which provides a Cartesian SFS implementation backed by
#   the JTS library (which can run natively in JRuby.)
# * RGeo::Projection, which wraps and provides an API for the proj4
#   library, providing a way to compute arbitrary projections.
# * RGeo::Geography extensions to provide highly accurate ellipsoidal
#   geometric calculations, and support arbitrary map projections
#   via RGeo::Projection.

module RGeo
  
  autoload(:Cartesian, 'rgeo/cartesian')
  autoload(:Errors, 'rgeo/errors')
  autoload(:Features, 'rgeo/features')
  autoload(:GeoJSON, 'rgeo/geo_json')
  autoload(:Geography, 'rgeo/geography')
  autoload(:Geos, 'rgeo/geos')
  autoload(:ImplHelpers, 'rgeo/impl_helpers')
  autoload(:WKRep, 'rgeo/wkrep')
  autoload(:Shapefile, 'rgeo/shapefile')
  
end

require 'rgeo/version'
