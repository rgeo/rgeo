# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS validity implementation
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"

class GeosValidityTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::ValidityTests

  def setup
    @factory = RGeo::Geos.factory(uses_lenient_multi_polygon_assertions: true)
  end
end if RGeo::Geos.capi_supported?
