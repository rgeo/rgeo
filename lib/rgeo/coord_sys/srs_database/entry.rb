# frozen_string_literal: true

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

    # Spatial reference system database classes must implement these methods:
    #   get
    #   clear_cache
    #
    # See SrOrg and UrlReader for implementations of SRSDatabase classes.
    #
    # Retrieve an Entry given an identifier. The identifier is usually
    # a numeric spatial reference ID (SRID), but could be a string
    # value for certain database types.
    #   get(identifier)
    #
    # Clear any cache utilized by this database.
    #   clear_cache

    module SRSDatabase
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

        def initialize(ident, data = {})
          @identifier = ident
          @authority = data[:authority]
          @authority_code = data[:authority_code]
          @name = data[:name]
          @description = data[:description]
          @coord_sys = data[:coord_sys]
          if @coord_sys.is_a?(String)
            @coord_sys = CS.create_from_wkt(@coord_sys)
          end
          @proj4 = data[:proj4]
          if @proj4 && CoordSys.check!(:proj4)
            if @proj4.is_a?(String) || @proj4.is_a?(Hash)
              @proj4 = Proj4.create(@proj4)
            end
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
