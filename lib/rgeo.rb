# -----------------------------------------------------------------------------
#
# RGeo main file
#
# -----------------------------------------------------------------------------
# Copyright 2010-2012 Daniel Azuma
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
# RGeo comprises a number of modules. The "rgeo" gem provides a suite of
# standard modules. Additional optional modules are provided by separate
# gems with names of the form "<tt>rgeo-*</tt>".
#
# === Standard modules
#
# These are the standard modules provided by the "rgeo" gem.
#
# * RGeo::Feature contains interface specifications for spatial
#   objects implemented by RGeo. These interfaces closely follow the OGC
#   Simple Features Specifiation (SFS). This module forms the core of RGeo.
#
# * RGeo::CoordSys contains classes for representing spatial
#   reference systems and coordinate transformations. For example, it
#   includes a wrapper for the Proj4 library, supporting many geographic
#   projections.
#
# * RGeo::Cartesian is a gateway for geometric data implementations
#   that operate in Caresian (flat) coordinate systems. It also provides a
#   basic pure ruby Cartesian implementation. This implementation does not
#   cover all the geometric analysis operations defined by the SFS, but it
#   does not require an external C library and is often sufficient for
#   basic applications.
#
# * RGeo::Geos is another Cartesian implementation that wraps the
#   GEOS library to provide a full, high-performance implementation of
#   Cartesian geometry that includes every operation defined in the SFS.
#   It requires GEOS 3.2 or later.
#
# * RGeo::Geographic contains spatial implementations that operate
#   in latitude-longitude coordinates and are well-suited for geographic
#   location based applications. Geographic spatial objects may also be
#   linked to projections.
#
# * RGeo::WKRep contains tools for reading and writing spatial
#   data in the OGC Well-Known Text (WKT) and Well-Known Binary (WKB)
#   representations. It also supports common variants such as the PostGIS
#   EWKT and EWKB representations.
#
# === Optional Modules
#
# Here is a partial list of optional modules available as separate gems.
#
# * <b>rgeo-geojson</b> provides the RGeo::GeoJSON module, containing
#   tools for GeoJSON encoding and decoding of spatial objects.
#
# * <b>rgeo-shapefile</b> provides the RGeo::Shapefile module, containing
#   tools for reading ESRI shapefiles.
#
# * <b>rgeo-activerecord</b> provides the RGeo::ActiveRecord module,
#   containing some ActiveRecord extensions for spatial databases, and a
#   set of common tools for ActiveRecord spatial database adapters.
#
# Several ActiveRecord adapters use RGeo. These include:
#
# * <b>mysqlspatial</b>, an adapter for MySQL spatial extensions based on
#   the mysql adapter. Available as the activerecord-mysqlspatial-adapter
#   gem.
#
# * <b>mysql2spatial</b>, an adapter for MySQL spatial extensions based on
#   the mysql2 adapter. Available as the activerecord-mysql2spatial-adapter
#   gem.
#
# * <b>spatialite</b>, an adapter for the SpatiaLite extension to the
#   Sqlite3 database, and based on the sqlite3 adapter. Available as the
#   activerecord-spatialite-adapter gem.
#
# * <b>postgis</b>, an adapter for the PostGIS extension to the PostgreSQL
#   database, and based on the postgresql adapter. Available as the
#   activerecord-postgis-adapter gem.

module RGeo
end


# Core modules
require 'rgeo/yaml'
require 'rgeo/version'
require 'rgeo/error'
require 'rgeo/feature'
require 'rgeo/coord_sys'
require 'rgeo/impl_helper'
require 'rgeo/wkrep'
require 'rgeo/geos'
require 'rgeo/cartesian'
require 'rgeo/geographic'
