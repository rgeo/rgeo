# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Coordinate systems for RGeo
#
# -----------------------------------------------------------------------------

require 'ostruct'
require_relative "coord_sys/cs/factories"
require_relative "coord_sys/cs/entities"
require_relative "coord_sys/cs/wkt_parser"

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
  module CoordSys
    CONFIG = OpenStruct.new
    CONFIG.default_coord_sys_class = CS::CoordinateSystem

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
