# frozen_string_literal: true

module Geos
  class GeoJSONReader
    include Geos::Tools

    attr_reader :ptr

    class ParseError < Geos::ParseError
    end

    def initialize(*args)
      ptr = if args.first.is_a?(FFI::Pointer)
        args.first
      else
        FFIGeos.GEOSGeoJSONReader_create_r(Geos.current_handle_pointer, *args)
      end

      @ptr = FFI::AutoPointer.new(
        ptr,
        self.class.method(:release)
      )
    end

    def read(json, options = {})
      cast_geometry_ptr(FFIGeos.GEOSGeoJSONReader_readGeometry_r(Geos.current_handle_pointer, ptr, json), srid: options[:srid])
    rescue Geos::GEOSException => e
      raise ParseError, e
    end

    def self.release(ptr) # :nodoc:
      FFIGeos.GEOSGeoJSONReader_destroy_r(Geos.current_handle_pointer, ptr)
    end
  end
end
