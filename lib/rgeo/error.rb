# -----------------------------------------------------------------------------
#
# Error classes for RGeo
#
# -----------------------------------------------------------------------------

module RGeo
  # All RGeo errors are members of this namespace.

  module Error
    # Base class for all RGeo-related exceptions
    class RGeoError < ::RuntimeError
    end

    # The specified geometry is invalid
    class InvalidGeometry < RGeoError
    end

    # The specified operation is not supported or not implemented
    class UnsupportedOperation < RGeoError
    end

    # Parsing failed
    class ParseError < RGeoError
    end
  end
end
