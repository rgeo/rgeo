# -----------------------------------------------------------------------------
#
# Tests for the GEOS point implementation
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

require ::File.expand_path('../common/factory_tests.rb', ::File.dirname(__FILE__))


module RGeo
  module Tests  # :nodoc:
    module GeosCAPI  # :nodoc:

      class TestZMFactory < ::Test::Unit::TestCase  # :nodoc:


        def setup
          @factory = ::RGeo::Geos.factory(:has_z_coordinate => true, :has_m_coordinate => true, :srid => 1000, :buffer_resolution => 2)
          @srid = 1000
        end


        include ::RGeo::Tests::Common::FactoryTests


        def test_factory_parts
          assert_equal(1000, @factory.srid)
          assert_equal(1000, @factory.z_factory.srid)
          assert_equal(1000, @factory.m_factory.srid)
          assert_equal(2, @factory.buffer_resolution)
          assert_equal(2, @factory.z_factory.buffer_resolution)
          assert_equal(2, @factory.m_factory.buffer_resolution)
          assert(@factory.property(:has_z_coordinate))
          assert(@factory.property(:has_m_coordinate))
          assert(@factory.z_factory.property(:has_z_coordinate))
          assert(!@factory.z_factory.property(:has_m_coordinate))
          assert(!@factory.m_factory.property(:has_z_coordinate))
          assert(@factory.m_factory.property(:has_m_coordinate))
        end


        def test_4d_point
          point_ = @factory.point(1, 2, 3, 4)
          assert_equal(Feature::Point, point_.geometry_type)
          assert_equal(3, point_.z)
          assert_equal(4, point_.m)
          assert_equal(3, point_.z_geometry.z)
          assert_nil(point_.z_geometry.m)
          assert_nil(point_.m_geometry.z)
          assert_equal(4, point_.m_geometry.m)
        end


      end

    end
  end
end if ::RGeo::Geos.capi_supported?
