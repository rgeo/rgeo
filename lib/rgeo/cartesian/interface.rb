# -----------------------------------------------------------------------------
#
# Cartesian toplevel interface
#
# -----------------------------------------------------------------------------

module RGeo
  module Cartesian
    class << self
      # Creates and returns a cartesian factory of the preferred
      # Cartesian implementation.
      #
      # The actual implementation returned depends on which ruby
      # interpreter is running and what libraries are available.
      # RGeo will try to provide a fully-functional and performant
      # implementation if possible. If not, the simple Cartesian
      # implementation will be returned.
      # In practice, this means it returns a Geos implementation if
      # available; otherwise it falls back to the simple implementation.
      #
      # The given options are passed to the factory's constructor.
      # What options are available depends on the particular
      # implementation. See RGeo::Geos.factory and
      # RGeo::Cartesian.simple_factory for details. Unsupported options
      # are ignored.

      def preferred_factory(opts_ = {})
        if ::RGeo::Geos.supported?
          ::RGeo::Geos.factory(opts_)
        else
          simple_factory(opts_)
        end
      end
      alias_method :factory, :preferred_factory

      # Returns a factory for the simple Cartesian implementation. This
      # implementation provides all SFS 1.1 types, and also allows Z and
      # M coordinates. It does not depend on external libraries, and is
      # thus always available, but it does not implement many of the more
      # advanced geometric operations. These limitations are:
      #
      # * Relational operators such as Feature::Geometry#intersects? are
      #   not implemented for most types.
      # * Relational constructors such as Feature::Geometry#union are
      #   not implemented for most types.
      # * Buffer and convex hull calculations are not implemented for most
      #   types. Boundaries are available except for GeometryCollection.
      # * Length calculations are available, but areas are not. Distances
      #   are available only between points.
      # * Equality and simplicity evaluation are implemented for some but
      #   not all types.
      # * Assertions for polygons and multipolygons are not implemented.
      #
      # Unimplemented operations may raise Error::UnsupportedOperation
      # if invoked.
      #
      # Options include:
      #
      # [<tt>:srid</tt>]
      #   Set the SRID returned by geometries created by this factory.
      #   Default is 0.
      # [<tt>:proj4</tt>]
      #   The coordinate system in Proj4 format, either as a
      #   CoordSys::Proj4 object or as a string or hash representing the
      #   proj4 format. Optional.
      # [<tt>:coord_sys</tt>]
      #   The coordinate system in OGC form, either as a subclass of
      #   CoordSys::CS::CoordinateSystem, or as a string in WKT format.
      #   Optional.
      # [<tt>:srs_database</tt>]
      #   Optional. If provided, the value should be an implementation of
      #   CoordSys::SRSDatabase::Interface. If both this and an SRID are
      #   provided, they are used to look up the proj4 and coord_sys
      #   objects from a spatial reference system database.
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

      def simple_factory(opts_ = {})
        Cartesian::Factory.new(opts_)
      end

      # Returns a Feature::FactoryGenerator that creates preferred
      # factories. The given options are used as the default options.
      #
      # A common case for this is to provide the <tt>:srs_database</tt>
      # as a default. Then, the factory generator need only be passed
      # an SRID and it will automatically fetch the appropriate Proj4
      # and CoordSys objects.

      def preferred_factory_generator(defaults_ = {})
        ::Proc.new { |c_| preferred_factory(defaults_.merge(c_)) }
      end
      alias_method :factory_generator, :preferred_factory_generator

      # Returns a Feature::FactoryGenerator that creates simple factories.
      # The given options are used as the default options.
      #
      # A common case for this is to provide the <tt>:srs_database</tt>
      # as a default. Then, the factory generator need only be passed
      # an SRID and it will automatically fetch the appropriate Proj4
      # and CoordSys objects.

      def simple_factory_generator(defaults_ = {})
        ::Proc.new { |c_| simple_factory(defaults_.merge(c_)) }
      end
    end
  end
end
