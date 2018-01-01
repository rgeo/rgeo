# -----------------------------------------------------------------------------
#
# Tests for the GEOS line string implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class GeosFFILineStringTest < Test::Unit::TestCase # :nodoc:
  include RGeo::Tests::Common::LineStringTests

  def setup
    @factory = ::RGeo::Geos.factory(native_interface: :ffi)
  end
end if ::RGeo::Geos.ffi_supported?
