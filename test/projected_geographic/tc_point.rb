# -----------------------------------------------------------------------------
#
# Tests for the simple mercator point implementation
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

require ::File.expand_path('../common/point_tests.rb', ::File.dirname(__FILE__))


module RGeo
  module Tests  # :nodoc:
    module ProjectedGeographic  # :nodoc:

      class TestPoint < ::Test::Unit::TestCase  # :nodoc:


        def setup
          @factory = ::RGeo::Geographic.projected_factory(:projection_proj4 => '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs', :projection_srid => 3857)
          @zfactory = ::RGeo::Geographic.projected_factory(:has_z_coordinate => true, :projection_proj4 => '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs', :projection_srid => 3857)
          @mfactory = ::RGeo::Geographic.projected_factory(:has_m_coordinate => true, :projection_proj4 => '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs', :projection_srid => 3857)
          @zmfactory = ::RGeo::Geographic.projected_factory(:has_z_coordinate => true, :has_m_coordinate => true, :projection_proj4 => '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs', :projection_srid => 3857)
        end


        include ::RGeo::Tests::Common::PointTests


        def test_has_projection
          point_ = @factory.point(21, -22)
          assert(point_.respond_to?(:projection))
        end


        def test_latlon
          point_ = @factory.point(21, -22)
          assert_equal(21, point_.longitude)
          assert_equal(-22, point_.latitude)
        end


        def test_srid
          point_ = @factory.point(11, 12)
          assert_equal(4326, point_.srid)
        end


        def test_distance
          point1_ = @factory.point(11, 12)
          point2_ = @factory.point(11, 12)
          point3_ = @factory.point(13, 12)
          assert_in_delta(0, point1_.distance(point2_), 0.0001)
          assert_in_delta(222638, point1_.distance(point3_), 1)
        end


      end

    end
  end
end if ::RGeo::CoordSys::Proj4.supported?
