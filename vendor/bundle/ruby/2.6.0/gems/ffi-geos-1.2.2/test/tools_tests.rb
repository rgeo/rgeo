# frozen_string_literal: true

require 'test_helper'

class ToolsTests < Minitest::Test
  include TestHelper

  def test_check_geometry
    assert_raises(TypeError) do
      Geos::Tools.check_geometry(:foo)
    end
  end

  def test_bool_result
    assert(Geos::Tools.bool_result(1))
    refute(Geos::Tools.bool_result(0))

    assert_raises(Geos::UnexpectedBooleanResultError) do
      Geos::Tools.bool_result(-1)
    end
  end

  def test_bool_to_int
    assert_equal(1, Geos::Tools.bool_to_int(1))
    assert_equal(1, Geos::Tools.bool_to_int(true))
    assert_equal(1, Geos::Tools.bool_to_int(''))
    assert_equal(1, Geos::Tools.bool_to_int(0))
    assert_equal(0, Geos::Tools.bool_to_int(false))
    assert_equal(0, Geos::Tools.bool_to_int(nil))
  end

  def test_pick_srid_from_geoms
    Geos.srid_copy_policy = :default
    assert_equal(0, Geos::Tools.pick_srid_from_geoms(4326, 4269))

    Geos.srid_copy_policy = :zero
    assert_equal(0, Geos::Tools.pick_srid_from_geoms(4326, 4269))

    Geos.srid_copy_policy = :lenient
    assert_equal(4326, Geos::Tools.pick_srid_from_geoms(4326, 4269))

    Geos.srid_copy_policy = :strict
    assert_raises(Geos::MixedSRIDsError) do
      Geos::Tools.pick_srid_from_geoms(4326, 4269)
    end
  ensure
    Geos.srid_copy_policy = :default
  end

  def test_pick_srid_from_geoms_with_option
    assert_equal(0, Geos::Tools.pick_srid_from_geoms(4326, 4269, :default))
    assert_equal(0, Geos::Tools.pick_srid_from_geoms(4326, 4269, :zero))
    assert_equal(4326, Geos::Tools.pick_srid_from_geoms(4326, 4269, :lenient))

    assert_raises(Geos::MixedSRIDsError) do
      Geos::Tools.pick_srid_from_geoms(4326, 4269, :strict)
    end

    assert_raises(ArgumentError) do
      Geos::Tools.pick_srid_from_geoms(4326, 4269, :blart)
    end
  end

  def test_pick_srid_according_to_policy
    Geos.srid_copy_policy = :default
    assert_equal(0, Geos::Tools.pick_srid_according_to_policy(4326))

    Geos.srid_copy_policy = :zero
    assert_equal(0, Geos::Tools.pick_srid_according_to_policy(4326))

    Geos.srid_copy_policy = :lenient
    assert_equal(4326, Geos::Tools.pick_srid_according_to_policy(4326))

    Geos.srid_copy_policy = :strict
    assert_equal(4326, Geos::Tools.pick_srid_according_to_policy(4326))
  ensure
    Geos.srid_copy_policy = :default
  end

  def test_check_enum_value
    assert_equal(1, Geos::Tools.check_enum_value(Geos::BufferCapStyles, :round))

    assert_raises(TypeError) do
      Geos::Tools.check_enum_value(Geos::BufferCapStyles, :what)
    end
  end

  def test_symbol_for_enum
    assert_equal(:round, Geos::Tools.symbol_for_enum(Geos::BufferCapStyles, :round))
    assert_equal(:round, Geos::Tools.symbol_for_enum(Geos::BufferCapStyles, 1))
  end
end
