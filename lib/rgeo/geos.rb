# -----------------------------------------------------------------------------
#
# GEOS wrapper for RGeo
#
# -----------------------------------------------------------------------------

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
  # ::RGeo::Geos.factory method. You may then call any of the standard
  # factory methods on the resulting object.

  module Geos
  end
end

# :stopdoc:

module RGeo
  module Geos
    # Implementation files
    require "rgeo/geos/utils"
    require "rgeo/geos/interface"
    begin
      require "rgeo/geos/geos_c_impl"
    rescue ::LoadError; end
    CAPI_SUPPORTED = ::RGeo::Geos.const_defined?(:CAPIGeometryMethods)
    if CAPI_SUPPORTED
      require "rgeo/geos/capi_feature_classes"
      require "rgeo/geos/capi_factory"
    end
    require "rgeo/geos/ffi_feature_methods"
    require "rgeo/geos/ffi_feature_classes"
    require "rgeo/geos/ffi_factory"
    require "rgeo/geos/zm_feature_methods"
    require "rgeo/geos/zm_feature_classes"
    require "rgeo/geos/zm_factory"

    # Determine ffi support.
    begin
      require "ffi-geos"
      # An additional check to make sure FFI loaded okay. This can fail on
      # some versions of ffi-geos and some versions of Rubinius.
      raise "Problem loading FFI" unless ::FFI::AutoPointer
      FFI_SUPPORTED = true
      FFI_SUPPORT_EXCEPTION = nil
    rescue ::LoadError => ex_
      FFI_SUPPORTED = false
      FFI_SUPPORT_EXCEPTION = ex_
    rescue => ex_
      FFI_SUPPORTED = false
      FFI_SUPPORT_EXCEPTION = ex_
    end

    # Default preferred native interface
    if CAPI_SUPPORTED
      self.preferred_native_interface = :capi
    elsif FFI_SUPPORTED
      self.preferred_native_interface = :ffi
    end

    # There is some trouble with END_CAP in GEOS
    # In docs CAP_ROUND = 1, but it's work properly with 0
    CAP_ROUND  = 0
    CAP_FLAT   = 1
    CAP_SQUARE = 2

    JOIN_ROUND = 0
    JOIN_MITRE = 1
    JOIN_BEVEL = 2

    # Init internal utilities
    Utils._init
  end
end

# :startdoc:
