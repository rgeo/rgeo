# -----------------------------------------------------------------------------
#
# Proj4 projection
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


module RGeo

  module Geographic


    class Proj4Projector  # :nodoc:


      def initialize(geography_factory_, projection_factory_)
        @geography_factory = geography_factory_
        @projection_factory = projection_factory_
      end


      def _set_factories(geography_factory_, projection_factory_)  # :nodoc:
        @geography_factory = geography_factory_
        @projection_factory = projection_factory_
      end


      def project(geometry_)
        Feature.cast(geometry_, @projection_factory, :project)
      end


      def unproject(geometry_)
        Feature.cast(geometry_, @geography_factory, :project)
      end


      def projection_factory
        @projection_factory
      end


      def wraps?
        false
      end


      def limits_window
        nil
      end


      class << self


        def create_from_existing_factory(geography_factory_, projection_factory_)
          new(geography_factory_, projection_factory_)
        end


        def create_from_proj4(geography_factory_, proj4_, opts_={})
          projection_factory_ = Cartesian.preferred_factory(:proj4 => proj4_,
            :coord_sys => opts_[:coord_sys], :srid => opts_[:srid],
            :buffer_resolution => opts_[:buffer_resolution],
            :lenient_multi_polygon_assertions => opts_[:lenient_multi_polygon_assertions],
            :has_z_coordinate => opts_[:has_z_coordinate],
            :has_m_coordinate => opts_[:has_m_coordinate],
            :wkt_parser => opts_[:wkt_parser], :wkt_generator => opts_[:wkt_generator],
            :wkb_parser => opts_[:wkb_parser], :wkb_generator => opts_[:wkb_generator])
          new(geography_factory_, projection_factory_)
        end


      end


    end


  end

end
