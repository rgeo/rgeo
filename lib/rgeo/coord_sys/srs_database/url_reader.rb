# -----------------------------------------------------------------------------
#
# SRS database interface
#
# -----------------------------------------------------------------------------
# Copyright 2010-2012 Daniel Azuma
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


require 'net/http'


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

        def initialize(opts_={})
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
            if response_.kind_of?(::Net::HTTPSuccess)
              response_ = response_.body.strip
              if response_[0,1] == '+'
                result_ = Entry.new(ident_, :proj4 => response_)
              else
                result_ = Entry.new(ident_, :coord_sys => response_)
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
