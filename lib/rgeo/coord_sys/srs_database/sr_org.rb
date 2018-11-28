# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# SRS database interface
#
# -----------------------------------------------------------------------------

require "net/http"

module RGeo
  module CoordSys
    module SRSDatabase
      # A spatial reference database implementation that fetches data
      # from the spatialreference.org website.

      class SrOrg
        # Create a database backed by the given catalog of the
        # spatialreference.org website. Catalogs currently supported by
        # spatialreference.org are "epsg", "esri", "iau2000" and "sr-org".
        #
        # Options:
        #
        # [<tt>:cache</tt>]
        #   If set to true, lookup results are cached so if the same URL
        #   is requested again, the result is served from cache rather
        #   than issuing another HTTP request. Default is false.

        def initialize(catalog, opts = {})
          @catalog = catalog.to_s.downcase
          @cache = opts[:cache] ? {} : nil
        end

        # The spatialreference.org catalog used by this database.
        attr_reader :catalog

        # Retrieve the Entry from a spatialreference.org catalog given an
        # integer ID.

        def get(ident)
          ident = ident.to_s
          return @cache[ident] if @cache&.include?(ident)
          coord_sys = nil
          proj4 = nil
          Net::HTTP.start("spatialreference.org") do |http|
            response = http.request_get("/ref/#{@catalog}/#{ident}/ogcwkt/")
            coord_sys = response.body if response.is_a?(Net::HTTPSuccess)
            response = http.request_get("/ref/#{@catalog}/#{ident}/proj4/")
            proj4 = response.body if response.is_a?(Net::HTTPSuccess)
          end
          result = Entry.new(ident, coord_sys: coord_sys.strip, proj4: proj4.strip)
          @cache[ident] = result if @cache
          result
        end

        # Clear the cache if one exists.

        def clear_cache
          @cache&.clear
        end
      end
    end
  end
end
