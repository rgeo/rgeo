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

        def initialize(catalog_, opts_ = {})
          @catalog = catalog_.to_s.downcase
          @cache = opts_[:cache] ? {} : nil
        end

        # The spatialreference.org catalog used by this database.
        attr_reader :catalog

        # Retrieve the Entry from a spatialreference.org catalog given an
        # integer ID.

        def get(ident_)
          ident_ = ident_.to_s
          return @cache[ident_] if @cache && @cache.include?(ident_)
          coord_sys_ = nil
          proj4_ = nil
          ::Net::HTTP.start("spatialreference.org") do |http_|
            response_ = http_.request_get("/ref/#{@catalog}/#{ident_}/ogcwkt/")
            coord_sys_ = response_.body if response_.is_a?(::Net::HTTPSuccess)
            response_ = http_.request_get("/ref/#{@catalog}/#{ident_}/proj4/")
            proj4_ = response_.body if response_.is_a?(::Net::HTTPSuccess)
          end
          result_ = Entry.new(ident_, coord_sys: coord_sys_.strip, proj4: proj4_.strip)
          @cache[ident_] = result_ if @cache
          result_
        end

        # Clear the cache if one exists.

        def clear_cache
          @cache.clear if @cache
        end
      end
    end
  end
end
