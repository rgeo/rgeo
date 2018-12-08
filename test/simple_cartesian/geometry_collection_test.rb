# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the simple cartesian geometry collection implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class CartesianGeometryCollectionTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::GeometryCollectionTests

  def create_factory
    @factory = RGeo::Cartesian.simple_factory
  end

  undef_method :test_fully_equal
  undef_method :test_geometrically_equal
  undef_method :test_empty_equal
  undef_method :test_not_equal
  undef_method :test_empty_collection_boundary
end
