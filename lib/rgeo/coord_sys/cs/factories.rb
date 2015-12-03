# -----------------------------------------------------------------------------
#
# OGC CS factory for RGeo
#
# -----------------------------------------------------------------------------

module RGeo
  module CoordSys
    # This module contains an implementation of the CS (coordinate
    # systems) package of the OGC Coordinate Transform spec. It provides
    # classes for representing ellipsoids, datums, coordinate systems,
    # and other related concepts, as well as a parser for the WKT format
    # for specifying coordinate systems.
    #
    # Generally, the easiest way to create coordinate system objects is
    # to use RGeo::CoordSys::CS.create_from_wkt, which parses the WKT
    # format. You can also use the create methods available for each
    # object class.
    #
    # Most but not all of the spec is implemented here.
    # Currently missing are:
    #
    # * XML format is not implemented. We're assuming that WKT is the
    #   preferred format.
    # * The PT and CT packages are not implemented.
    # * FittedCoordinateSystem is not implemented.
    # * The defaultEnvelope attribute of CS_CoordinateSystem is not
    #   implemented.

    module CS
      # A class implementing the CS_CoordinateSystemFactory interface.
      # It provides methods for building up complex objects from simpler
      # objects or values.
      #
      # Note that the methods of CS_CoordinateSystemFactory do not provide
      # facilities for setting the authority. If you need to set authority
      # values, use the create methods for the object classes themselves.

      class CoordinateSystemFactory
        # Create a CompoundCoordinateSystem from a name, and two
        # constituent coordinate systems.

        def create_compound_coordinate_system(name_, head_, tail_)
          CompoundCoordinateSystem.create(name_, head_, tail_)
        end

        # Create an Ellipsoid from a name, semi-major axis, and semi-minor
        # axis. You can also provide a LinearUnit, but this is optional
        # and may be set to nil.

        def create_ellipsoid(name_, semi_major_axis_, semi_minor_axis_, linear_unit_)
          Ellipsoid.create_ellipsoid(name_, semi_major_axis_, semi_minor_axis_, linear_unit_)
        end

        # Create an Ellipsoid from a name, semi-major axis, and an inverse
        # flattening factor. You can also provide a LinearUnit, but this
        # is optional and may be set to nil.

        def create_flattened_sphere(name_, semi_major_axis_, inverse_flattening_, linear_unit_)
          Ellipsoid.create_flattened_sphere(name_, semi_major_axis_, inverse_flattening_, linear_unit_)
        end

        # Create any object given the OGC WKT format. Raises
        # Error::ParseError if a syntax error is encounterred.

        def create_from_wkt(str_)
          WKTParser.new(str_).parse
        end

        # Create a GeographicCoordinateSystem, given a name, an
        # AngularUnit, a HorizontalDatum, a PrimeMeridian, and two
        # AxisInfo objects. The AxisInfo objects are optional and may be
        # set to nil.

        def create_geographic_coordinate_system(name_, angular_unit_, horizontal_datum_, prime_meridian_, axis0_, axis1_)
          GeographicCoordinateSystem.create(name_, angular_unit_, horizontal_datum_, prime_meridian_, axis0_, axis1_)
        end

        # Create a HorizontalDatum given a name, a horizontal datum type
        # code, an Ellipsoid, and a WGS84ConversionInfo. The
        # WGS84ConversionInfo is optional and may be set to nil.

        def create_horizontal_datum(name_, horizontal_datum_type_, ellipsoid_, to_wgs84_)
          HorizontalDatum.create(name_, horizontal_datum_type_, ellipsoid_, to_wgs84_)
        end

        # Create a LocalCoordinateSystem given a name, a LocalDatum, a
        # Unit, and an array of at least one AxisInfo.

        def create_local_coordinate_system(name_, datum_, unit_, axes_)
          LocalCoordinateSystem.create(name_, datum_, unit_, axes_)
        end

        # Create a LocalDatum given a name and a local datum type code.

        def create_local_datum(_name_, local_datum_type_)
          LocalDatum.create(name, local_datum_type_)
        end

        # Create a PrimeMeridian given a name, an AngularUnit, and a
        # longitude offset.

        def create_prime_meridian(_name_, angular_unit_, longitude_)
          PrimeMeridian.create(name, angular_unit_, longitude_)
        end

        # Create a ProjectedCoordinateSystem given a name, a
        # GeographicCoordinateSystem, and Projection, a LinearUnit, and
        # two AxisInfo objects. The AxisInfo objects are optional and may
        # be set to nil.

        def create_projected_coordinate_system(name_, gcs_, projection_, linear_unit_, axis0_, axis1_)
          ProjectedCoordinateSystem.create(name_, gcs_, projection_, linear_unit_, axis0_, axis1_)
        end

        # Create a Projection given a name, a projection class, and an
        # array of ProjectionParameter.

        def create_projection(name_, wkt_projection_class_, parameters_)
          Projection.create(name_, wkt_projection_class_, parameters_)
        end

        # Create a VerticalCoordinateSystem given a name, a VerticalDatum,
        # a VerticalUnit, and an AxisInfo. The AxisInfo is optional and
        # may be nil.

        def create_vertical_coordinate_system(name_, vertical_datum_, vertical_unit_, axis_)
          VerticalCoordinateSystem.create(name_, vertical_datum_, vertical_unit_, axis_)
        end

        # Create a VerticalDatum given a name ane a datum type code.

        def create_vertical_datum(name_, vertical_datum_type_)
          VerticalDatum.create(name_, vertical_datum_type_)
        end
      end

      class << self
        # Parsees OGC WKT format and returns the object created. Raises
        # Error::ParseError if a syntax error is encounterred.

        def create_from_wkt(str_)
          WKTParser.new(str_).parse
        end
      end
    end
  end
end
