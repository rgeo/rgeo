# -----------------------------------------------------------------------------
#
# Tests for the GEOS multi polygon implementation
#
# -----------------------------------------------------------------------------

require "test_helper"

class GeosMultiPolygonTest < Test::Unit::TestCase # :nodoc:
  include RGeo::Tests::Common::MultiPolygonTests

  def create_factories
    @factory = RGeo::Geos.factory
    @lenient_factory = RGeo::Geos.factory(lenient_multi_polygon_assertions: true)
  end

  # Centroid of an empty should return an empty collection rather than crash

  def test_empty_centroid
    assert_equal(@factory.collection([]), @factory.multi_polygon([]).centroid)
  end

  def _test_geos_bug_582
    f_ = RGeo::Geos.factory(buffer_resolution: 2)
    p1_ = f_.polygon(f_.linear_ring([]))
    p2_ = f_.polygon(f_.linear_ring([f_.point(0, 0), f_.point(0, 1), f_.point(1, 1), f_.point(1, 0)]))
    mp_ = f_.multi_polygon([p2_, p1_])
    mp_.centroid.as_text
  end
end if RGeo::Geos.capi_supported?
