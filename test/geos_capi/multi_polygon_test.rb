# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS multi polygon implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class GeosMultiPolygonTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::MultiPolygonTests

  def create_factories
    @factory = RGeo::Geos.factory
    @lenient_factory = RGeo::Geos.factory(lenient_multi_polygon_assertions: true)
  end

  # Centroid of an empty should return an empty collection rather than crash

  def test_empty_centroid
    assert_equal(@factory.collection([]), @factory.multi_polygon([]).centroid)
  end

  def test_geos_bug_582
    f = RGeo::Geos.factory(buffer_resolution: 2)
    p1 = f.polygon(f.linear_ring([]))
    p2 = f.polygon(f.linear_ring([f.point(0, 0), f.point(0, 1), f.point(1, 1), f.point(1, 0)]))
    mp = f.multi_polygon([p2, p1])
    mp.centroid.as_text
  end
end if RGeo::Geos.capi_supported?
