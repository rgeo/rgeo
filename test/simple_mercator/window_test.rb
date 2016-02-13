# -----------------------------------------------------------------------------
#
# Tests for the simple mercator window implementation
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

module RGeo
  module Tests # :nodoc:
    module SimpleMercator # :nodoc:
      class TestWindow < ::Test::Unit::TestCase # :nodoc:
        def setup
          @factory = ::RGeo::Geographic.simple_mercator_factory
        end

        def assert_close_enough(p1_, p2_)
          assert((p1_.x - p2_.x).abs < 0.00001 && (p1_.y - p2_.y).abs < 0.00001)
        end

        def assert_contains_approx(p_, mp_)
          assert(mp_.any? { |q_| (p_.x - q_.x).abs < 0.00001 && (p_.y - q_.y).abs < 0.00001 })
        end

        def test_limits
          limits_ = @factory.projection_limits_window
          assert_in_delta(-20_037_508, limits_.x_min, 1)
          assert_in_delta(-20_037_508, limits_.y_min, 1)
          assert_in_delta(20_037_508, limits_.x_max, 1)
          assert_in_delta(20_037_508, limits_.y_max, 1)
        end

        def test_limits_unprojected
          limits_ = @factory.projection_limits_window
          assert_close_enough(@factory.point(-180, -85.051129), limits_.sw_point)
          assert_close_enough(@factory.point(180, -85.051129), limits_.se_point)
          assert_close_enough(@factory.point(-180, 85.051129), limits_.nw_point)
          assert_close_enough(@factory.point(180, 85.051129), limits_.ne_point)
          assert_close_enough(@factory.point(0, 0), limits_.center_point)
        end

        def test_center_point
          window1_ = Geographic::ProjectedWindow.for_corners(@factory.point(-160, -30), @factory.point(170, 30))
          assert_close_enough(@factory.point(5, 0), window1_.center_point)
          window2_ = Geographic::ProjectedWindow.for_corners(@factory.point(160, -30), @factory.point(-170, 30))
          assert_close_enough(@factory.point(175, 0), window2_.center_point)
        end

        def test_random_point
          window1_ = Geographic::ProjectedWindow.for_corners(@factory.point(-170, 30), @factory.point(-160, 40))
          20.times { assert(window1_.contains_point?(window1_.random_point)) }
          window2_ = Geographic::ProjectedWindow.for_corners(@factory.point(170, 30), @factory.point(-170, 40))
          20.times { assert(window2_.contains_point?(window2_.random_point)) }
        end

        def test_crosses_seam
          window1_ = Geographic::ProjectedWindow.for_corners(@factory.point(-170, 30), @factory.point(170, 40))
          assert(!window1_.crosses_seam?)
          window2_ = Geographic::ProjectedWindow.for_corners(@factory.point(170, 30), @factory.point(-170, 40))
          assert(window2_.crosses_seam?)
        end

        def test_degenerate
          window1_ = Geographic::ProjectedWindow.for_corners(@factory.point(-20, 30), @factory.point(-10, 40))
          assert(!window1_.degenerate?)
          window2_ = Geographic::ProjectedWindow.for_corners(@factory.point(-20, 30), @factory.point(-20, 40))
          assert(window2_.degenerate?)
          window3_ = Geographic::ProjectedWindow.for_corners(@factory.point(-20, 30), @factory.point(-10, 30))
          assert(window3_.degenerate?)
        end

        def test_contains_point
          window1_ = Geographic::ProjectedWindow.for_corners(@factory.point(-170, 30), @factory.point(-160, 40))
          window2_ = Geographic::ProjectedWindow.for_corners(@factory.point(170, 30), @factory.point(-170, 40))
          point1_ = @factory.point(-169, 32)
          point2_ = @factory.point(-171, 32)
          point3_ = @factory.point(-169, 29)
          point4_ = @factory.point(171, 32)
          point5_ = @factory.point(169, 32)
          assert(window1_.contains_point?(point1_))
          assert(!window1_.contains_point?(point2_))
          assert(!window1_.contains_point?(point3_))
          assert(!window2_.contains_point?(point1_))
          assert(window2_.contains_point?(point2_))
          assert(window2_.contains_point?(point4_))
          assert(!window2_.contains_point?(point5_))
        end

        def test_noseam_contains_window
          window1_ = Geographic::ProjectedWindow.for_corners(@factory.point(10, 10), @factory.point(30, 30))
          assert(window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(15, 15), @factory.point(25, 25))))

          assert(!window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(5, 15), @factory.point(25, 25))))
          assert(!window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(15, 15), @factory.point(35, 25))))
          assert(!window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(0, 15), @factory.point(5, 25))))
          assert(!window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(35, 15), @factory.point(40, 25))))
          assert(!window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(5, 15), @factory.point(35, 25))))

          assert(!window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(15, 5), @factory.point(25, 25))))
          assert(!window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(15, 15), @factory.point(25, 35))))
          assert(!window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(15, 0), @factory.point(25, 5))))
          assert(!window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(15, 35), @factory.point(25, 40))))
          assert(!window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(15, 5), @factory.point(25, 35))))

          assert(!window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(170, 35), @factory.point(-170, 40))))
        end

        def test_seam_contains_window
          window1_ = Geographic::ProjectedWindow.for_corners(@factory.point(160, 10), @factory.point(-160, 30))
          assert(window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(175, 15), @factory.point(-175, 25))))
          assert(window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(170, 15), @factory.point(175, 25))))
          assert(window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(-175, 15), @factory.point(-170, 25))))

          assert(!window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(150, 15), @factory.point(170, 25))))
          assert(!window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(150, 15), @factory.point(-170, 25))))
          assert(!window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(-170, 15), @factory.point(-150, 25))))
          assert(!window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(170, 15), @factory.point(-150, 25))))

          assert(!window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(-150, 15), @factory.point(150, 25))))
          assert(!window1_.contains_window?(Geographic::ProjectedWindow.for_corners(@factory.point(150, 15), @factory.point(-150, 25))))
        end

        def test_scaled_by
          window1_ = Geographic::ProjectedWindow.for_corners(@factory.point(20, -20), @factory.point(50, 40))
          window1s_ = window1_.scaled_by(2, 1.5)
          assert(window1s_.contains_point?(@factory.point(10, -25)))
          assert(window1s_.contains_point?(@factory.point(60, 45)))
          assert(!window1s_.contains_point?(@factory.point(0, -25)))
          assert(!window1s_.contains_point?(@factory.point(10, -35)))
        end

        def test_scaled_by_across_seam
          window1_ = Geographic::ProjectedWindow.for_corners(@factory.point(170, -20), @factory.point(-160, 40))
          window1s_ = window1_.scaled_by(2, 1.5)
          assert(window1s_.contains_point?(@factory.point(160, -25)))
          assert(window1s_.contains_point?(@factory.point(-150, 45)))
          assert(!window1s_.contains_point?(@factory.point(150, -25)))
          assert(!window1s_.contains_point?(@factory.point(-140, 45)))
        end

        def test_surrounding_point
          window1_ = Geographic::ProjectedWindow.surrounding_point(@factory.point(20, -20), 1)
          assert(window1_.contains_point?(@factory.point(20, -20)))
          assert(!window1_.contains_point?(@factory.point(20, -21)))
          assert(!window1_.contains_point?(@factory.point(19, -20)))
        end

        def test_bounding_1_point
          window1_ = Geographic::ProjectedWindow.bounding_points([@factory.point(20, -20)]).with_margin(1)
          assert(window1_.contains_point?(@factory.point(20, -20)))
          assert(!window1_.contains_point?(@factory.point(20, -21)))
          assert(!window1_.contains_point?(@factory.point(19, -20)))
        end

        def test_bounding_2_points
          window1_ = Geographic::ProjectedWindow.bounding_points([@factory.point(10, 10), @factory.point(30, 30)])
          assert(window1_.contains_point?(@factory.point(20, 20)))
          assert(!window1_.contains_point?(@factory.point(5, 20)))
          assert(!window1_.contains_point?(@factory.point(20, 35)))
        end

        def test_bounding_2_points_across_seam
          window1_ = Geographic::ProjectedWindow.bounding_points([@factory.point(-170, 10), @factory.point(170, 30)])
          assert(window1_.contains_point?(@factory.point(-174, 20)))
          assert(!window1_.contains_point?(@factory.point(-160, 20)))
          assert(!window1_.contains_point?(@factory.point(160, 20)))
          assert(!window1_.contains_point?(@factory.point(-174, 35)))
        end
      end
    end
  end
end
