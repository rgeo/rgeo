# frozen_string_literal: true

require 'test_helper'

class GeometrySridCopyPolicyTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_srid_copy_policy
    geom = read('POLYGON ((0 0, 0 5, 5 5, 5 0, 0 0))')
    geom.srid = 4326

    Geos.srid_copy_policy = :zero
    cloned = geom.clone

    assert_equal(4326, cloned.srid)

    Geos.srid_copy_policy = :lenient
    cloned = geom.clone

    assert_equal(4326, cloned.srid)

    Geos.srid_copy_policy = :strict
    cloned = geom.clone

    assert_equal(4326, cloned.srid)

    Geos.srid_copy_policy = :zero
    geom_b = geom.convex_hull

    assert_equal(0, geom_b.srid)

    Geos.srid_copy_policy = :lenient
    geom_b = geom.convex_hull

    assert_equal(4326, geom_b.srid)

    Geos.srid_copy_policy = :strict
    geom_b = geom.convex_hull

    assert_equal(4326, geom_b.srid)

    geom_b = read('POLYGON ((3 3, 3 8, 8 8, 8 3, 3 3))')
    geom_b.srid = 3875

    Geos.srid_copy_policy = :zero
    geom_c = geom.intersection(geom_b)

    assert_equal(0, geom_c.srid)

    Geos.srid_copy_policy = :lenient
    geom_c = geom.intersection(geom_b)

    assert_equal(4326, geom_c.srid)

    Geos.srid_copy_policy = :strict

    assert_raises(Geos::MixedSRIDsError) do
      geom.intersection(geom_b)
    end
  ensure
    Geos.srid_copy_policy = :default
  end

  def test_bad_srid_copy_policy
    assert_raises(ArgumentError) do
      Geos.srid_copy_policy = :blart
    end
  end

  def test_srid_copy_policy_default
    Geos.srid_copy_policy_default = :default

    assert_equal(:zero, Geos.srid_copy_policy_default)

    Geos.srid_copy_policy_default = :lenient

    assert_equal(:lenient, Geos.srid_copy_policy_default)

    Geos.srid_copy_policy_default = :strict

    assert_equal(:strict, Geos.srid_copy_policy_default)

    assert_raises(ArgumentError) do
      Geos.srid_copy_policy_default = :blart
    end
  ensure
    Geos.srid_copy_policy_default = :default
  end
end
