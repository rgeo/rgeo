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
      # A spatial reference database implementation that fetches data from
      # internet URLs.

      class UrlReader
        # Create a URL-based spatial reference database.
        #
        # Options:
        #
        # [<tt>:cache</tt>]
        #   If set to true, lookup results are cached so if the same URL
        #   is requested again, the result is served from cache rather
        #   than issuing another HTTP request. Default is false.

        def initialize(opts = {})
          @cache = opts[:cache] ? {} : nil
        end

        # Retrieve the given URL and return an Entry.
        # Returns nil if the URL cannot be read as an OGC WKT or Proj4
        # coordinate system

        def get(ident)
          ident = ident.to_s
          return @cache[ident] if @cache&.include?(ident)
          uri = URI.parse(ident)
          result = nil
          Net::HTTP.start(uri.host, uri.port) do |http|
            request = uri.path
            request = "#{request}?#{uri.query}" if uri.query
            response = http.requestget(request)
            if response.is_a?(Net::HTTPSuccess)
              response = response.body.strip
              if response[0, 1] == "+"
                result = Entry.new(ident, proj4: response)
              else
                result = Entry.new(ident, coord_sys: response)
              end
            end
          end
          @cache[ident] = result if @cache
          result
        end

        # Clear the cache if one is present.

        def clear_cache
          @cache&.clear
        end
      end
    end
  end
end
