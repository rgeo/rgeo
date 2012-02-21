# -----------------------------------------------------------------------------
#
# Tests for miscellaneous GEOS stuff
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


module RGeo
  module Tests  # :nodoc:
    module GeosCAPI  # :nodoc:

      class TestMisc < ::Test::Unit::TestCase  # :nodoc:


        def setup
          @factory = ::RGeo::Geos.factory(:srid => 4326)
        end


        def test_uninitialized
          geom_ = ::RGeo::Geos::GeometryImpl.new
          assert_equal(false, geom_.initialized?)
          assert_nil(geom_.geometry_type)
        end


        def test_empty_geometries_equal
          geom1_ = @factory.collection([])
          geom2_ = @factory.line_string([])
          assert(!geom1_.eql?(geom2_))
          assert(geom1_.equals?(geom2_))
        end


        def test_prepare
          p1_ = @factory.point(1, 2)
          p2_ = @factory.point(3, 4)
          p3_ = @factory.point(5, 2)
          polygon_ = @factory.polygon(@factory.linear_ring([p1_, p2_, p3_, p1_]))
          assert_equal(false, polygon_.prepared?)
          polygon_.prepare!
          assert_equal(true, polygon_.prepared?)
        end


        def test_auto_prepare
          p1_ = @factory.point(1, 2)
          p2_ = @factory.point(3, 4)
          p3_ = @factory.point(5, 2)
          polygon_ = @factory.polygon(@factory.linear_ring([p1_, p2_, p3_, p1_]))
          assert_equal(false, polygon_.prepared?)
          polygon_.intersects?(p1_)
          assert_equal(false, polygon_.prepared?)
          polygon_.intersects?(p2_)
          assert_equal(true, polygon_.prepared?)

          factory_no_auto_prepare_ = ::RGeo::Geos.factory(:srid => 4326, :auto_prepare => :disabled)
          polygon2_ = factory_no_auto_prepare_.polygon(
            factory_no_auto_prepare_.linear_ring([p1_, p2_, p3_, p1_]))
          assert_equal(false, polygon2_.prepared?)
          polygon2_.intersects?(p1_)
          assert_equal(false, polygon2_.prepared?)
          polygon2_.intersects?(p2_)
          assert_equal(false, polygon2_.prepared?)
        end


        def test_gh_21
          # Test for GH-21 (seg fault in rgeo_convert_to_geos_geometry)
          # This seemed to fail under Ruby 1.8.7 only.
          f_ = RGeo::Geographic.simple_mercator_factory
          loc_ = f_.line_string([f_.point(-123, 37), f_.point(-122, 38)])
          f2_ = f_.projection_factory
          loc2_ = f2_.line_string([f2_.point(-123, 37), f2_.point(-122, 38)])
          loc2_.intersection(loc_)
        end


      end

    end
  end
end if ::RGeo::Geos.capi_supported?

unless ::RGeo::Geos.capi_supported?
  puts "WARNING: GEOS CAPI support not available. Related tests skipped."
end
