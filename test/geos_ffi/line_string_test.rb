# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS line string implementation
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"
require_relative "skip_ffi"

class GeosFFILineStringTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::LineStringTests
  include SkipFFI

  def setup
    @factory = RGeo::Geos.factory(native_interface: :ffi)
  end
end
