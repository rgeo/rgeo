# -----------------------------------------------------------------------------
#
# Tests for type properties
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

    class TestTypes < ::Test::Unit::TestCase  # :nodoc:


      def test_geometry
        assert_equal('Geometry', ::RGeo::Feature::Geometry.type_name)
        assert_nil(::RGeo::Feature::Geometry.supertype)
        assert(::RGeo::Feature::Geometry.subtype_of?(::RGeo::Feature::Geometry))
        assert(!::RGeo::Feature::Geometry.subtype_of?(::RGeo::Feature::Point))
      end


      def test_point
        assert_equal('Point', ::RGeo::Feature::Point.type_name)
        assert_equal(::RGeo::Feature::Geometry, ::RGeo::Feature::Point.supertype)
        assert(::RGeo::Feature::Point.subtype_of?(::RGeo::Feature::Point))
        assert(::RGeo::Feature::Point.subtype_of?(::RGeo::Feature::Geometry))
        assert(!::RGeo::Feature::Point.subtype_of?(::RGeo::Feature::LineString))
      end


      def test_line_string
        assert_equal('LineString', ::RGeo::Feature::LineString.type_name)
        assert_equal(::RGeo::Feature::Curve, ::RGeo::Feature::LineString.supertype)
        assert(::RGeo::Feature::LineString.subtype_of?(::RGeo::Feature::LineString))
        assert(::RGeo::Feature::LineString.subtype_of?(::RGeo::Feature::Curve))
        assert(::RGeo::Feature::LineString.subtype_of?(::RGeo::Feature::Geometry))
        assert(!::RGeo::Feature::LineString.subtype_of?(::RGeo::Feature::Line))
      end


    end

  end
end

unless ::RGeo.yaml_supported?
  puts "WARNING: Psych not installed. Skipping YAML tests."
end
