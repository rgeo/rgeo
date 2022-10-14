# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS geometry collection implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

if RGeo::Geos.ffi_supported?
  class GeosFFIGeometryCollectionTest < Minitest::Test # :nodoc:
    include RGeo::Tests::Common::GeometryCollectionTests

    def create_factory
      RGeo::Geos.factory(native_interface: :ffi)
    end
  end
end
