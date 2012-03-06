# -----------------------------------------------------------------------------
#
# Tests for proj4 wrapper
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

      class TestProj4 < ::Test::Unit::TestCase  # :nodoc:


        def test_create_wgs84
          proj_ = ::RGeo::CoordSys::Proj4.create('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')
          assert_equal(true, proj_.geographic?)
          assert_equal('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs', proj_.original_str)
          assert_equal(' +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0', proj_.canonical_str)
        end


        def test_get_wgs84_geographic
          proj_ = ::RGeo::CoordSys::Proj4.create('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')
          proj2_ = proj_.get_geographic
          assert_nil(proj2_.original_str)
          assert_equal(true, proj2_.geographic?)
          coords_ = ::RGeo::CoordSys::Proj4.transform_coords(proj_, proj2_, 1, 2, 0)
          assert_equal([1, 2, 0], coords_)
        end


        def test_identity_transform
          proj_ = ::RGeo::CoordSys::Proj4.create('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')
          assert_equal([1, 2, 0], ::RGeo::CoordSys::Proj4.transform_coords(proj_, proj_, 1, 2, 0))
          assert_equal([1, 2], ::RGeo::CoordSys::Proj4.transform_coords(proj_, proj_, 1, 2, nil))
        end


        def _project_merc(x_, y_)
          [x_ * 6378137.0, ::Math.log(::Math.tan(::Math::PI / 4.0 + y_ / 2.0)) * 6378137.0]
        end


        def _unproject_merc(x_, y_)
          [x_ / 6378137.0, (2.0 * ::Math.atan(::Math.exp(y_ / 6378137.0)) - ::Math::PI / 2.0)]
        end


        def _assert_close_enough(a_, b_)
          assert_in_delta(a_, b_, ::Math.sqrt(a_*a_+b_*b_)*0.00000001)
        end


        def _assert_xy_close(xy1_, xy2_)
          _assert_close_enough(xy1_[0], xy2_[0])
          _assert_close_enough(xy1_[1], xy2_[1])
        end


        def test_simple_mercator_transform
          geography_ = ::RGeo::CoordSys::Proj4.create('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs', :radians => true)
          projection_ = ::RGeo::CoordSys::Proj4.create('+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs')
          _assert_xy_close(_project_merc(0, 0), ::RGeo::CoordSys::Proj4.transform_coords(geography_, projection_, 0, 0, nil))
          _assert_xy_close(_project_merc(0.01, 0.01), ::RGeo::CoordSys::Proj4.transform_coords(geography_, projection_, 0.01, 0.01, nil))
          _assert_xy_close(_project_merc(1, 1), ::RGeo::CoordSys::Proj4.transform_coords(geography_, projection_, 1, 1, nil))
          _assert_xy_close(_project_merc(-1, -1), ::RGeo::CoordSys::Proj4.transform_coords(geography_, projection_, -1, -1, nil))
          _assert_xy_close(_unproject_merc(0, 0), ::RGeo::CoordSys::Proj4.transform_coords(projection_, geography_, 0, 0, nil))
          _assert_xy_close(_unproject_merc(10000, 10000), ::RGeo::CoordSys::Proj4.transform_coords(projection_, geography_, 10000, 10000, nil))
          _assert_xy_close(_unproject_merc(-20000000, -20000000), ::RGeo::CoordSys::Proj4.transform_coords(projection_, geography_, -20000000, -20000000, nil))
        end


        def test_equivalence
          proj1_ = ::RGeo::CoordSys::Proj4.create('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')
          proj2_ = ::RGeo::CoordSys::Proj4.create('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')
          assert_equal(proj1_, proj2_)
        end


        def test_point_projection_cast
          geography_ = ::RGeo::Geos.factory(:proj4 => '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs', :srid =>4326)
          projection_ = ::RGeo::Geos.factory(:proj4 => '+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +datum=OSGB36 +units=m +no_defs', :srid => 27700)
          proj_point_ = projection_.parse_wkt('POINT(473600.5000000000000000 186659.7999999999883585)')
          geo_point_ = ::RGeo::Feature.cast(proj_point_, :project => true, :factory => geography_)
          _assert_close_enough(-0.9393598527244420, geo_point_.x)
          _assert_close_enough(51.5740106527552697, geo_point_.y)
        end


        def test_point_transform_lowlevel
          geography_ = ::RGeo::Geos.factory(:proj4 => '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs', :srid =>4326)
          projection_ = ::RGeo::Geos.factory(:proj4 => '+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +datum=OSGB36 +units=m +no_defs', :srid => 27700)
          proj_point_ = projection_.parse_wkt('POINT(473600.5000000000000000 186659.7999999999883585)')
          geo_point_ = ::RGeo::CoordSys::Proj4.transform(projection_.proj4, proj_point_, geography_.proj4, geography_)
          _assert_close_enough(-0.9393598527244420, geo_point_.x)
          _assert_close_enough(51.5740106527552697, geo_point_.y)
        end


        def test_geocentric
          obj1_ = ::RGeo::CoordSys::Proj4.create('+proj=geocent +ellps=WGS84')
          assert_equal(true, obj1_.geocentric?)
        end


        def test_get_geographic
          projection_ = ::RGeo::CoordSys::Proj4.create('+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs')
          geographic_ = projection_.get_geographic
          expected_ = ::RGeo::CoordSys::Proj4.create('+proj=latlong +a=6378137 +b=6378137 +nadgrids=@null')
          assert_equal(expected_, geographic_)
        end


        def test_marshal_roundtrip
          obj1_ = ::RGeo::CoordSys::Proj4.create('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')
          dump_ = ::Marshal.dump(obj1_)
          obj2_ = ::Marshal.load(dump_)
          assert_equal(obj1_, obj2_)
        end


        def test_dup
          obj1_ = ::RGeo::CoordSys::Proj4.create('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')
          obj2_ = obj1_.dup
          assert_equal(obj1_, obj2_)
        end


        def test_dup_of_get_geographic
          obj1_ = ::RGeo::CoordSys::Proj4.create('+proj=latlong +datum=WGS84 +ellps=WGS84')
          obj2_ = obj1_.get_geographic
          obj3_ = obj2_.dup
          assert_equal(obj1_, obj3_)
        end


        if ::RGeo.yaml_supported?

          def test_yaml_roundtrip
            obj1_ = ::RGeo::CoordSys::Proj4.create('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')
            dump_ = ::Psych.dump(obj1_)
            obj2_ = ::Psych.load(dump_)
            assert_equal(obj1_, obj2_)
          end

        end


      end

    end
  end
end if ::RGeo::CoordSys::Proj4.supported?

unless ::RGeo::CoordSys::Proj4.supported?
  puts "WARNING: Proj4 support not available. Related tests skipped."
end
