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
# The RGeo::Feature module contains interface specifications for spatial
# objects implemented by RGeo. These interfaces closely follow the OGC
# Simple Features Specifiation (SFS). This module forms the core of RGeo.
# 
# The RGeo::CoordSys module contains classes for representing spatial
# reference systems and coordinate transformations. For example, it
# includes a wrapper for the Proj4 library, supporting many geographic
# projections.
# 
# The RGeo::Cartesian module provides a basic pure ruby implementation of
# spatial objects in a Cartesian (flat) coordinate system. It does not
# implement all the geometric analysis operations in the SFS, but it
# implements the data structures without requiring an external C library,
# so it is often sufficient for basic applications.
# 
# The RGeo::Geos module is another Cartesian implementation that wraps
# the GEOS library to provide a full, high-performance implementation of
# Cartesian geometry that includes every operation defined in the SFS. It
# requires GEOS 3.2 or later.
# 
# The RGeo::Geography module contains spatial implementations that
# operate in latitude-longitude coordinates and are well-suited for
# geographic location based applications. Geography implementations may
# also be linked to projections.
# 
# The RGeo::WKRep module contains tools for reading and writing spatial
# data in the OGC Well-Known Text (WKT) and Well-Known Binary (WKB)
# representations. It also supports common variants such as the PostGIS
# EWKT and EWKB representations.
# 
# The RGeo::GeoJSON module contains tools for GeoJSON serialization of
# spatial objects. These tools work with any of the spatial object
# implementations.
# 
# The RGeo::Shapefile module contains tools for reading ESRI shapefiles,
# an industry standard (if somewhat legacy) file format commonly used for
# providing geographic data sets.
# 
# The RGeo::ActiveRecord module contains ActiveRecord connection adapters
# for handling spatial data with MySQL Spatial, SpatiaLite, and PostGIS.
# See the RGeo::ActiveRecord rdocs for more information on using these
# adapters. However, you do not need to access or require this module
# directly from code. ActiveRecord will load these adapters automatically
# when they are requested.
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
#  require 'rgeo/feature'
#  require 'rgeo/cartesian'
#  require 'rgeo/coord_sys'
#  require 'rgeo/geography'
#  require 'rgeo/geos'
#  require 'rgeo/geo_json'
#  require 'rgeo/shapefile'
#  require 'rgeo/wkrep'
# 
# You do not need to explicitly require any files for access to the
# spatial ActiveRecord adapters. ActiveRecord will load them
# automatically when they are referenced.

module RGeo
  
  autoload(:Cartesian, 'rgeo/cartesian')
  autoload(:CoordSys, 'rgeo/coord_sys')
  autoload(:Error, 'rgeo/error')
  autoload(:Feature, 'rgeo/feature')
  autoload(:GeoJSON, 'rgeo/geo_json')
  autoload(:Geography, 'rgeo/geography')
  autoload(:Geos, 'rgeo/geos')
  autoload(:ImplHelper, 'rgeo/impl_helper')
  autoload(:Shapefile, 'rgeo/shapefile')
  autoload(:WKRep, 'rgeo/wkrep')
  
end

require 'rgeo/version'
