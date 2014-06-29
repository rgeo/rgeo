# -----------------------------------------------------------------------------
#
# Common tests for polygon implementations
#
# -----------------------------------------------------------------------------
# Copyright 2010-2012 Daniel Azuma
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the copyright holder, nor the names of any other
#   contributors to this software, may be used to endorse or promote products
#   derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# -----------------------------------------------------------------------------
;


require 'rgeo'


module RGeo
  module Tests  # :nodoc:
    module Common  # :nodoc:

      module PolygonTests  # :nodoc:


        def test_creation_simple
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(1, 0)
          exterior_ = @factory.linear_ring([point1_, point2_, point3_, point1_])
          polygon_ = @factory.polygon(exterior_)
          assert_not_nil(polygon_)
          assert(::RGeo::Feature::Polygon === polygon_)
          assert_equal(::RGeo::Feature::Polygon, polygon_.geometry_type)
          assert(exterior_.eql?(polygon_.exterior_ring))
          assert_equal(0, polygon_.num_interior_rings)
          assert_nil(polygon_.interior_ring_n(0))
          assert_nil(polygon_.interior_ring_n(-1))
        end


        def test_creation_one_hole
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 10)
          point3_ = @factory.point(10, 10)
          point4_ = @factory.point(10, 0)
          point5_ = @factory.point(4, 4)
          point6_ = @factory.point(5, 6)
          point7_ = @factory.point(6, 4)
          exterior_ = @factory.linear_ring([point1_, point2_, point3_, point4_, point1_])
          interior_ = @factory.linear_ring([point5_, point6_, point7_, point5_])
          polygon_ = @factory.polygon(exterior_, [interior_])
          assert_not_nil(polygon_)
          assert(::RGeo::Feature::Polygon === polygon_)
          assert_equal(::RGeo::Feature::Polygon, polygon_.geometry_type)
          assert(exterior_.eql?(polygon_.exterior_ring))
          assert_equal(1, polygon_.num_interior_rings)
          assert(interior_.eql?(polygon_.interior_ring_n(0)))
          assert_nil(polygon_.interior_ring_n(1))
          assert_nil(polygon_.interior_ring_n(-1))
        end


        def test_required_equivalences
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(1, 0)
          exterior1_ = @factory.linear_ring([point1_, point2_, point3_, point1_])
          poly1_ = @factory.polygon(exterior1_)
          point4_ = @factory.point(0, 0)
          point5_ = @factory.point(0, 1)
          point6_ = @factory.point(1, 0)
          exterior2_ = @factory.linear_ring([point4_, point5_, point6_, point4_])
          poly2_ = @factory.polygon(exterior2_)
          assert(poly1_.eql?(poly2_))
          assert(poly1_ == poly2_)
        end


        def test_fully_equal
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(1, 0)
          exterior1_ = @factory.linear_ring([point1_, point2_, point3_, point1_])
          poly1_ = @factory.polygon(exterior1_)
          point4_ = @factory.point(0, 0)
          point5_ = @factory.point(0, 1)
          point6_ = @factory.point(1, 0)
          exterior2_ = @factory.linear_ring([point4_, point5_, point6_, point4_])
          poly2_ = @factory.polygon(exterior2_)
          assert(poly1_.rep_equals?(poly2_))
          assert(poly1_.equals?(poly2_))
        end


        def test_geometrically_equal_but_ordered_different
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(1, 0)
          exterior1_ = @factory.linear_ring([point1_, point2_, point3_, point1_])
          poly1_ = @factory.polygon(exterior1_)
          exterior2_ = @factory.linear_ring([point2_, point3_, point1_, point2_])
          poly2_ = @factory.polygon(exterior2_)
          assert(!poly1_.rep_equals?(poly2_))
          assert(poly1_.equals?(poly2_))
        end


        def test_geometrically_equal_but_different_directions
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(1, 0)
          exterior1_ = @factory.linear_ring([point1_, point2_, point3_, point1_])
          poly1_ = @factory.polygon(exterior1_)
          exterior2_ = @factory.linear_ring([point1_, point3_, point2_, point1_])
          poly2_ = @factory.polygon(exterior2_)
          assert(!poly1_.rep_equals?(poly2_))
          assert(poly1_.equals?(poly2_))
        end


        def test_hashes_equal_for_representationally_equivalent_objects
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(1, 0)
          exterior1_ = @factory.linear_ring([point1_, point2_, point3_, point1_])
          poly1_ = @factory.polygon(exterior1_)
          point4_ = @factory.point(0, 0)
          point5_ = @factory.point(0, 1)
          point6_ = @factory.point(1, 0)
          exterior2_ = @factory.linear_ring([point4_, point5_, point6_, point4_])
          poly2_ = @factory.polygon(exterior2_)
          assert_equal(poly1_.hash, poly2_.hash)
        end


        def test_wkt_creation_simple
          parsed_poly_ = @factory.parse_wkt('POLYGON((0 0, 0 1, 1 0, 0 0))')
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(1, 0)
          exterior_ = @factory.linear_ring([point1_, point2_, point3_, point1_])
          built_poly_ = @factory.polygon(exterior_)
          assert(built_poly_.eql?(parsed_poly_))
        end


        def test_wkt_creation_one_hole
          parsed_poly_ = @factory.parse_wkt('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0), (4 4, 5 6, 6 4, 4 4))')
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 10)
          point3_ = @factory.point(10, 10)
          point4_ = @factory.point(10, 0)
          point5_ = @factory.point(4, 4)
          point6_ = @factory.point(5, 6)
          point7_ = @factory.point(6, 4)
          exterior_ = @factory.linear_ring([point1_, point2_, point3_, point4_, point1_])
          interior_ = @factory.linear_ring([point5_, point6_, point7_, point5_])
          built_poly_ = @factory.polygon(exterior_, [interior_])
          assert(built_poly_.eql?(parsed_poly_))
        end


        def test_clone
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(1, 0)
          exterior_ = @factory.linear_ring([point1_, point2_, point3_, point1_])
          poly1_ = @factory.polygon(exterior_)
          poly2_ = poly1_.clone
          assert(poly1_.eql?(poly2_))
          assert(exterior_.eql?(poly2_.exterior_ring))
          assert_equal(0, poly2_.num_interior_rings)
        end


        def test_type_check
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(1, 0)
          exterior_ = @factory.linear_ring([point1_, point2_, point3_, point1_])
          poly_ = @factory.polygon(exterior_)
          assert(::RGeo::Feature::Geometry.check_type(poly_))
          assert(!::RGeo::Feature::Point.check_type(poly_))
          assert(!::RGeo::Feature::GeometryCollection.check_type(poly_))
          assert(::RGeo::Feature::Surface.check_type(poly_))
          assert(::RGeo::Feature::Polygon.check_type(poly_))
        end


        def test_as_text_wkt_round_trip
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(1, 0)
          exterior_ = @factory.linear_ring([point1_, point2_, point3_, point1_])
          poly1_ = @factory.polygon(exterior_)
          text_ = poly1_.as_text
          poly2_ = @factory.parse_wkt(text_)
          assert(poly1_.eql?(poly2_))
        end


        def test_as_binary_wkb_round_trip
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(1, 0)
          exterior_ = @factory.linear_ring([point1_, point2_, point3_, point1_])
          poly1_ = @factory.polygon(exterior_)
          binary_ = poly1_.as_binary
          poly2_ = @factory.parse_wkb(binary_)
          assert(poly1_.eql?(poly2_))
        end


        def test_dimension
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 10)
          point3_ = @factory.point(10, 10)
          point4_ = @factory.point(10, 0)
          point5_ = @factory.point(4, 4)
          point6_ = @factory.point(5, 6)
          point7_ = @factory.point(6, 4)
          exterior_ = @factory.linear_ring([point1_, point2_, point3_, point4_, point1_])
          interior_ = @factory.linear_ring([point5_, point6_, point7_, point5_])
          poly_ = @factory.polygon(exterior_, [interior_])
          assert_equal(2, poly_.dimension)
        end


        def test_is_empty
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(1, 0)
          exterior_ = @factory.linear_ring([point1_, point2_, point3_, point1_])
          poly1_ = @factory.polygon(exterior_)
          assert(!poly1_.is_empty?)
          poly2_ = @factory.polygon(@factory.linear_ring([]))
          assert(poly2_.is_empty?)
        end

        def test_ignores_duplicate_points
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 1)
          point3_ = @factory.point(0, 1)
          point4_ = @factory.point(1, 0)
          exterior_ = @factory.linear_ring([point1_, point2_, point3_, point4_, point1_])
          poly1_ = @factory.polygon(exterior_)
          assert(!poly1_.nil?)
        end


      end

    end
  end
end
