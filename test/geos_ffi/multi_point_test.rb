# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS multi point implementation
#
# -----------------------------------------------------------------------------

require "test_helper"
require_relative "skip_ffi"

class GeosFFIMultiPointTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::MultiPointTests
  include SkipFFI

  def create_factory(opts = {})
    RGeo::Geos.factory(opts.merge(native_interface: :ffi))
  end
end
