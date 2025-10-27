# frozen_string_literal: true

module Geos
  class GeoJSONWriter
    attr_accessor :indentation
    attr_reader :ptr

    def initialize(options = {})
      options = {
        indentation: -1
      }.merge(options)

      ptr = FFIGeos.GEOSGeoJSONWriter_create_r(Geos.current_handle_pointer)
      @ptr = FFI::AutoPointer.new(
        ptr,
        self.class.method(:release)
      )

      set_options(options)
    end

    def self.release(ptr) # :nodoc:
      FFIGeos.GEOSGeoJSONWriter_destroy_r(Geos.current_handle_pointer, ptr)
    end

    def set_options(options) # :nodoc:
      [:indentation].each do |k|
        send("#{k}=", options[k]) if respond_to?("#{k}=") && options.key?(k)
      end
    end
    private :set_options

    # Options can be set temporarily for individual writes using an options
    # Hash. Options include :indentation.
    def write(geom, options = nil)
      unless options.nil?
        old_options = {
          indentation: indentation
        }

        set_options(options)
      end

      FFIGeos.GEOSGeoJSONWriter_writeGeometry_r(Geos.current_handle_pointer, ptr, geom.ptr, indentation)
    ensure
      set_options(old_options) unless options.nil?
    end
  end
end
