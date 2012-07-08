# -----------------------------------------------------------------------------
#
# Various Geos-related internal utilities
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


module RGeo

  module Geos


    module Utils  # :nodoc:

      class << self


        def ffi_coord_seqs_equal?(cs1_, cs2_, check_z_)
          len1_ = cs1_.length
          len2_ = cs2_.length
          if len1_ == len2_
            (0...len1_).each do |i_|
              return false unless cs1_.get_x(i_) == cs2_.get_x(i_) &&
                cs1_.get_y(i_) == cs2_.get_y(i_) &&
                (!check_z_ || cs1_.get_z(i_) == cs2_.get_z(i_))
            end
            true
          else
            false
          end
        end


        def ffi_compute_dimension(geom_)
          result_ = -1
          case geom_.type_id
          when ::Geos::GeomTypes::GEOS_POINT
            result_ = 0
          when ::Geos::GeomTypes::GEOS_MULTIPOINT
            result_ = 0 unless geom_.empty?
          when ::Geos::GeomTypes::GEOS_LINESTRING, ::Geos::GeomTypes::GEOS_LINEARRING
            result_ = 1
          when ::Geos::GeomTypes::GEOS_MULTILINESTRING
            result_ = 1 unless geom_.empty?
          when ::Geos::GeomTypes::GEOS_POLYGON
            result_ = 2
          when ::Geos::GeomTypes::GEOS_MULTIPOLYGON
            result_ = 2 unless geom_.empty?
          when ::Geos::GeomTypes::GEOS_GEOMETRYCOLLECTION
            geom_.each do |g_|
              dim_ = ffi_compute_dimension(g_)
              result_ = dim_ if result_ < dim_
            end
          end
          result_
        end


        def ffi_coord_seq_hash(cs_, hash_=0)
          (0...cs_.length).inject(hash_) do |h_, i_|
            [hash_, cs_.get_x(i_), cs_.get_y(i_), cs_.get_z(i_)].hash
          end
        end


        def _init
          if FFI_SUPPORTED
            @ffi_supports_prepared_level_1 = ::Geos::FFIGeos.respond_to?(:GEOSPreparedContains_r)
            @ffi_supports_prepared_level_2 = ::Geos::FFIGeos.respond_to?(:GEOSPreparedDisjoint_r)
            @ffi_supports_set_output_dimension = ::Geos::FFIGeos.respond_to?(:GEOSWKTWriter_setOutputDimension_r)
          end
          @psych_wkt_generator = WKRep::WKTGenerator.new(:convert_case => :upper)
          @marshal_wkb_generator = WKRep::WKBGenerator.new
        end

        attr_reader :ffi_supports_prepared_level_1
        attr_reader :ffi_supports_prepared_level_2
        attr_reader :ffi_supports_set_output_dimension
        attr_reader :psych_wkt_generator
        attr_reader :marshal_wkb_generator


      end

    end


  end

end
