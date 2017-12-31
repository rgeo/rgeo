# -----------------------------------------------------------------------------
#
# Tests for the GEOS multi line string implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class TestMultiLineString < Test::Unit::TestCase # :nodoc:
  include RGeo::Tests::Common::MultiLineStringTests

  def create_factory
    ::RGeo::Geos.factory
  end
end  if ::RGeo::Geos.capi_supported?
