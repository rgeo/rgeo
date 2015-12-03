# -----------------------------------------------------------------------------
#
# SRS database interface
#
# -----------------------------------------------------------------------------

module RGeo
  module CoordSys
    # This module contains tools for accessing spatial reference
    # databases. These are databases (either local or remote) from which
    # you can look up coordinate system specifications, typically in
    # either OGC or Proj4 format. For example, you can access the
    # <tt>spatial_ref_sys</tt> table provided with an OGC-compliant RDBMS
    # such as PostGIS. You can also read the database files provided with
    # the proj4 library, or access online databases such as the
    # spatialreference.org site.

    module SRSDatabase
      # Interface specification for spatial reference system databases.
      # This module exists primarily for the sake of documentation.
      # Database implementations need not actually include this module,
      # but at least need to duck-type its methods.

      module Interface
        # Retrieve an Entry given an identifier. The identifier is usually
        # a numeric spatial reference ID (SRID), but could be a string
        # value for certain database types.

        def get(_ident_)
          nil
        end

        # Clears any cache utilized by this database.

        def clear_cache
          nil
        end
      end

      # An entry in a spatial reference system database.
      # Every entry has an identifier, but all the other attributes are
      # optional and may or may not be present depending on the database.

      class Entry
        # Create an entry.
        # You must provide an identifier, which may be numeric or a
        # string. The data hash should contain any other attributes,
        # keyed by symbol.
        #
        # Some attribute inputs have special behaviors:
        #
        # [<tt>:coord_sys</tt>]
        #   You can pass a CS coordinate system object, or a string in
        #   WKT format.
        # [<tt>:proj4</tt>]
        #   You can pass a Proj4 object, or a proj4-format string.
        # [<tt>:name</tt>]
        #   If the name is not provided directly, it is taken from the
        #   coord_sys.
        # [<tt>:authority</tt>]
        #   If the authority name is not provided directly, it is taken
        #   from the coord_sys.
        # [<tt>:authority_code</tt>]
        #   If the authority code is not provided directly, it is taken
        #   from the coord_sys.

        def initialize(ident_, data_ = {})
          @identifier = ident_
          @authority = data_[:authority]
          @authority_code = data_[:authority_code]
          @name = data_[:name]
          @description = data_[:description]
          @coord_sys = data_[:coord_sys]
          if @coord_sys.is_a?(::String)
            @coord_sys = CS.create_from_wkt(@coord_sys)
          end
          @proj4 = data_[:proj4]
          if Proj4.supported?
            if @proj4.is_a?(::String) || @proj4.is_a?(::Hash)
              @proj4 = Proj4.create(@proj4)
            end
          else
            @proj4 = nil
          end
          if @coord_sys
            @name = @coord_sys.name unless @name
            @authority = @coord_sys.authority unless @authority
            @authority_code = @coord_sys.authority unless @authority_code
          end
        end

        # The database key or identifier.
        attr_reader :identifier

        # The authority name, if present. Example: "epsg".
        attr_reader :authority

        # The authority code, e.g. an EPSG code.
        attr_reader :authority_code

        # A human-readable name for this coordinate system.
        attr_reader :name

        # A human-readable description for this coordinate system.
        attr_reader :description

        # The CS::CoordinateSystem object.
        attr_reader :coord_sys

        # The Proj4 object.
        attr_reader :proj4
      end
    end
  end
end
