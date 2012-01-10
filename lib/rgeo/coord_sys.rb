# -----------------------------------------------------------------------------
#
# Coordinate systems for RGeo
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


module RGeo


  # This module provides data structures and tools related to coordinate
  # systems and coordinate transforms. It comprises the following parts:
  #
  # RGeo::CoordSys::Proj4 is a wrapper around the proj4 library, which
  # defines a commonly-used syntax for specifying geographic and projected
  # coordinate systems, and performs coordinate transformations.
  #
  # The RGeo::CoordSys::CS module contains an implementation of the CS
  # (coordinate systems) package of the OGC Coordinate Transform spec.
  # This includes classes for representing ellipsoids, datums, coordinate
  # systems, and other related concepts, as well as a parser for the WKT
  # format for specifying coordinate systems.
  #
  # The RGeo::CoordSys::SRSDatabase module contains tools for accessing
  # spatial reference databases, from which you can look up coordinate
  # system specifications. You can access the <tt>spatial_ref_sys</tt>
  # table provided with OGC-compliant spatial databases such as PostGIS,
  # read the databases provided with the proj4 library, or access URLs
  # such as those provided by spatialreference.org.

  module CoordSys
  end


end


# Implementation files
begin
  require 'rgeo/coord_sys/proj4_c_impl'
rescue ::LoadError; end
require 'rgeo/coord_sys/proj4'
require 'rgeo/coord_sys/cs/factories'
require 'rgeo/coord_sys/cs/entities'
require 'rgeo/coord_sys/cs/wkt_parser'
require 'rgeo/coord_sys/srs_database/interface.rb'
require 'rgeo/coord_sys/srs_database/active_record_table.rb'
require 'rgeo/coord_sys/srs_database/proj4_data.rb'
require 'rgeo/coord_sys/srs_database/url_reader.rb'
require 'rgeo/coord_sys/srs_database/sr_org.rb'
