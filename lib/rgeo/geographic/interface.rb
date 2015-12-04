# -----------------------------------------------------------------------------
#
# Access to geographic data factories
#
# -----------------------------------------------------------------------------

module RGeo
  module Geographic
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
      # [<tt>:has_z_coordinate</tt>]
      #   Support a Z coordinate. Default is false.
      # [<tt>:has_m_coordinate</tt>]
      #   Support an M coordinate. Default is false.
      # [<tt>:uses_lenient_assertions</tt>]
      #   If set to true, assertion checking is disabled. This includes
      #   simplicity checking on LinearRing, and validity checks on
      #   Polygon and MultiPolygon. This may speed up creation of certain
      #   objects, at the expense of not doing the proper checking for
      #   OGC compliance. Default is false.
      # [<tt>:buffer_resolution</tt>]
      #   The resolution of buffers around geometries created by this
      #   factory. This controls the number of line segments used to
      #   approximate curves. The default is 1, which causes, for
      #   example, the buffer around a point to be approximated by a
      #   4-sided polygon. A resolution of 2 would cause that buffer
      #   to be approximated by an 8-sided polygon. The exact behavior
      #   for different kinds of buffers is not specified precisely,
      #   but in general the value is taken as the number of segments
      #   per 90-degree curve.
      # [<tt>:proj4</tt>]
      #   Provide the coordinate system in Proj4 format. You may pass
      #   either an RGeo::CoordSys::Proj4 object, or a string or hash
      #   containing the Proj4 parameters. This coordinate system must be
      #   a geographic (lat/long) coordinate system. The default is the
      #   "popular visualization CRS" (EPSG 4055), represented by
      #   "<tt>+proj=longlat +a=6378137 +b=6378137 +towgs84=0,0,0,0,0,0,0 +no_defs</tt>".
      #   Has no effect if Proj4 is not available.
      # [<tt>:coord_sys</tt>]
      #   Provide a coordinate system in OGC format, either as an object
      #   (one of the CoordSys::CS classes) or as a string in WKT format.
      #   This coordinate system must be a GeographicCoordinateSystem.
      #   The default is the "popular visualization CRS" (EPSG 4055).
      # [<tt>:srid</tt>]
      #   The SRID that should be returned by features from this factory.
      #   Default is 4055, indicating EPSG 4055, the "popular
      #   visualization crs". You may alternatively wish to set the srid
      #   to 4326, indicating the WGS84 crs, but note that that value
      #   implies an ellipsoidal datum, not a spherical datum.
      # [<tt>:srs_database</tt>]
      #   Optional. If provided, the value should be an implementation of
      #   CoordSys::SRSDatabase::Interface. If both this and an SRID are
      #   provided, they are used to look up the proj4 and coord_sys
      #   objects from a spatial reference system database.
      # [<tt>:wkt_parser</tt>]
      #   Configure the parser for WKT. The value is a hash of
      #   configuration parameters for WKRep::WKTParser.new. Default is
      #   the empty hash, indicating the default configuration for
      #   WKRep::WKTParser.
      # [<tt>:wkb_parser</tt>]
      #   Configure the parser for WKB. The value is a hash of
      #   configuration parameters for WKRep::WKBParser.new. Default is
      #   the empty hash, indicating the default configuration for
      #   WKRep::WKBParser.
      # [<tt>:wkt_generator</tt>]
      #   Configure the generator for WKT. The value is a hash of
      #   configuration parameters for WKRep::WKTGenerator.new.
      #   Default is <tt>{:convert_case => :upper}</tt>.
      # [<tt>:wkb_generator</tt>]
      #   Configure the generator for WKT. The value is a hash of
      #   configuration parameters for WKRep::WKTGenerator.new.
      #   Default is the empty hash, indicating the default configuration
      #   for WKRep::WKBGenerator.

      def spherical_factory(opts_ = {})
        proj4_ = opts_[:proj4]
        coord_sys_ = opts_[:coord_sys]
        srid_ = opts_[:srid]
        if (!proj4_ || !coord_sys_) && srid_ && (db_ = opts_[:srs_database])
          entry_ = db_.get(srid_.to_i)
          if entry_
            proj4_ ||= entry_.proj4
            coord_sys_ ||= entry_.coord_sys
          end
        end
        srid_ ||= coord_sys_.authority_code if coord_sys_
        Geographic::Factory.new("Spherical",
          has_z_coordinate: opts_[:has_z_coordinate],
          has_m_coordinate: opts_[:has_m_coordinate],
          proj4: proj4_ || _proj4_4055,
          coord_sys: coord_sys_ || _coordsys_4055,
          uses_lenient_assertions: opts_[:uses_lenient_assertions],
          buffer_resolution: opts_[:buffer_resolution],
          wkt_parser: opts_[:wkt_parser],
          wkb_parser: opts_[:wkb_parser],
          wkt_generator: opts_[:wkt_generator],
          wkb_generator: opts_[:wkb_generator],
          srid: (srid_ || 4055).to_i)
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
      # using a projected_factory with appropriate Proj4 specifications.
      # However, the simple_mercator implementation is done without
      # actually requiring the Proj4 library. The projections are simple
      # enough to be implemented in pure ruby.
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
      # [<tt>:has_z_coordinate</tt>]
      #   Support a Z coordinate. Default is false.
      # [<tt>:has_m_coordinate</tt>]
      #   Support an M coordinate. Default is false.
      # [<tt>:wkt_parser</tt>]
      #   Configure the parser for WKT. The value is a hash of
      #   configuration parameters for WKRep::WKTParser.new. Default is
      #   the empty hash, indicating the default configuration for
      #   WKRep::WKTParser.
      # [<tt>:wkb_parser</tt>]
      #   Configure the parser for WKB. The value is a hash of
      #   configuration parameters for WKRep::WKBParser.new. Default is
      #   the empty hash, indicating the default configuration for
      #   WKRep::WKBParser.
      # [<tt>:wkt_generator</tt>]
      #   Configure the generator for WKT. The value is a hash of
      #   configuration parameters for WKRep::WKTGenerator.new.
      #   Default is <tt>{:convert_case => :upper}</tt>.
      # [<tt>:wkb_generator</tt>]
      #   Configure the generator for WKT. The value is a hash of
      #   configuration parameters for WKRep::WKTGenerator.new.
      #   Default is the empty hash, indicating the default configuration
      #   for WKRep::WKBGenerator.
      #
      # You may also provide options understood by the underlying
      # projected Cartesian factory. For example, if GEOS is used for the
      # projected factory, you may also set the
      # <tt>:lenient_multi_polygon_assertions</tt> and
      # <tt>:buffer_resolution</tt> options. See RGeo::Geos.factory for
      # more details.

      def simple_mercator_factory(opts_ = {})
        factory_ = Geographic::Factory.new("Projected",
          proj4: _proj4_4326,
          coord_sys: _coordsys_4326,
          srid: 4326,
          wkt_parser: opts_[:wkt_parser],
          wkb_parser: opts_[:wkb_parser],
          wkt_generator: opts_[:wkt_generator],
          wkb_generator: opts_[:wkb_generator],
          has_z_coordinate: opts_[:has_z_coordinate],
          has_m_coordinate: opts_[:has_m_coordinate])
        projector_ = Geographic::SimpleMercatorProjector.new(factory_,
          buffer_resolution: opts_[:buffer_resolution],
          lenient_multi_polygon_assertions: opts_[:lenient_multi_polygon_assertions],
          uses_lenient_assertions: opts_[:uses_lenient_assertions],
          has_z_coordinate: opts_[:has_z_coordinate],
          has_m_coordinate: opts_[:has_m_coordinate])
        factory_._set_projector(projector_)
        factory_
      end

      # Creates and returns a geographic factory that includes a
      # projection specified by a Proj4 coordinate system. Like all
      # geographic factories, this one creates features using latitude-
      # longitude values. However, calculations such as intersections are
      # done in the projected coordinate system, and size and distance
      # calculations report results in the projected units. Thus, this
      # factory actually includes two factories representing different
      # coordinate systems: the main factory representing the geographic
      # lat-long coordinate system, and an auxiliary "projection factory"
      # representing the projected coordinate system.
      #
      # This implementation is intended for advanced GIS applications
      # requiring greater control over the projection being used.
      #
      # === Options
      #
      # When creating a projected implementation, you must provide enough
      # information to construct a Proj4 specification for the projection.
      # Generally, this means you will provide either the projection's
      # factory itself (via the <tt>:projection_factory</tt> option), in
      # which case the factory must include a Proj4 coordinate system;
      # or, alternatively, you should provide the Proj4 coordinate system
      # and let this method construct a projection factory for you (which
      # it will do using the preferred Cartesian factory generator).
      # If you choose this second method, you may provide the proj4
      # directly via the <tt>:projection_proj4</tt> option, or indirectly
      # by providing both an <tt>:srid</tt> and a <tt>:srs_database</tt>
      # to use to look up the coordinate system.
      #
      # Following are detailed descriptions of the various options you can
      # pass to this method.
      #
      # [<tt>:projection_factory</tt>]
      #   Specify an existing Cartesian factory to use for the projection.
      #   This factory must have a non-nil Proj4. If this is provided, any
      #   <tt>:projection_proj4</tt>, <tt>:projection_coord_sys</tt>, and
      #   <tt>:projection_srid</tt> are ignored.
      # [<tt>:projection_proj4</tt>]
      #   Specify a Proj4 projection to use to construct the projection
      #   factory. This may be specified as a CoordSys::Proj4 object, or
      #   as a Proj4 string or hash representation.
      # [<tt>:projection_coord_sys</tt>]
      #   Specify a OGC coordinate system for the projection. This may be
      #   specified as an RGeo::CoordSys::CS::GeographicCoordinateSystem
      #   object, or as a String in OGC WKT format. Optional.
      # [<tt>:projection_srid</tt>]
      #   The SRID value to use for the projection factory. Defaults to
      #   the given projection coordinate system's authority code, or to
      #   0 if no projection coordinate system is known.
      # [<tt>:proj4</tt>]
      #   A proj4 projection for the geographic (lat-lon) factory. You may
      #   pass either an RGeo::CoordSys::Proj4 object, or a string or hash
      #   containing the Proj4 parameters. This coordinate system must be
      #   a geographic (lat/long) coordinate system. It defaults to the
      #   geographic part of the projection factory's coordinate system.
      #   Generally, you should leave it at the default unless you want
      #   the geographic coordinate system to be based on a different
      #   horizontal datum than the projection.
      # [<tt>:coord_sys</tt>]
      #   An OGC coordinate system for the geographic (lat-lon) factory,
      #   which may be an RGeo::CoordSys::CS::GeographicCoordinateSystem
      #   object or a string in OGC WKT format. It defaults to the
      #   geographic system embedded in the projection coordinate system.
      #   Generally, you should leave it at the default unless you want
      #   the geographic coordinate system to be based on a different
      #   horizontal datum than the projection.
      # [<tt>:srid</tt>]
      #   The SRID value to use for the main geographic factory. Defaults
      #   to the given geographic coordinate system's authority code, or
      #   to 0 if no geographic coordinate system is known.
      # [<tt>:srs_database</tt>]
      #   Optional. If provided, the value should be an implementation of
      #   CoordSys::SRSDatabase::Interface. If both this and an SRID are
      #   provided, they are used to look up the proj4 and coord_sys
      #   objects from a spatial reference system database.
      # [<tt>:has_z_coordinate</tt>]
      #   Support a Z coordinate. Default is false.
      #   Note: this is ignored if a <tt>:projection_factory</tt> is
      #   provided; in that case, the geographic factory's z-coordinate
      #   availability will match the projection factory's setting.
      # [<tt>:has_m_coordinate</tt>]
      #   Support an M coordinate. Default is false.
      #   Note: this is ignored if a <tt>:projection_factory</tt> is
      #   provided; in that case, the geographic factory's m-coordinate
      #   availability will match the projection factory's setting.
      # [<tt>:wkt_parser</tt>]
      #   Configure the parser for WKT. The value is a hash of
      #   configuration parameters for WKRep::WKTParser.new. Default is
      #   the empty hash, indicating the default configuration for
      #   WKRep::WKTParser.
      # [<tt>:wkb_parser</tt>]
      #   Configure the parser for WKB. The value is a hash of
      #   configuration parameters for WKRep::WKBParser.new. Default is
      #   the empty hash, indicating the default configuration for
      #   WKRep::WKBParser.
      # [<tt>:wkt_generator</tt>]
      #   Configure the generator for WKT. The value is a hash of
      #   configuration parameters for WKRep::WKTGenerator.new.
      #   Default is <tt>{:convert_case => :upper}</tt>.
      # [<tt>:wkb_generator</tt>]
      #   Configure the generator for WKT. The value is a hash of
      #   configuration parameters for WKRep::WKTGenerator.new.
      #   Default is the empty hash, indicating the default configuration
      #   for WKRep::WKBGenerator.
      #
      # If a <tt>:projection_factory</tt> is _not_ provided, you may also
      # provide options for configuring the projected Cartesian factory.
      # For example, if GEOS is used for the projected factory, you may
      # also set the <tt>:lenient_multi_polygon_assertions</tt> and
      # <tt>:buffer_resolution</tt> options. See RGeo::Geos.factory for
      # more details.

      def projected_factory(opts_ = {})
        unless CoordSys::Proj4.supported?
          raise Error::UnsupportedOperation, "Proj4 is not supported because the proj4 library was not found at install time."
        end
        db_ = opts_[:srs_database]
        if (projection_factory_ = opts_[:projection_factory])
          # Get the projection coordinate systems from the given factory
          projection_proj4_ = projection_factory_.proj4
          unless projection_proj4_
            raise ::ArgumentError, "The :projection_factory does not have a proj4."
          end
          projection_coord_sys_ = projection_factory_.coord_sys
          if projection_coord_sys_ && !projection_coord_sys_.is_a?(CoordSys::CS::ProjectedCoordinateSystem)
            raise ::ArgumentError, 'The :projection_factory\'s coord_sys is not a ProjectedCoordinateSystem.'
          end
          # Determine geographic coordinate system. First check parameters.
          proj4_ = opts_[:proj4]
          coord_sys_ = opts_[:coord_sys]
          srid_ = opts_[:srid]
          # Lookup srid from srs database if needed
          if (!proj4_ || !coord_sys_) && srid_ && db_
            entry_ = db_.get(srid_.to_i)
            if entry_
              proj4_ ||= entry_.proj4
              coord_sys_ ||= entry_.coord_sys
            end
          end
          # Fall back to getting the values from the projection.
          proj4_ ||= projection_proj4_.get_geographic || _proj4_4326
          coord_sys_ ||= projection_coord_sys_.geographic_coordinate_system if projection_coord_sys_
          srid_ ||= coord_sys_.authority_code if coord_sys_
          srid_ ||= 4326
          # Now we should have all the coordinate system info.
          factory_ = Geographic::Factory.new("Projected",
            proj4: proj4_,
            coord_sys: coord_sys_,
            srid: srid_.to_i,
            has_z_coordinate: projection_factory_.property(:has_z_coordinate),
            has_m_coordinate: projection_factory_.property(:has_m_coordinate),
            wkt_parser: opts_[:wkt_parser], wkt_generator: opts_[:wkt_generator],
            wkb_parser: opts_[:wkb_parser], wkb_generator: opts_[:wkb_generator])
          projector_ = Geographic::Proj4Projector.create_from_existing_factory(factory_,
            projection_factory_)
        else
          # Determine projection coordinate system. First check the parameters.
          projection_proj4_ = opts_[:projection_proj4]
          projection_coord_sys_ = opts_[:projection_coord_sys]
          projection_srid_ = opts_[:projection_srid]
          # Check the case where we need to look up a srid from an srs database.
          if (!projection_proj4_ || !projection_coord_sys_) && projection_srid_ && db_
            entry_ = db_.get(projection_srid_.to_i)
            if entry_
              projection_proj4_ ||= entry_.proj4
              projection_coord_sys_ ||= entry_.coord_sys
            end
          end
          # A projection proj4 is absolutely required.
          unless projection_proj4_
            raise ::ArgumentError, "Unable to determine the Proj4 for the projected coordinate system."
          end
          # Check the projection coordinate systems, and parse if needed.
          if projection_proj4_.is_a?(::String) || projection_proj4_.is_a?(::Hash)
            actual_projection_proj4_ = CoordSys::Proj4.create(projection_proj4_)
            unless actual_projection_proj4_
              raise ::ArgumentError, "Bad proj4 syntax: #{projection_proj4_.inspect}"
            end
            projection_proj4_ = actual_projection_proj4_
          end
          if projection_coord_sys_ && !projection_coord_sys_.is_a?(CoordSys::CS::ProjectedCoordinateSystem)
            raise ::ArgumentError, "The :projection_coord_sys is not a ProjectedCoordinateSystem."
          end
          projection_srid_ ||= projection_coord_sys_.authority_code if projection_coord_sys_
          # Determine geographic coordinate system. First check parameters.
          proj4_ = opts_[:proj4]
          coord_sys_ = opts_[:coord_sys]
          srid_ = opts_[:srid]
          # Lookup srid from srs database if needed
          if (!proj4_ || !coord_sys_) && srid_ && db_
            entry_ = db_.get(srid_.to_i)
            if entry_
              proj4_ ||= entry_.proj4
              coord_sys_ ||= entry_.coord_sys
            end
          end
          # Fall back to getting the values from the projection.
          proj4_ ||= projection_proj4_.get_geographic || _proj4_4326
          coord_sys_ ||= projection_coord_sys_.geographic_coordinate_system if projection_coord_sys_
          srid_ ||= coord_sys_.authority_code if coord_sys_
          srid_ ||= 4326
          # Now we should have all the coordinate system info.
          factory_ = Geographic::Factory.new("Projected",
            proj4: proj4_,
            coord_sys: coord_sys_,
            srid: srid_.to_i,
            has_z_coordinate: opts_[:has_z_coordinate],
            has_m_coordinate: opts_[:has_m_coordinate],
            wkt_parser: opts_[:wkt_parser], wkt_generator: opts_[:wkt_generator],
            wkb_parser: opts_[:wkb_parser], wkb_generator: opts_[:wkb_generator])
          projector_ = Geographic::Proj4Projector.create_from_proj4(factory_,
            projection_proj4_,
            srid: projection_srid_,
            coord_sys: projection_coord_sys_,
            buffer_resolution: opts_[:buffer_resolution],
            lenient_multi_polygon_assertions: opts_[:lenient_multi_polygon_assertions],
            uses_lenient_assertions: opts_[:uses_lenient_assertions],
            has_z_coordinate: opts_[:has_z_coordinate],
            has_m_coordinate: opts_[:has_m_coordinate],
            wkt_parser: opts_[:wkt_parser], wkt_generator: opts_[:wkt_generator],
            wkb_parser: opts_[:wkb_parser], wkb_generator: opts_[:wkb_generator])
        end
        factory_._set_projector(projector_)
        factory_
      end

      def _proj4_4055 # :nodoc:
        unless defined?(@proj4_4055)
          @proj4_4055 = CoordSys::Proj4.create("+proj=longlat +a=6378137 +b=6378137 +towgs84=0,0,0,0,0,0,0 +no_defs")
        end
        @proj4_4055
      end

      def _coordsys_4055 # :nodoc:
        unless defined?(@coordsys_4055)
          @coordsys_4055 = CoordSys::CS.create_from_wkt('GEOGCS["Popular Visualisation CRS",DATUM["Popular_Visualisation_Datum",SPHEROID["Popular Visualisation Sphere",6378137,0,AUTHORITY["EPSG","7059"]],TOWGS84[0,0,0,0,0,0,0],AUTHORITY["EPSG","6055"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.01745329251994328,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4055"]]')
        end
        @coordsys_4055
      end

      def _proj4_4326 # :nodoc:
        unless defined?(@proj4_4326)
          @proj4_4326 = CoordSys::Proj4.create("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
        end
        @proj4_4326
      end

      def _coordsys_4326 # :nodoc:
        unless defined?(@coordsys_4326)
          @coordsys_4326 = CoordSys::CS.create_from_wkt('GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.01745329251994328,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4326"]]')
        end
        @coordsys_4326
      end
    end
  end
end
