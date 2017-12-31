# -----------------------------------------------------------------------------
#
# Tests for the simple cartesian multi line string implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

module RGeo
  module Tests # :nodoc:
    module SimpleCartesian # :nodoc:
      class TestMultiLineString < ::Test::Unit::TestCase # :nodoc:
        include RGeo::Tests::Common::MultiLineStringTests

        def create_factory
          @factory = ::RGeo::Cartesian.simple_factory
        end

        undef_method :test_fully_equal
        undef_method :test_geometrically_equal
        undef_method :test_not_equal
      end
    end
  end
end
