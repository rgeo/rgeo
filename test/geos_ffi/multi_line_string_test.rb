# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS multi line string implementation
#
# -----------------------------------------------------------------------------

require "test_helper"
require_relative "skip_ffi"

class GeosFFIMultiLineStringTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::MultiLineStringTests
  include SkipFFI

  def create_factory
    RGeo::Geos.factory(native_interface: :ffi)
  end
end
