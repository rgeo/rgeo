# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS multi polygon implementation
#
# -----------------------------------------------------------------------------

require "test_helper"
require_relative "skip_capi"

class GeosMultiPolygonTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::MultiPolygonTests
  prepend SkipCAPI

  def create_factories
    @factory = RGeo::Geos.factory
  end

  # Centroid of an empty should return an empty collection rather than crash

  def test_empty_centroid
    assert_equal(@factory.collection([]), @factory.multi_polygon([]).centroid)
  end

  def test_geos_bug582
    f = RGeo::Geos.factory(buffer_resolution: 2)
    p1 = f.polygon(f.linear_ring([]))
    p2 = f.polygon(f.linear_ring([f.point(0, 0), f.point(0, 1), f.point(1, 1), f.point(1, 0)]))
    mp = f.multi_polygon([p2, p1])
    mp.centroid.as_text
  end

  def test_polygonize
    input = @factory.parse_wkt("MULTIPOLYGON (((0 0, 1 1, 1 0, 0 0)))")
    expected = @factory.parse_wkt("GEOMETRYCOLLECTION (MULTIPOLYGON (((0 0, 1 1, 1 0, 0 0))))")

    assert_equal expected, input.polygonize
  end

  INVALID_MULTIPOLYGON = "MULTIPOLYGON (((0 1,2 1,2 2,0 2,0 1)), ((1 0,3 0,3 3,1 3,1 0)))"
  LINEWORK_MULTIPOLYGON = "MULTIPOLYGON (((1 2, 1 1, 0 1, 0 2, 1 2)), " \
                          "((1 3, 3 3, 3 0, 1 0, 1 1, 2 1, 2 2, 1 2, 1 3)))"
  JOINED_POLYGON = "POLYGON ((0 2, 1 2, 1 3, 3 3, 3 0, 1 0, 1 1, 0 1, 0 2))"

  # default make_valid uses linework method and intersection is removed
  def test_make_valid
    multipolygon = @factory.parse_wkt(INVALID_MULTIPOLYGON)
    expected = @factory.parse_wkt(LINEWORK_MULTIPOLYGON)

    assert_equal expected, multipolygon.make_valid
  end

  # linework is default so result is same as without params for multipolygon
  def test_make_valid_method_linework
    multipolygon = @factory.parse_wkt(INVALID_MULTIPOLYGON)
    expected = @factory.parse_wkt(LINEWORK_MULTIPOLYGON)

    assert_equal expected, multipolygon.make_valid(method: :linework)
  end

  # make_valid with method structure joins intersected polygons
  def test_make_valid_method_structure
    multipolygon = @factory.parse_wkt(INVALID_MULTIPOLYGON)
    expected = @factory.parse_wkt(JOINED_POLYGON)

    assert_equal expected, multipolygon.make_valid(method: :structure)
  end

  def test_make_valid_method_structure_string
    multipolygon = @factory.parse_wkt(INVALID_MULTIPOLYGON)
    expected = @factory.parse_wkt(JOINED_POLYGON)

    assert_equal expected, multipolygon.make_valid(method: "structure")
  end

  def test_make_valid_method_unknown
    assert_raises(ArgumentError) do
      @factory.parse_wkt(INVALID_MULTIPOLYGON).make_valid(method: :some_method)
    end
  end

  # make_valid with method structure and keep_collapsed has no effect - works as method=structure
  def test_make_valid_method_structure_keep_collapsed
    multipolygon = @factory.parse_wkt(INVALID_MULTIPOLYGON)
    expected = @factory.parse_wkt(JOINED_POLYGON)

    assert_equal expected, multipolygon.make_valid(method: :structure, keep_collapsed: false)
    assert_equal expected, multipolygon.make_valid(method: :structure, keep_collapsed: true)
  end
end
