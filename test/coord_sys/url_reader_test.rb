# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for OGC CS classes
#
# -----------------------------------------------------------------------------

require "test_helper"

class UrlReaderTest < Minitest::Test # :nodoc:
  def test_sr_org_epsg_4326_ogcwkt
    db = RGeo::CoordSys::SRSDatabase::UrlReader.new
    entry = db.get("http://spatialreference.org/ref/epsg/4326/ogcwkt/")
    assert_kind_of(RGeo::CoordSys::CS::GeographicCoordinateSystem, entry.coord_sys)
    assert_equal("WGS 84", entry.name)
  end

  def test_sr_org_epsg_4326_proj4
    db = RGeo::CoordSys::SRSDatabase::UrlReader.new
    entry = db.get("http://spatialreference.org/ref/epsg/4326/proj4/")
    assert_equal("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs", entry.proj4.original_str)
  end

  def test_sr_org_epsg_3857_ogcwkt
    db = RGeo::CoordSys::SRSDatabase::UrlReader.new
    entry = db.get("http://spatialreference.org/ref/epsg/3857/ogcwkt/")
    assert_kind_of(RGeo::CoordSys::CS::ProjectedCoordinateSystem, entry.coord_sys)
    assert_equal("Popular Visualisation CRS / Mercator", entry.name)
  end

  def test_sr_org_epsg_3857_proj4
    db = RGeo::CoordSys::SRSDatabase::UrlReader.new
    entry = db.get("http://spatialreference.org/ref/epsg/3857/proj4/")
    assert_equal("+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +a=6378137 +b=6378137 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs", entry.proj4.original_str)
  end
end if false
