# -----------------------------------------------------------------------------
#
# Tests for the GEOS line string implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/line_string_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module GeosCAPI # :nodoc:
      class TestLineString < ::Test::Unit::TestCase # :nodoc:
        include ::RGeo::Tests::Common::LineStringTests

        def setup
          @factory = ::RGeo::Geos.factory
        end

        def test_project_interpolate_round_trip
          point =  @factory.point(2,2)
          line_string = @factory.line_string([ [0,0], [5,5] ].map { |x,y| @factory.point(x,y) })
          location = line_string.project_point point
          interpolated_point = line_string.interpolate_point location
          assert_equal point, interpolated_point
        end
      end
    end
  end
end if ::RGeo::Geos.capi_supported?
