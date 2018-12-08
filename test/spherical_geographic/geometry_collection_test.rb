# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the simple spherical geometry collection implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class SphericalGeometryCollectionTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::GeometryCollectionTests

  def create_factory
    @factory = RGeo::Geographic.spherical_factory
  end

  undef_method :test_fully_equal
  undef_method :test_geometrically_equal
  undef_method :test_empty_equal
  undef_method :test_not_equal
  undef_method :test_empty_collection_envelope
  undef_method :test_empty_collection_boundary
end
