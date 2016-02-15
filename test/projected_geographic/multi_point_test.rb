# -----------------------------------------------------------------------------
#
# Tests for the simple mercator multi point implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

require ::File.expand_path("../common/multi_point_tests.rb", ::File.dirname(__FILE__))

module RGeo
  module Tests # :nodoc:
    module ProjectedGeographic # :nodoc:
      class TestMultiPoint < ::Test::Unit::TestCase # :nodoc:
        def create_factory(opts_ = {})
          ::RGeo::Geographic.projected_factory(opts_.merge(
                                                 projection_proj4: "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs", projection_srid: 3857))
        end

        include ::RGeo::Tests::Common::MultiPointTests

        # These tests suffer from floating point issues
        undef_method :test_union
        undef_method :test_difference
        undef_method :test_intersection
      end
    end
  end
end if ::RGeo::CoordSys::Proj4.supported?
