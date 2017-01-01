# -----------------------------------------------------------------------------
#
# Tests for OGC CS classes
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

module RGeo
  module Tests # :nodoc:
    module CoordSys # :nodoc:
      class TestProj4SRSData < ::Test::Unit::TestCase # :nodoc:
        def test_epsg_4326
          db_ = ::RGeo::CoordSys::SRSDatabase::Proj4Data.new("epsg")
          entry_ = db_.get(4326)
          allowed_vals_ = [
            "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs", # Proj 4.7
            "+proj=longlat +datum=WGS84 +no_defs" # Proj 4.8
          ]
          assert(allowed_vals_.include?(entry_.proj4.original_str))
          assert_equal("WGS 84", entry_.name)
        end

        def test_epsg_3857
          db_ = ::RGeo::CoordSys::SRSDatabase::Proj4Data.new("epsg")
          entry_ = db_.get(3857)
          # some versions return "+wktext +no_defs", some "+wktext  +no_defs"
          assert_equal "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs",
            entry_.proj4.original_str.gsub("  ", " ")
          assert_equal "WGS 84 / Pseudo-Mercator", entry_.name
        end

        def test_nad83_4601
          db_ = ::RGeo::CoordSys::SRSDatabase::Proj4Data.new("nad83")
          entry_ = db_.get(4601)
          assert_equal("+proj=lcc  +datum=NAD83 +lon_0=-120d50 +lat_1=48d44 +lat_2=47d30 +lat_0=47 +x_0=500000 +y_0=0 +no_defs", entry_.proj4.original_str)
          assert_equal("4601: washington north: nad83", entry_.name)
        end
      end
    end
  end
end if ::RGeo::CoordSys::Proj4.supported?
