# -----------------------------------------------------------------------------
#
# Common tests for geometry collection implementations
#
# -----------------------------------------------------------------------------

require "rgeo"

module RGeo
  module Tests # :nodoc:
    module Common # :nodoc:
      module FactoryTests # :nodoc:
        def _srid
          defined?(@srid) ? @srid : 0
        end

        def test_srid_preserved_through_factory
          geom_ = @factory.point(-10, 20)
          assert_equal(_srid, geom_.srid)
          factory_ = geom_.factory
          assert_equal(_srid, factory_.srid)
          geom2_ = factory_.point(-20, 25)
          assert_equal(_srid, geom2_.srid)
        end

        def test_srid_preserved_through_geom_operations
          geom1_ = @factory.point(-10, 20)
          geom2_ = @factory.point(-20, 25)
          geom3_ = geom1_.union(geom2_)
          assert_equal(_srid, geom3_.srid)
          assert_equal(_srid, geom3_.geometry_n(0).srid)
          assert_equal(_srid, geom3_.geometry_n(1).srid)
        end

        def test_srid_preserved_through_geom_functions
          geom1_ = @factory.point(-10, 20)
          geom2_ = geom1_.boundary
          assert_equal(_srid, geom2_.srid)
        end

        def test_srid_preserved_through_geometry_dup
          geom1_ = @factory.point(-10, 20)
          geom2_ = geom1_.clone
          assert_equal(_srid, geom2_.srid)
        end

        def test_dup_factory_results_in_equal_factories
          dup_factory_ = @factory.dup
          assert_equal(@factory, dup_factory_)
          assert_equal(_srid, dup_factory_.srid)
        end

        def test_dup_factory_results_in_equal_hashes
          dup_factory_ = @factory.dup
          assert_equal(@factory.hash, dup_factory_.hash)
        end

        def test_marshal_dump_load_factory
          data_ = ::Marshal.dump(@factory)
          factory2_ = ::Marshal.load(data_)
          assert_equal(@factory, factory2_)
          assert_equal(_srid, factory2_.srid)
        end

        def test_psych_dump_load_factory
          data_ = Psych.dump(@factory)
          factory2_ = Psych.load(data_)
          assert_equal(@factory, factory2_)
          assert_equal(_srid, factory2_.srid)
        end
      end
    end
  end
end
