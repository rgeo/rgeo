# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS geometry collection implementation
#
# -----------------------------------------------------------------------------

require "test_helper"
require_relative "skip_ffi"

class GeosFFIGeometryCollectionTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::GeometryCollectionTests
  include SkipFFI

  def create_factory
    RGeo::Geos.factory(native_interface: :ffi)
  end
end
