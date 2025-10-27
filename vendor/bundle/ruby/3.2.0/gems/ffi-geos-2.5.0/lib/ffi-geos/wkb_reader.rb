# frozen_string_literal: true

module Geos
  class WkbReader
    include Geos::Tools

    attr_reader :ptr

    class ParseError < Geos::ParseError
    end

    def initialize(*args)
      ptr = if args.first.is_a?(FFI::Pointer)
        args.first
      else
        FFIGeos.GEOSWKBReader_create_r(Geos.current_handle_pointer, *args)
      end

      @ptr = FFI::AutoPointer.new(
        ptr,
        self.class.method(:release)
      )
    end

    def read(wkb, options = {})
      cast_geometry_ptr(FFIGeos.GEOSWKBReader_read_r(Geos.current_handle_pointer, ptr, wkb, wkb.bytesize), srid: options[:srid])
    rescue Geos::GEOSException => e
      raise ParseError, e
    end

    def read_hex(wkb, options = {})
      cast_geometry_ptr(FFIGeos.GEOSWKBReader_readHEX_r(Geos.current_handle_pointer, ptr, wkb, wkb.bytesize), srid: options[:srid])
    rescue Geos::GEOSException => e
      raise ParseError, e
    end

    def self.release(ptr) # :nodoc:
      FFIGeos.GEOSWKBReader_destroy_r(Geos.current_handle_pointer, ptr)
    end
  end
end
