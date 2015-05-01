# -----------------------------------------------------------------------------
#
# Tests for the GEOS polygon implementation
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


require 'test/unit'
require 'rgeo'

require ::File.expand_path('../common/polygon_tests.rb', ::File.dirname(__FILE__))


module RGeo
  module Tests  # :nodoc:
    module GeosCAPI  # :nodoc:

      class TestPolygon < ::Test::Unit::TestCase  # :nodoc:


        def setup
          @factory = ::RGeo::Geos.factory
        end


        include ::RGeo::Tests::Common::PolygonTests


        def test_intersection
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 2)
          point3_ = @factory.point(2, 2)
          point4_ = @factory.point(2, 0)
          poly1_ = @factory.polygon(@factory.linear_ring([point1_, point2_, point3_, point4_]))
          poly2_ = @factory.polygon(@factory.linear_ring([point1_, point2_, point4_]))
          poly3_ = poly1_.intersection(poly2_)
          assert_equal(poly2_, poly3_)
        end


        def test_union
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 2)
          point3_ = @factory.point(2, 2)
          point4_ = @factory.point(2, 0)
          poly1_ = @factory.polygon(@factory.linear_ring([point1_, point2_, point3_, point4_]))
          poly2_ = @factory.polygon(@factory.linear_ring([point1_, point2_, point4_]))
          poly3_ = poly1_.union(poly2_)
          assert_equal(poly1_, poly3_)
        end


        def test_simplify
          xys = [[0, 0], [5, 0], [10, 0], [10, 10], [5, 10.2], [0, 10], [0, 0]]
          points = xys.collect { |x,y| @factory.point(x, y) }
          poly = @factory.polygon(@factory.linear_ring(points))
          simplified = poly.simplify(0.3)
          new_points = simplified.exterior_ring.points
          extra = new_points.reject { |p| [0, 10].include?(p.x) and [0, 10].include?(p.y) }
          assert_equal 5, new_points.length, "Closed ring of the square should have 5 points"
          assert_equal 0, extra.length , "Should only have x/y's on 0 and 10"
        end


      end

    end
  end
end if ::RGeo::Geos.capi_supported?
