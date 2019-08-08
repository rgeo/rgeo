# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the simple mercator multi line string implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class MercatorMultiLineStringTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::MultiLineStringTests

  def create_factory
    RGeo::Geographic.simple_mercator_factory
  end

  undef_method :test_length
  undef_method :test_point_on_surface
end
