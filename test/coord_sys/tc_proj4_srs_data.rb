# -----------------------------------------------------------------------------
#
# Tests for OGC CS classes
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
    module CoordSys  # :nodoc:

      class TestProj4SRSData < ::Test::Unit::TestCase  # :nodoc:


        def test_epsg_4326
          db_ = ::RGeo::CoordSys::SRSDatabase::Proj4Data.new('epsg')
          entry_ = db_.get(4326)
          assert_equal('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs', entry_.proj4.original_str)
          assert_equal('WGS 84', entry_.name)
        end


        def test_epsg_3785
          db_ = ::RGeo::CoordSys::SRSDatabase::Proj4Data.new('epsg')
          entry_ = db_.get(3785)
          assert_equal('+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs', entry_.proj4.original_str)
          assert_equal('Popular Visualisation CRS / Mercator (deprecated)', entry_.name)
        end


        def test_nad83_4601
          db_ = ::RGeo::CoordSys::SRSDatabase::Proj4Data.new('nad83')
          entry_ = db_.get(4601)
          assert_equal('+proj=lcc  +datum=NAD83 +lon_0=-120d50 +lat_1=48d44 +lat_2=47d30 +lat_0=47 +x_0=500000 +y_0=0 +no_defs', entry_.proj4.original_str)
          assert_equal('4601: washington north: nad83', entry_.name)
        end


      end

    end
  end
end if ::RGeo::CoordSys::Proj4.supported?
