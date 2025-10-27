# frozen_string_literal: true

require 'test_helper'

class GeometryMinimumClearanceTests < Minitest::Test
  include TestHelper

  def setup
    super
    writer.trim = true
  end

  def test_minimum_clearance
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:minimum_clearance)

    tester = lambda { |expected_clearance, geom|
      geom = read(geom)
      clearance = geom.minimum_clearance

      if expected_clearance.eql?(Float::INFINITY)
        assert_predicate(clearance, :infinite?)
      else
        assert_in_delta(expected_clearance, clearance, TOLERANCE)
      end
    }

    tester[Float::INFINITY, 'LINESTRING EMPTY']
    tester[20, 'LINESTRING (30 100, 10 100)']
    tester[100, 'LINESTRING (200 200, 200 100)']
    tester[3.49284983912134e-05, 'LINESTRING (-112.712119 33.575919, -112.712127 33.575885)']
  end

  def test_minimum_clearance_line
    skip unless ENV['FORCE_TESTS'] || Geos::Geometry.method_defined?(:minimum_clearance_line)

    tester = lambda { |expected_geom, geom|
      geom = read(geom)
      clearance_geom = geom.minimum_clearance_line

      assert_equal(expected_geom, write(clearance_geom))
    }

    tester['LINESTRING EMPTY', 'MULTIPOINT ((100 100), (100 100))']
    tester['LINESTRING (30 100, 10 100)', 'MULTIPOINT ((100 100), (10 100), (30 100))']
    tester['LINESTRING (200 200, 200 100)', 'POLYGON ((100 100, 300 100, 200 200, 100 100))']
    tester[
      'LINESTRING (-112.712119 33.575919, -112.712127 33.575885)',
      '0106000000010000000103000000010000001a00000035d42824992d5cc01b834e081dca404073b9c150872d5cc03465a71fd4c940400ec00644882d5cc03b8a' \
      '73d4d1c94040376dc669882d5cc0bf9cd9aed0c940401363997e892d5cc002f4fbfecdc94040ca4e3fa88b2d5cc0a487a1d5c9c940408f1ce90c8c2d5cc06989' \
      '95d1c8c94040fab836548c2d5cc0bd175fb4c7c940409f1f46088f2d5cc0962023a0c2c940407b15191d902d5cc068041bd7bfc940400397c79a912d5cc0287d' \
      '21e4bcc940403201bf46922d5cc065e3c116bbc940409d9d0c8e922d5cc0060fd3beb9c940400ef7915b932d5cc09012bbb6b7c940404fe61f7d932d5cc0e4a0' \
      '8499b6c94040fc71fbe5932d5cc0ea9106b7b5c94040eaec6470942d5cc0c2323674b3c94040601dc70f952d5cc043588d25acc94040aea06989952d5cc03ecf' \
      '9f36aac94040307f85cc952d5cc0e5eb32fca7c94040dd0a6135962d5cc01b615111a7c9404048a7ae7c962d5cc00a2aaa7ea5c94040f4328ae5962d5cc05eb8' \
      '7361a4c94040c49448a2972d5cc04d81cccea2c940407c80eecb992d5cc06745d4449fc9404035d42824992d5cc01b834e081dca4040'
    ]
    tester['LINESTRING EMPTY', 'POLYGON EMPTY']
  end
end
