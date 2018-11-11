# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# FFI-GEOS geometry implementation
#
# -----------------------------------------------------------------------------

module RGeo
  module Geos
    class FFIGeometryImpl # :nodoc:
      include FFIGeometryMethods
    end

    class FFIPointImpl # :nodoc:
      include FFIGeometryMethods
      include FFIPointMethods
    end

    class FFILineStringImpl  # :nodoc:
      include FFIGeometryMethods
      include FFILineStringMethods
    end

    class FFILinearRingImpl  # :nodoc:
      include FFIGeometryMethods
      include FFILineStringMethods
      include FFILinearRingMethods
    end

    class FFILineImpl # :nodoc:
      include FFIGeometryMethods
      include FFILineStringMethods
      include FFILineMethods
    end

    class FFIPolygonImpl # :nodoc:
      include FFIGeometryMethods
      include FFIPolygonMethods
    end

    class FFIGeometryCollectionImpl # :nodoc:
      include FFIGeometryMethods
      include FFIGeometryCollectionMethods
    end

    class FFIMultiPointImpl # :nodoc:
      include FFIGeometryMethods
      include FFIGeometryCollectionMethods
      include FFIMultiPointMethods
    end

    class FFIMultiLineStringImpl # :nodoc:
      include FFIGeometryMethods
      include FFIGeometryCollectionMethods
      include FFIMultiLineStringMethods
    end

    class FFIMultiPolygonImpl # :nodoc:
      include FFIGeometryMethods
      include FFIGeometryCollectionMethods
      include FFIMultiPolygonMethods
    end
  end
end
