# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the simple mercator geometry collection implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class MercatorGeometryCollectionTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::GeometryCollectionTests

  def create_factory
    RGeo::Geographic.simple_mercator_factory
  end
end
