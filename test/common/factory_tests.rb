# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Common tests for geometry collection implementations
#
# -----------------------------------------------------------------------------

module RGeo
  module Tests # :nodoc:
    module Common # :nodoc:
      module FactoryTests # :nodoc:
        def srid
          @srid || 0
        end

        def test_srid_preserved_through_factory
          geom = @factory.point(-10, 20)
          assert_equal(srid, geom.srid)
          factory = geom.factory
          assert_equal(srid, factory.srid)
          geom2 = factory.point(-20, 25)
          assert_equal(srid, geom2.srid)
        end

        def test_srid_preserved_through_geom_operations
          geom1 = @factory.point(-10, 20)
          geom2 = @factory.point(-20, 25)
          geom3 = geom1.union(geom2)
          assert_equal(srid, geom3.srid)
          assert_equal(srid, geom3.geometry_n(0).srid)
          assert_equal(srid, geom3.geometry_n(1).srid)
        end

        def test_srid_preserved_through_geom_functions
          geom1 = @factory.point(-10, 20)
          geom2 = geom1.boundary
          assert_equal(srid, geom2.srid)
        end

        def test_srid_preserved_through_geometry_dup
          geom1 = @factory.point(-10, 20)
          geom2 = geom1.clone
          assert_equal(srid, geom2.srid)
        end

        def test_dup_factoryresults_in_equal_factories
          dup_factory = @factory.dup
          assert_equal(@factory, dup_factory)
          assert_equal(srid, dup_factory.srid)
        end

        def test_dup_factoryresults_in_equal_hashes
          dup_factory = @factory.dup
          assert_equal(@factory.hash, dup_factory.hash)
        end

        def test_marshal_dump_load_factory
          data = Marshal.dump(@factory)
          factory2 = Marshal.load(data)
          assert_equal(@factory, factory2)
          assert_equal(srid, factory2.srid)
        end

        def test_psych_dump_load_factory
          data = Psych.dump(@factory)
          factory2 = Psych.load(data)
          assert_equal(@factory, factory2)
          assert_equal(srid, factory2.srid)
        end
      end
    end
  end
end
