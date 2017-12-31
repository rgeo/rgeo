# -----------------------------------------------------------------------------
#
# Tests for the simple spherical multi line string implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

module RGeo
  module Tests # :nodoc:
    module SphericalGeographic # :nodoc:
      class TestMultiLineString < ::Test::Unit::TestCase # :nodoc:
        include RGeo::Tests::Common::MultiLineStringTests

        def create_factory
          @factory = ::RGeo::Geographic.spherical_factory
        end

        undef_method :test_fully_equal
        undef_method :test_geometrically_equal
        undef_method :test_not_equal
        undef_method :test_length
      end
    end
  end
end
