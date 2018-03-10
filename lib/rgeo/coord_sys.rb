# -----------------------------------------------------------------------------
#
# Coordinate systems for RGeo
#
# -----------------------------------------------------------------------------

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
    # The only valid key is :proj4
    def self.supported?(key)
      raise(Error::UnsupportedOperation, "Invalid key. The only valid key is :proj4.") unless key == :proj4
      defined?(RGeo::CoordSys::Proj4) && RGeo::CoordSys::Proj4.supported?
    end

    def self.check!(key)
      supported?(key) || raise(Error::UnsupportedOperation, "Coordinate system '#{key}' is not supported.")
    end
  end
end

# Implementation files
require "rgeo/coord_sys/cs/factories"
require "rgeo/coord_sys/cs/entities"
require "rgeo/coord_sys/cs/wkt_parser"
require "rgeo/coord_sys/srs_database/interface.rb"
require "rgeo/coord_sys/srs_database/url_reader.rb"
require "rgeo/coord_sys/srs_database/sr_org.rb"
