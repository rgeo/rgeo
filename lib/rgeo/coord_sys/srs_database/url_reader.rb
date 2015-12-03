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

        def initialize(opts_ = {})
          @cache = opts_[:cache] ? {} : nil
        end

        # Retrieve the given URL and return an Entry.
        # Returns nil if the URL cannot be read as an OGC WKT or Proj4
        # coordinate system

        def get(ident_)
          ident_ = ident_.to_s
          return @cache[ident_] if @cache && @cache.include?(ident_)
          uri_ = ::URI.parse(ident_)
          result_ = nil
          ::Net::HTTP.start(uri_.host, uri_.port) do |http_|
            request_ = uri_.path
            request_ = "#{request_}?#{uri_.query}" if uri_.query
            response_ = http_.request_get(request_)
            if response_.is_a?(::Net::HTTPSuccess)
              response_ = response_.body.strip
              if response_[0, 1] == "+"
                result_ = Entry.new(ident_, proj4: response_)
              else
                result_ = Entry.new(ident_, coord_sys: response_)
              end
            end
          end
          @cache[ident_] = result_ if @cache
          result_
        end

        # Clear the cache if one is present.

        def clear_cache
          @cache.clear if @cache
        end
      end
    end
  end
end
