# -----------------------------------------------------------------------------
#
# Tests for the GEOS multi line string implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class GeosFFIMultiLineStringTest < Test::Unit::TestCase # :nodoc:
  include RGeo::Tests::Common::MultiLineStringTests

  def create_factory
    RGeo::Geos.factory(native_interface: :ffi)
  end

end if RGeo::Geos.ffi_supported?
