# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for the GEOS point implementation
#
# -----------------------------------------------------------------------------

require_relative "../test_helper"
require_relative "skip_capi"

class GeosZMFactoryTest < Minitest::Test # :nodoc:
  include RGeo::Tests::Common::FactoryTests
  prepend SkipCAPI

  def setup
    @factory = RGeo::Geos.factory(has_z_coordinate: true, has_m_coordinate: true, srid: 1000, buffer_resolution: 2)
    @srid = 1000
  end

  def test_is_geos_factory
    assert_equal(true, RGeo::Geos.geos?(@factory))
    assert_equal(true, RGeo::Geos.capi_geos?(@factory))
    assert_equal(false, RGeo::Geos.ffi_geos?(@factory))
  end

  def test_factory_parts
    assert_equal(1000, @factory.srid)
    assert_equal(1000, @factory.z_factory.srid)
    assert_equal(1000, @factory.m_factory.srid)
    assert_equal(2, @factory.buffer_resolution)
    assert_equal(2, @factory.z_factory.buffer_resolution)
    assert_equal(2, @factory.m_factory.buffer_resolution)
    assert(@factory.property(:has_z_coordinate))
    assert(@factory.property(:has_m_coordinate))
    assert(@factory.z_factory.property(:has_z_coordinate))
    assert(!@factory.z_factory.property(:has_m_coordinate))
    assert(!@factory.m_factory.property(:has_z_coordinate))
    assert(@factory.m_factory.property(:has_m_coordinate))
  end

  def test_centroid_raises
    point1 = @factory.point(0, 0, 0, 0)
    point2 = @factory.point(0, 1, 0, 0)
    point3 = @factory.point(1, 0, 0, 0)
    polygon = @factory.polygon(@factory.linear_ring([point1, point2, point3, point1]))
    assert_raises(RGeo::Error::UnsupportedOperation) do
      polygon.centroid
    end
  end

  def test_inspect_shows_more_than_2d
    point = @factory.point(1, 2, 3, 4)
    assert_match("POINT (1.0 2.0 3.0 4.0)", point.inspect)
  end

  def test_4d_point
    point = @factory.point(1, 2, 3, 4)
    assert_equal(RGeo::Feature::Point, point.geometry_type)
    assert_equal(3, point.z)
    assert_equal(4, point.m)
    assert_equal(3, point.z_geometry.z)
    assert_nil(point.z_geometry.m)
    assert_nil(point.m_geometry.z)
    assert_equal(4, point.m_geometry.m)
  end
end
