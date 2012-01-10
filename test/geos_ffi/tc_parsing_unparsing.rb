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


module RGeo
  module Tests  # :nodoc:
    module GeosFFI  # :nodoc:

      class TestParsingUnparsing < ::Test::Unit::TestCase  # :nodoc:


        def test_wkt_generator_default_floating_point
          # Bug report GH-4
          factory_ = ::RGeo::Geos.factory(:native_interface => :ffi)
          point_ = factory_.point(111.99, -40.37)
          assert_equal('POINT (111.99 -40.37)', point_.as_text)
        end


        def test_wkt_generator_downcase
          factory_ = ::RGeo::Geos.factory(:wkt_generator => {:convert_case => :lower},
            :native_interface => :ffi)
          point_ = factory_.point(1, 1)
          assert_equal('point (1.0 1.0)', point_.as_text)
        end


        def test_wkt_generator_geos
          factory_ = ::RGeo::Geos.factory(:wkt_generator => :geos, :native_interface => :ffi)
          point_ = factory_.point(1, 1)
          assert_equal('POINT (1.0000000000000000 1.0000000000000000)', point_.as_text)
        end


        def test_wkt_parser_default_with_non_geosable_input
          factory_ = ::RGeo::Geos.factory(:native_interface => :ffi)
          assert_not_nil(factory_.parse_wkt('Point (1 1)'))
        end


      end

    end
  end
end if ::RGeo::Geos.ffi_supported?
