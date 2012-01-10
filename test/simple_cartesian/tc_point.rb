# -----------------------------------------------------------------------------
#
# Tests for the simple cartesian point implementation
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
    module SimpleCartesian  # :nodoc:

      class TestPoint < ::Test::Unit::TestCase  # :nodoc:


        def setup
          @factory = ::RGeo::Cartesian.simple_factory(:srid => 1)
          @zfactory = ::RGeo::Cartesian.simple_factory(:srid => 1, :has_z_coordinate => true)
          @mfactory = ::RGeo::Cartesian.simple_factory(:srid => 1, :has_m_coordinate => true)
          @zmfactory = ::RGeo::Cartesian.simple_factory(:srid => 1, :has_z_coordinate => true, :has_m_coordinate => true)
        end


        include ::RGeo::Tests::Common::PointTests


        def test_srid
          point_ = @factory.point(11, 12)
          assert_equal(1, point_.srid)
        end


        def test_distance
          point1_ = @factory.point(2, 2)
          point2_ = @factory.point(7, 14)
          assert_in_delta(13, point1_.distance(point2_), 0.0001)
        end


        undef_method :test_disjoint
        undef_method :test_intersects
        undef_method :test_touches
        undef_method :test_crosses
        undef_method :test_within
        undef_method :test_contains
        undef_method :test_overlaps
        undef_method :test_intersection
        undef_method :test_union
        undef_method :test_difference
        undef_method :test_sym_difference


      end

    end
  end
end
