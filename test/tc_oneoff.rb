# -----------------------------------------------------------------------------
#
# A container file for one-off tests
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"
require "ffi-geos"

module RGeo
  module Tests # :nodoc:
    class TestOneOff < ::Test::Unit::TestCase # :nodoc:
      def setup
        # @mercator_factory = ::RGeo::Geographic.simple_mercator_factory
        # @spherical_factory = ::RGeo::Geographic.spherical_factory(:buffer_resolution => 2)
        # @projected_factory = ::RGeo::Geographic.projected_factory(:projection_proj4 => '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs', :projection_srid => 3857, :has_z_coordinate => true)
        # @geos_factory = ::RGeo::Geos.factory(:buffer_resolution => 2)
        # @cartesian_factory = ::RGeo::Cartesian.simple_factory(:buffer_resolution => 2)
      end

      def test_dummy
      end
    end
  end
end
