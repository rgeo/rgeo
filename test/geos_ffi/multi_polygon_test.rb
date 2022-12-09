# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS multi polygon implementation
#
# -----------------------------------------------------------------------------

require "test_helper"
require_relative "skip_ffi"

class GeosFFIMultiPolygonTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::MultiPolygonTests
  include SkipFFI

  def create_factories
    @factory = RGeo::Geos.factory(native_interface: :ffi)
  end

  # Centroid of an empty should return an empty collection
  # rather than throw a weird exception out of ffi-geos
  def test_empty_centroid
    assert_equal(@factory.collection([]), @factory.multi_polygon([]).centroid)
  end
end
