# frozen_string_literal: true

module Geos
  class PreparedGeometry
    include Geos::Tools

    attr_reader :ptr, :geometry

    undef :clone, :dup

    def initialize(geom, options = {})
      check_geometry(geom)

      options = {
        auto_free: true
      }.merge(options)

      @ptr = FFI::AutoPointer.new(
        FFIGeos.GEOSPrepare_r(Geos.current_handle_pointer, geom.ptr),
        self.class.method(:release)
      )
      @geometry = geom

      @ptr.autorelease = !!options[:auto_free]
    end

    def self.release(ptr) # :nodoc:
      FFIGeos.GEOSPreparedGeom_destroy_r(Geos.current_handle_pointer, ptr)
    end

    def contains?(geom)
      check_geometry(geom)
      bool_result(FFIGeos.GEOSPreparedContains_r(Geos.current_handle_pointer, ptr, geom.ptr))
    end

    def contains_properly?(geom)
      check_geometry(geom)
      bool_result(FFIGeos.GEOSPreparedContainsProperly_r(Geos.current_handle_pointer, ptr, geom.ptr))
    end

    def covered_by?(geom)
      check_geometry(geom)
      bool_result(FFIGeos.GEOSPreparedCoveredBy_r(Geos.current_handle_pointer, ptr, geom.ptr))
    end

    def covers?(geom)
      check_geometry(geom)
      bool_result(FFIGeos.GEOSPreparedCovers_r(Geos.current_handle_pointer, ptr, geom.ptr))
    end

    def crosses?(geom)
      check_geometry(geom)
      bool_result(FFIGeos.GEOSPreparedCrosses_r(Geos.current_handle_pointer, ptr, geom.ptr))
    end

    def disjoint?(geom)
      check_geometry(geom)
      bool_result(FFIGeos.GEOSPreparedDisjoint_r(Geos.current_handle_pointer, ptr, geom.ptr))
    end

    def intersects?(geom)
      check_geometry(geom)
      bool_result(FFIGeos.GEOSPreparedIntersects_r(Geos.current_handle_pointer, ptr, geom.ptr))
    end

    def overlaps?(geom)
      check_geometry(geom)
      bool_result(FFIGeos.GEOSPreparedOverlaps_r(Geos.current_handle_pointer, ptr, geom.ptr))
    end

    def touches?(geom)
      check_geometry(geom)
      bool_result(FFIGeos.GEOSPreparedTouches_r(Geos.current_handle_pointer, ptr, geom.ptr))
    end

    def within?(geom)
      check_geometry(geom)
      bool_result(FFIGeos.GEOSPreparedWithin_r(Geos.current_handle_pointer, ptr, geom.ptr))
    end

    def distance(geom)
      check_geometry(geom)
      double_ptr = FFI::MemoryPointer.new(:double)
      FFIGeos.GEOSPreparedDistance_r(Geos.current_handle_pointer, ptr, geom.ptr, double_ptr)
      double_ptr.read_double
    end

    def distance_within?(geom, distance)
      check_geometry(geom)
      bool_result(FFIGeos.GEOSPreparedDistanceWithin_r(Geos.current_handle_pointer, ptr, geom.ptr, distance))
    end

    def nearest_points(geom)
      check_geometry(geom)

      coord_seq_ptr = FFIGeos.GEOSPreparedNearestPoints_r(Geos.current_handle_pointer, ptr, geom.ptr)

      Geos::CoordinateSequence.new(coord_seq_ptr)
    end
  end
end
