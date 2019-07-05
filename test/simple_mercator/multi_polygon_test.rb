# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the simple mercator multi polygon implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class MercatorMultiPolygonTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::MultiPolygonTests

  def create_factories
    @factory = RGeo::Geographic.simple_mercator_factory
    @lenient_factory = RGeo::Geographic.simple_mercator_factory(lenient_multi_polygon_assertions: true)
  end

  # These tests suffer from floating point issues
  undef_method :test_point_on_surface
end
