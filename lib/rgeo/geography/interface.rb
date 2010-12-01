# -----------------------------------------------------------------------------
# 
# Access to geographic data factories
# 
# -----------------------------------------------------------------------------
# Copyright 2010 Daniel Azuma
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
  
  module Geography
    
    class << self
      
      
      # Creates and returns a geographic factory that does not include a
      # a projection, and which performs calculations assuming a
      # spherical earth. In other words, geodesics are treated as great
      # circle arcs, and geometric calculations are handled accordingly.
      # Size and distance calculations report results in meters.
      # This implementation is thus ideal for everyday calculations on
      # the globe in which good accuracy is desired, but in which it is
      # not deemed necessary to perform the complex ellipsoidal
      # calculations needed for greater precision.
      # 
      # The maximum error is about 0.5 percent, for objects and
      # calculations that span a significant percentage of the globe, due
      # to distortion caused by rotational flattening of the earth. For
      # calculations that span a much smaller area, the error can drop to
      # a few meters or less.
      # 
      # === Limitations
      # 
      # This implementation does not implement some of the more advanced
      # geometric operations. In particular:
      # 
      # * Relational operators such as Feature::Geometry#intersects? are
      #   not implemented for most types.
      # * Relational constructors such as Feature::Geometry#union are
      #   not implemented for most types.
      # * Buffer, convex hull, and envelope calculations are not
      #   implemented for most types. Boundaries are available except for
      #   GeometryCollection.
      # * Length calculations are available, but areas are not. Distances
      #   are available only between points.
      # * Equality and simplicity evaluation are implemented for some but
      #   not all types.
      # * Assertions for polygons and multipolygons are not implemented.
      # 
      # Unimplemented operations will return nil if invoked.
      # 
      # === Options
      # 
      # You may use the following options when creating a spherical
      # factory:
      # 
      # <tt>:support_z_coordinate</tt>::
      #   Support <tt>z_coordinate</tt>. Default is false.
      # <tt>:support_m_coordinate</tt>::
      #   Support <tt>m_coordinate</tt>. Default is false.
      # <tt>:proj4</tt>::
      #   Provide the coordinate system in Proj4 format. You may pass
      #   either an RGeo::CoordSys::Proj4 object, or a string or hash
      #   containing the Proj4 parameters. This coordinate system must be
      #   a geographic (lat/long) coordinate system. The default is the
      #   "popular visualization CRS" (EPSG 4055), represented by
      #   "<tt>+proj=longlat +a=6378137 +b=6378137 +towgs84=0,0,0,0,0,0,0 +no_defs</tt>".
      #   Has no effect if Proj4 is not available.
      # <tt>:srid</tt>::
      #   The SRID that should be returned by features from this factory.
      #   Default is 4055, indicating EPSG 4055, the "popular
      #   visualization crs". You may alternatively wish to set the srid
      #   to 4326, indicating the WGS84 crs, but note that that value
      #   implies an ellipsoidal datum, not a spherical datum.
      
      def spherical(opts_={})
        Geography::Factory.new('Spherical', :support_z_coordinate => opts_[:support_z_coordinate], :support_m_coordinate => opts_[:support_m_coordinate], :proj4 => opts_[:proj4] || '+proj=longlat +a=6378137 +b=6378137 +towgs84=0,0,0,0,0,0,0 +no_defs', :srid => opts_[:srid] || 4055)
      end
      
      
      # Creates and returns a geographic factory that is designed for
      # visualization applications that use Google or Bing maps, or any
      # other visualization systems that use the same projection. It
      # includes a projection factory that matches the projection used
      # by those mapping systems.
      # 
      # Like all geographic factories, this one creates features using
      # latitude-longitude values. However, calculations such as
      # intersections are done in the projected coordinate system, and
      # size and distance calculations report results in the projected
      # units.
      # 
      # The behavior of the simple_mercator factory could also be obtained
      # using a projected with appropriate Proj4 specifications. However,
      # the simple_mercator implementation is done without actually
      # requiring the Proj4 library. The projections are simple enough to
      # be implemented in pure ruby.
      # 
      # === About the coordinate system
      # 
      # Many popular visualization technologies, such as Google and Bing
      # maps, actually use two coordinate systems. The first is the
      # standard WSG84 lat-long system used by the GPS and represented
      # by EPSG 4326. Most API calls and input-output in these mapping
      # technologies utilize this coordinate system. The second is a
      # Mercator projection based on a "sphericalization" of the WGS84
      # lat-long system. This projection is the basis of the map's screen
      # and tiling coordinates, and has been assigned EPSG 3857.
      # 
      # This factory represents both coordinate systems. The main factory
      # produces data in the lat-long system and reports SRID 4326, and
      # the projected factory produces data in the projection and reports
      # SRID 3857. Latitudes are restricted to the range
      # (-85.05112877980659, 85.05112877980659), which conveniently
      # results in a square projected domain.
      # 
      # === Options
      # 
      # You may use the following options when creating a simple_mercator
      # factory:
      # 
      # <tt>:lenient_multi_polygon_assertions</tt>::
      #   If set to true, assertion checking on MultiPolygon is disabled.
      #   This may speed up creation of MultiPolygon objects, at the
      #   expense of not doing the proper checking for OGC MultiPolygon
      #   compliance. See RGeo::Feature::MultiPolygon for details on
      #   the MultiPolygon assertions. Default is false.
      # <tt>:buffer_resolution</tt>::
      #   The resolution of buffers around geometries created by this
      #   factory. This controls the number of line segments used to
      #   approximate curves. The default is 1, which causes, for
      #   example, the buffer around a point to be approximated by a
      #   4-sided polygon. A resolution of 2 would cause that buffer
      #   to be approximated by an 8-sided polygon. The exact behavior
      #   for different kinds of buffers is defined by GEOS.
      # <tt>:support_z_coordinate</tt>::
      #   Support <tt>z_coordinate</tt>. Default is false.
      #   Note that simple_mercator factories cannot support both
      #   <tt>z_coordinate</tt> and <tt>m_coordinate</tt>. They may at
      #   most support one or the other.
      # <tt>:support_m_coordinate</tt>::
      #   Support <tt>m_coordinate</tt>. Default is false.
      #   Note that simple_mercator factories cannot support both
      #   <tt>z_coordinate</tt> and <tt>m_coordinate</tt>. They may at
      #   most support one or the other.
      
      def simple_mercator(opts_={})
        factory_ = Geography::Factory.new('Projected', :proj4 => '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs', :srid => 4326, :support_z_coordinate => opts_[:support_z_coordinate], :support_m_coordinate => opts_[:support_m_coordinate])
        projector_ = Geography::SimpleMercatorProjector.new(factory_, :buffer_resolution => opts_[:buffer_resolution], :lenient_multi_polygon_assertions => opts_[:lenient_multi_polygon_assertions], :support_z_coordinate => opts_[:support_z_coordinate], :support_m_coordinate => opts_[:support_m_coordinate])
        factory_._set_projector(projector_)
        factory_
      end
      
      
      # Creates and returns a geographic factory that includes a
      # projection specified by a Proj4 coordinate system. Like all
      # geographic factories, this one creates features using latitude-
      # longitude values. However, calculations such as intersections are
      # done in the projected coordinate system, and size and distance
      # calculations report results in the projected units.
      # 
      # This implementation is intended for advanced GIS applications
      # requiring intimate control over the projection being used.
      # 
      # === Options
      # 
      # When creating a projected implementation, you must provide either
      # the <tt>:projection_factory</tt> option, indicating an existing
      # Cartesian factory to use for the projection, or the
      # <tt>:projection_proj4</tt> option, indicating a Proj4 projection
      # to use to construct an appropriate projection factory.
      # 
      # If you provide <tt>:projection_factory</tt>, the following options
      # are supported.
      # 
      # <tt>:projection_factory</tt>::
      #   Specify an existing Cartesian factory to use for the projection.
      #   This factory must support the <tt>:proj4</tt> capability.
      # 
      # Note that in this case, the geography factory's z-coordinate and
      # m-coordinate availability will be set to match the projection's
      # z-coordinate and m-coordinate availability.
      # 
      # If you provide <tt>:projection_proj4</tt>, the following options
      # are supported.
      # 
      # <tt>:projection_proj4</tt>::
      #   Specify a Proj4 projection to use. This may be specified as a
      #   CoordSys::Proj4 object, or as a Proj4 string or hash
      #   representation.
      # <tt>:projection_srid</tt>::
      #   An SRID value to use for the projection factory. Default is 0.
      # <tt>:lenient_multi_polygon_assertions</tt>::
      #   If set to true, assertion checking on MultiPolygon is disabled.
      #   This may speed up creation of MultiPolygon objects, at the
      #   expense of not doing the proper checking for OGC MultiPolygon
      #   compliance. See RGeo::Feature::MultiPolygon for details on
      #   the MultiPolygon assertions. Default is false.
      # <tt>:buffer_resolution</tt>::
      #   The resolution of buffers around geometries created by this
      #   factory. This controls the number of line segments used to
      #   approximate curves. The default is 1, which causes, for
      #   example, the buffer around a point to be approximated by a
      #   4-sided polygon. A resolution of 2 would cause that buffer
      #   to be approximated by an 8-sided polygon. The exact behavior
      #   for different kinds of buffers is defined by GEOS.
      # <tt>:support_z_coordinate</tt>::
      #   Support <tt>z_coordinate</tt>. Default is false.
      # <tt>:support_m_coordinate</tt>::
      #   Support <tt>m_coordinate</tt>. Default is false.
      
      def projected(opts_={})
        unless CoordSys::Proj4.supported?
          raise Error::UnsupportedCapability, "Proj4 is not supported because the proj4 library was not found at install time."
        end
        if (projection_factory_ = opts_[:projection_factory])
          factory_ = Geography::Factory.new('Projected', :proj4 => opts_[:proj4] || '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs', :srid => opts_[:srid] || 4326, :support_z_coordinate => projection_factory_.has_capability?(:z_coordinate), :support_m_coordinate => projection_factory_.has_capability?(:m_coordinate))
          projector_ = Geography::Proj4Projector.create_from_existing_factory(factory_, projection_factory_)
        elsif opts_[:projection_proj4]
          factory_ = Geography::Factory.new('Projected', :proj4 => opts_[:proj4] || '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs', :srid => opts_[:srid] || 4326, :support_z_coordinate => opts_[:support_z_coordinate], :support_m_coordinate => opts_[:support_m_coordinate])
          projector_ = Geography::Proj4Projector.create_from_proj4(factory_, opts_[:projection_proj4], :srid => opts_[:projection_srid], :buffer_resolution => opts_[:buffer_resolution], :lenient_multi_polygon_assertions => opts_[:lenient_multi_polygon_assertions], :support_z_coordinate => opts_[:support_z_coordinate], :support_m_coordinate => opts_[:support_m_coordinate])
        else
          raise ::ArgumentError, 'You must provide either :projection_proj4 or :projection_factory.'
        end
        factory_._set_projector(projector_)
        factory_
      end
      
      
    end
    
  end
  
end
