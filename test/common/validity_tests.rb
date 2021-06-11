# frozen_string_literal: true

module RGeo
  module Tests # :nodoc:
    module Common # :nodoc:
      module ValidityTests # :nodoc:
        def test_validity_correct_implementation
          assert(
            RGeo::ImplHelper::ValidityCheck.send(:classes).empty?,
            "`ValidityCheck.override_classes` was not called correctly"
          )
          assert(
            defined?(@factory),
            "Tests that include ValidityTests should have a @factory variable."
          )
          assert(
            @factory.point(1, 1).method(:invalid_reason).owner != RGeo::ImplHelper::ValidityCheck,
            "Current implementation must have an `invalid_reason` method for its geometries."
          )
        end

        def test_validity_unsafe_area
          assert_equal(0, bowtie_polygon.unsafe_area)
          assert_raises(RGeo::Error::InvalidGeometry) do
            bowtie_polygon.area
          end
          assert_equal(1, square_polygon.area)
        end

        def test_validity_make_valid
          skip "make_valid not handled by current implementation" unless implements_make_valid?

          assert_equal(0.5, bowtie_polygon.make_valid.area)
        end

        def implements_make_valid?
          square_polygon.method(:make_valid).owner != RGeo::ImplHelper::ValidityCheck
        end

        def square_polygon
          @square_polygon ||= @factory.polygon(
            @factory.linear_ring(
              [
                @factory.point(0, 0),
                @factory.point(1, 0),
                @factory.point(1, 1),
                @factory.point(0, 1),
                @factory.point(0, 0)
              ]
            )
          )
        end

        def bowtie_polygon
          @bowtie_polygon ||= @factory.polygon(
            @factory.linear_ring(
              [
                @factory.point(0, 0),
                @factory.point(1, 1),
                @factory.point(1, 0),
                @factory.point(0, 1),
                @factory.point(0, 0)
              ]
            )
          )
        end
      end
    end
  end
end
